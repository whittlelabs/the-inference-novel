# The Inference

A novel about a software engineer named Sean Milton, written entirely by Claude Opus 4.6.

**Read it at [theinferencenovel.com](https://theinferencenovel.com)**

## About

*The Inference* is a ~19,000-word novel in five parts. It follows Sean Milton, a software engineer with twenty-five years of experience, as the world around him begins to mirror his internal state in ways that defy coincidence. The authorship is transparent — this is an AI-written novel published as an experiment in what that means.

## Project structure

```
the_inference.md        # Novel source (Markdown)
the_inference.pdf       # Pre-built styled PDF
templates/
  novel.html            # Pandoc template for the reading page
  landing.html          # Landing page
  discuss.html          # Giscus discussion page
  pdf.html              # Pandoc template for PDF generation
css/
  style.css             # Web stylesheet (dark/light mode)
  print.css             # PDF stylesheet (6×9 trim)
assets/
  og-image.png          # Open Graph image
  favicon.ico           # Multi-size favicon
  robots.txt
build.sh                # Build script (Pandoc + optional WeasyPrint)
deploy.sh               # Manual deploy to S3 + CloudFront invalidation
.github/workflows/
  deploy.yml            # CI/CD: build → S3 → CloudFront on push to main
```

## Building locally

Requires [Pandoc](https://pandoc.org/).

```sh
brew install pandoc   # macOS
bash build.sh
```

Preview at `http://localhost:8000`:

```sh
python3 -m http.server -d site 8000
```

### Regenerating the PDF

The pre-built PDF is committed to the repo and used by CI. To regenerate it locally:

```sh
python3 -m venv .venv
.venv/bin/pip install weasyprint
bash build.sh
cp site/the_inference.pdf the_inference.pdf
```

## Deployment

Pushes to `main` trigger a GitHub Actions workflow that builds the site, syncs to S3, and invalidates the CloudFront cache.

For manual deploys:

```sh
export CLOUDFRONT_DISTRIBUTION_ID=E3U1WEH0YC3SQB
bash deploy.sh
```

## Discussion

Feedback and discussion happen via [GitHub Discussions](https://github.com/whittlelabs/the-inference-novel/discussions), embedded on the site through [Giscus](https://giscus.app/).

## License

This work is licensed under [Creative Commons Attribution-NonCommercial 4.0 International](https://creativecommons.org/licenses/by-nc/4.0/).

You are free to share and adapt this work for non-commercial purposes, with appropriate credit.
