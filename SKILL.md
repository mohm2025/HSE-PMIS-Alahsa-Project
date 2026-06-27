---
name: hse-pmis-dashboard
description: Work with the SafeSite PMIS — HSE Performance System dashboard (index.html.html). Use when adding, editing, or styling KPI cards, charts, tables, navigation tabs, or export controls in this single-file HSE (Health, Safety & Environment) project management information system.
---

# HSE PMIS Dashboard

This repository hosts **SafeSite PMIS**, a self-contained HSE (Health, Safety &
Environment) Performance System dashboard for the Al-Ahsa project. The entire
application — markup, styles, and behavior — lives in `index.html.html`.

## Layout

The page is structured top-to-bottom as:

- **Topbar** (`.topbar`) — logo, site badge, and sync status.
- **Config bar** (`.config-bar`) — data-source input and load button.
- **Export bar** (`.export-bar`) — Excel (`.btn-exp.xl`) and CSV (`.btn-exp.csv`) export buttons.
- **Nav tabs** (`.nav-tabs` / `.nav-tab`) — switch between sections; the active tab gets `.active`.
- **Main** (`.main`) — holds the sections (`.sec`); only `.sec.active` is visible.

## Conventions

- **Theming** uses CSS custom properties defined in `:root` (e.g. `--or` orange,
  `--gr` green, `--re` red, `--am` amber, `--bl` blue), with a
  `prefers-color-scheme: dark` override. Reuse these variables instead of
  hardcoding colors.
- **KPI cards** (`.kpi`) take a state modifier: `.danger`, `.warning`,
  `.success`, or `.info`, which sets the left border color.
- **Charts** sit in `.chart-card` inside a two-column `.chart-row`.
- **Tables** are wrapped in `.tbl-wrap` with a `.tbl-hdr` header.
- Fonts: `system-ui` for body text, `monospace` for labels, codes, and badges.

## Editing guidance

- Keep everything in the single `index.html.html` file unless asked to split it.
- Match the existing compact CSS style (minified, semicolon-separated rules).
- When adding a section, give it a `.sec` container and a matching `.nav-tab`,
  and wire the tab to toggle the `.active` class.
- Preserve the dark-mode variable overrides when introducing new colors.
