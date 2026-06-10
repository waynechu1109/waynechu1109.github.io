# waynechu1109.github.io

Personal website for Wei-Teng (Wayne) Chu, hosted on GitHub Pages.

## Local Preview

### Prerequisites

- Ruby (comes with macOS; check with `ruby --version`)
- Jekyll 4 (`gem install jekyll bundler` if not installed)

Verify Jekyll is available:

```bash
jekyll --version
```

### Serve the Site

```bash
jekyll serve
```

Then open [http://localhost:4000](http://localhost:4000) in your browser.

Jekyll will watch for file changes and rebuild automatically. Refresh the browser to see updates.

### Build Only (no server)

```bash
jekyll build
```

Output is written to `_site/`. You can open those files directly in a browser, but relative paths may not resolve correctly without a server.

### Useful Flags

| Flag | Effect |
|------|--------|
| `--livereload` | Auto-refresh browser on file save |
| `--drafts` | Include draft posts |
| `--port 5000` | Use a different port (default: 4000) |

Example with live reload:

```bash
jekyll serve --livereload
```

## Site Structure

```
.
├── index.html                  # Home / About page
├── aviation_photography.html   # Aviation photography gallery
├── course_projects.html        # Course projects listing
├── _layouts/
│   └── default.html            # Shared HTML layout (nav, footer)
├── _includes/
│   ├── lightbox_script.html    # Lightbox JS for photo gallery
│   ├── styles_index.html       # Page-specific styles for index
│   ├── styles_aviation.html    # Page-specific styles for aviation
│   └── styles_course_projects.html
├── css/
│   └── style.css               # Shared stylesheet
└── media/                      # Images and other assets
```

## Deployment

Pushing to the `main` branch automatically deploys to [https://waynechu1109.github.io](https://waynechu1109.github.io) via GitHub Pages.
