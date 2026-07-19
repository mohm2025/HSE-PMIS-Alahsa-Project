# Alhasa Palm Project (Tamimi) — HSE File Organization System

A complete, ready-to-use system for organizing every HSE file on the Alhasa Palm
Project into a coded folder tree that anyone can navigate in seconds. The folder
**codes** match the SafeSite PMIS dashboard tabs (Incidents, Observations,
Permits, Training…), so the files on disk line up with the system you already use.

## What's in this folder

| File | What it does |
|------|--------------|
| **`Build-AlhasaPalmFolders.ps1`** | PowerShell script that builds the full coded folder tree **on your PC / in a synced OneDrive folder**. Safe to re-run — only adds missing folders, never deletes. |
| **`RUN-ME_Build-Folders.bat`** | Double-click launcher for the script (for PCs where right-click → *Run with PowerShell* is blocked). |
| **`Build-SharePoint-Library.ps1`** | Cloud version — provisions the **same coded tree directly in a SharePoint Online / OneDrive-for-Business document library** (server-side, no local sync). Uses PnP PowerShell. |
| **`Alhasa-Palm-HSE-File-Organization-Guide.docx`** | Printable reference guide (open in Word; export to PDF with *File → Save as PDF*). |
| **`Alhasa-Palm-HSE-File-Register.xlsx`** | Master document log — one row per file, with dropdowns, an auto-count summary, and **11 starter template rows** (one per category) to copy from. |

## How to set it up (3 steps)

1. **Copy** `Build-AlhasaPalmFolders.ps1` and `RUN-ME_Build-Folders.bat` into your
   project folder, e.g.
   `C:\Users\malshehri\OneDrive - DAN COMPANY\Desktop\Alhasa Palm Project-Tamimi`.
2. **Double-click** `RUN-ME_Build-Folders.bat`. The full coded folder tree appears,
   with a short `_ABOUT` note inside each folder.
3. **Drag** your existing files into the matching coded folders, renaming each one
   with the naming rule below. Log controlled documents in the Excel register.

> Prefer to point the script at a specific path instead? Open the `.ps1`, set
> `$TargetRoot = "C:\...\Alhasa Palm Project-Tamimi"`, and run it.

## Cloud / shared-drive setup (OneDrive & SharePoint)

You have two ways to get the coded tree into the cloud — pick one:

- **Simplest (recommended): let OneDrive sync it.** If your `Alhasa Palm Project-Tamimi`
  folder is already a synced OneDrive/SharePoint folder on your PC, just run
  `Build-AlhasaPalmFolders.ps1` inside it. The folders you create sync up to the
  cloud automatically — nothing else to do.
- **Server-side (no sync): `Build-SharePoint-Library.ps1`.** Builds the same
  structure straight into a SharePoint document library (e.g. a shared HSE team
  site everyone opens in the browser). Needs the PnP PowerShell module once:
  `Install-Module PnP.PowerShell -Scope CurrentUser`, then set your site URL and
  library name at the top of the script and run it.

> Prefer Google Drive instead of SharePoint? The same folder codes work there too —
> ask and it can be built into your Drive directly.

## The coded folder structure

| Folder | Code | Contents |
|--------|------|----------|
| `00_PM`  | PM  | Project management — contracts, correspondence, minutes, org charts |
| `10_HSE` | HSE | HSE plan, method statements, risk assessments / JSA, emergency response |
| `20_PTW` | PTW | Permits to work, sorted by permit type |
| `30_INC` | INC | Incidents, investigations / RCA, near-miss, first-aid, lessons learned |
| `40_OBS` | OBS | Safety observations, inspections, audits, corrective actions (CAPA), NCR |
| `50_TRN` | TRN | Training records, competency certificates, inductions, toolbox talks |
| `60_CRT` | CRT | Equipment & third-party certificates, calibration, lifting gear, plant |
| `70_RPT` | RPT | Daily / weekly / monthly reports, KPIs, dashboard exports, man-hours |
| `80_MED` | MED | Site photos & videos |
| `90_DWG` | DWG | Layouts, as-built, reference standards, MSDS / vendor data |
| `99_ARC` | ARC | Archive — superseded revisions & closed records (never delete, move here) |

Each category also gets numbered sub-folders (e.g. `30_INC` → `30-01_Incident-Reports`,
`30-02_Investigations-and-RCA`, `30-03_Near-Miss`, …).

## The file-naming rule

```
APP-[CAT]-[TYPE]-[NNN]-[YYYYMMDD]-[REV]_Short-Description.ext
```

| Part | Meaning |
|------|---------|
| `APP` | Project prefix (Alhasa Palm Project) |
| `CAT` | Category code from the table above (`INC`, `PTW`, `OBS`…) |
| `TYPE` | Document type — `RPT` report, `FRM` form, `CHK` checklist, `PMT` permit, `CERT` certificate, `MOM` minutes, `LTR` letter, `RA` risk assessment, `MS` method statement, `INV` investigation, `PHO` photo, `LOG` register, `PLN` plan, `PRO` procedure, `TBT` toolbox talk, `AUD` audit |
| `NNN` | Running number within that type (`001`, `002`…) |
| `YYYYMMDD` | Document date (sorts chronologically on its own) |
| `REV` | Revision — `R0` first issue, then `R1`, `R2`… |
| `Description` | Short, hyphenated, no spaces |

**Examples**

```
APP-INC-INV-001-20260715-R0_Scaffold-Fall-NearMiss.pdf
APP-PTW-PMT-045-20260718-R0_HotWork-ZoneB.pdf
APP-OBS-RPT-012-20260719-R0_Unsafe-Housekeeping-GateA.xlsx
APP-RPT-RPT-006-20260701-R1_Monthly-HSE-Report-Jun2026.pdf
```

## Day-to-day rules

- **One file, one home** — don't duplicate across folders.
- **Name it before you file it.**
- **Never delete — archive** to `99_ARC`.
- **New version = new revision** (`R0` → `R1`).
- **Log controlled documents** in the Excel register.
- **Photos follow their record** — same number as the record they belong to, stored in `80_MED`.
