#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Check dependencies
command -v pandoc >/dev/null 2>&1 || { echo "Error: pandoc is required. Install with: brew install pandoc"; exit 1; }

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

# Copy templates and assets
cp templates/landing.html site/index.html
cp templates/discuss.html site/discuss/index.html
cp css/style.css site/css/style.css
cp the_inference.pdf site/the_inference.pdf

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
