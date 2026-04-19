# HSE PMIS - Al-Ahsa Project

**SafeSite PMIS** — Health, Safety, Security & Environment Performance Management System for construction/industrial sites.

## Live Demo
Deployed on Netlify — see repository settings for URL.

## Features

- **Authentication** — Login with user accounts (admin, samer, manager, inspectors), password reset, change password
- **Observations** — Log, edit, close unsafe acts, near misses, PPE violations, etc.
- **NCR Register** — Non-Conformance Reports with severity tracking, closure %, root cause
- **Photos** — Separate **OPEN/Finding** photos (blue) and **CLOSEOUT** photos (green) with lightbox
- **Analytics** — Charts for category, status, priority, severity, closure rate, trends
- **Export** — Excel (.xlsx), CSV, Print-friendly
- **Email Alerts** — Auto-notification of overdue items; one-click email report
- **Google Sheets** — Optional integration via Apps Script webhook
- **Offline Mode** — All data persists in localStorage

## Running Locally

Just open `index.html` in any modern browser — no build step required.

```bash
# Or run a local server:
python -m http.server 8000
# Then open http://localhost:8000/
```

## Default Login Credentials

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | Admin |
| samer | samer123 | Manager |
| ahmed | ahmed123 | Inspector |
| sara | sara123 | Inspector |

## Deployment

The repo is configured for Netlify static hosting via `netlify.toml`. Just connect the GitHub repo to Netlify and it deploys automatically.

Both `/` and `/index.html.html` serve the same app (legacy URL support).

## Structure

```
.
├── index.html          # Main app (use this)
├── index.html.html     # Legacy duplicate for backward compatibility
├── netlify.toml        # Netlify config
├── README.md           # This file
└── .gitignore
```
