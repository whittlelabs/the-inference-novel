#!/bin/bash
set -euo pipefail

BUCKET="s3://theinferencenovel.com"
DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID:?Set CLOUDFRONT_DISTRIBUTION_ID environment variable}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$SCRIPT_DIR/site"

if [ ! -d "$SITE_DIR" ]; then
  echo "Error: site/ directory not found. Run build.sh first."
  exit 1
fi

echo "Deploying to $BUCKET..."

# Sync static assets with long cache
aws s3 sync "$SITE_DIR" "$BUCKET" \
  --delete \
  --cache-control "max-age=86400" \
  --exclude "*.html" \
  --exclude "robots.txt"

# Sync HTML and robots.txt with no-cache for immediate updates
aws s3 sync "$SITE_DIR" "$BUCKET" \
  --cache-control "no-cache, must-revalidate" \
  --exclude "*" \
  --include "*.html" \
  --include "robots.txt"

echo "  Files synced to S3"

# Invalidate CloudFront cache
echo "  Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text)

echo "  Invalidation created: $INVALIDATION_ID"

# Validation
echo ""
echo "Waiting for DNS/CDN propagation..."
sleep 10

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://theinferencenovel.com 2>/dev/null || echo "000")
if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "Deploy successful. https://theinferencenovel.com returns HTTP 200."
else
  echo "WARNING: Site returns HTTP $HTTP_STATUS. This may be expected if DNS hasn't propagated yet."
  echo "Check: https://theinferencenovel.com"
fi
