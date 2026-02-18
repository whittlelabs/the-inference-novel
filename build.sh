#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Check dependencies
command -v pandoc >/dev/null 2>&1 || { echo "Error: pandoc is required. Install with: brew install pandoc"; exit 1; }

# Use venv Python for WeasyPrint if available, otherwise fall back to system
PYTHON="python3"
if [ -f "$SCRIPT_DIR/.venv/bin/python3" ]; then
  PYTHON="$SCRIPT_DIR/.venv/bin/python3"
fi
$PYTHON -c "import weasyprint" 2>/dev/null || { echo "Error: weasyprint is required. Run: python3 -m venv .venv && .venv/bin/pip install weasyprint"; exit 1; }

echo "Building The Inference..."

# Clean and create output directory
rm -rf site
mkdir -p site/read site/discuss site/css

# Convert novel Markdown to HTML via Pandoc
pandoc the_inference.md \
  --from markdown \
  --to html5 \
  --template templates/novel.html \
  --section-divs \
  --no-highlight \
  --metadata title="The Inference" \
  --output site/read/index.html

echo "  Generated site/read/index.html"

# Generate styled PDF via Pandoc + WeasyPrint
pandoc the_inference.md \
  --from markdown \
  --to html5 \
  --template templates/pdf.html \
  --section-divs \
  --no-highlight \
  --metadata title="The Inference" \
  --output /tmp/the_inference_print.html

$PYTHON -c "
import weasyprint
doc = weasyprint.HTML(filename='/tmp/the_inference_print.html', base_url='$SCRIPT_DIR/')
doc.write_pdf('site/the_inference.pdf')
"

echo "  Generated site/the_inference.pdf"

# Copy templates and assets
cp templates/landing.html site/index.html
cp templates/discuss.html site/discuss/index.html
cp css/style.css site/css/style.css

# Copy assets if they exist
[ -f assets/favicon.ico ] && cp assets/favicon.ico site/favicon.ico
[ -f assets/og-image.png ] && cp assets/og-image.png site/og-image.png
[ -f assets/robots.txt ] && cp assets/robots.txt site/robots.txt

echo "  Copied static assets"

# Validation
echo ""
echo "Validating build output..."
FAILED=0
for f in site/index.html site/read/index.html site/discuss/index.html site/css/style.css site/the_inference.pdf; do
  if [ -f "$f" ]; then
    SIZE=$(wc -c < "$f" | tr -d ' ')
    echo "  OK: $f (${SIZE} bytes)"
  else
    echo "  MISSING: $f"
    FAILED=1
  fi
done

if [ "$FAILED" -eq 1 ]; then
  echo ""
  echo "Build failed: missing files."
  exit 1
fi

echo ""
echo "Build complete. Output in site/"
echo "Preview locally with: python3 -m http.server -d site 8000"
