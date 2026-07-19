<#
================================================================================
  Alhasa Palm Project (Tamimi) - HSE File Organization System
  Auto-Build Folder Structure Script
================================================================================
  WHAT THIS DOES
    Creates the full coded folder tree for your HSE project in seconds, drops a
    short "_ABOUT.txt" note inside each main folder, and leaves your existing
    files untouched. Run it once, then drag your current files into the matching
    coded folders.

  HOW TO RUN  (choose ONE)
    A) Easiest: right-click this file  ->  "Run with PowerShell"
    B) Or open PowerShell in the target folder and run:
           powershell -ExecutionPolicy Bypass -File .\Build-AlhasaPalmFolders.ps1

  WHERE IT BUILDS
    By default it builds INTO the folder this script is sitting in.
    To build somewhere specific, edit $TargetRoot below, e.g.:
       $TargetRoot = "C:\Users\malshehri\OneDrive - DAN COMPANY\Desktop\Alhasa Palm Project-Tamimi"

  SAFE TO RE-RUN: it never deletes or overwrites; it only adds missing folders.
================================================================================
#>

# ---- CONFIG -----------------------------------------------------------------
# Leave blank to build in the script's own folder, or set an explicit path.
$TargetRoot = ""
# -----------------------------------------------------------------------------

if ([string]::IsNullOrWhiteSpace($TargetRoot)) {
    $TargetRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor DarkCyan
Write-Host "  Alhasa Palm Project (Tamimi) - HSE File System Builder" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor DarkCyan
Write-Host "  Building into:" -ForegroundColor Gray
Write-Host "  $TargetRoot" -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path -LiteralPath $TargetRoot)) {
    Write-Host "  Target path does not exist. Creating it..." -ForegroundColor DarkYellow
    New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null
}

# ---- FOLDER MAP -------------------------------------------------------------
# Each top folder = "NN_CODE_Name" ; children are the sub-folders.
# The NN number sorts them; the CODE is what you use in file names.
$structure = [ordered]@{
    "00_PM_Project-Management" = @(
        "00-01_Project-Charter-and-Scope",
        "00-02_Contracts-and-Agreements",
        "00-03_Correspondence-Letters",
        "00-04_Meeting-Minutes",
        "00-05_Organization-and-Roster",
        "00-06_Mobilization"
    )
    "10_HSE_Plans-and-Procedures" = @(
        "10-01_HSE-Plan",
        "10-02_Method-Statements",
        "10-03_Risk-Assessments-and-JSA",
        "10-04_Emergency-Response-Plan",
        "10-05_HSE-Policies-and-Objectives",
        "10-06_Environmental-Waste"
    )
    "20_PTW_Permits-to-Work" = @(
        "20-01_Hot-Work",
        "20-02_Cold-Work-General",
        "20-03_Confined-Space",
        "20-04_Excavation",
        "20-05_Work-at-Height",
        "20-06_Electrical-and-LOTO",
        "20-07_Lifting-Operations"
    )
    "30_INC_Incidents-and-Investigations" = @(
        "30-01_Incident-Reports",
        "30-02_Investigations-and-RCA",
        "30-03_Near-Miss",
        "30-04_First-Aid-Cases",
        "30-05_Lessons-Learned",
        "30-06_Statistics-LTI-TRIR"
    )
    "40_OBS_Observations-and-Inspections" = @(
        "40-01_Safety-Observations",
        "40-02_Site-Inspections",
        "40-03_Audits-Internal-External",
        "40-04_Corrective-Actions-CAPA",
        "40-05_Non-Conformance-NCR"
    )
    "50_TRN_Training-and-Competency" = @(
        "50-01_Training-Records",
        "50-02_Competency-Certificates",
        "50-03_Site-Inductions",
        "50-04_Toolbox-Talks",
        "50-05_Training-Matrix"
    )
    "60_CRT_Certificates-and-Equipment" = @(
        "60-01_Equipment-Certificates",
        "60-02_Third-Party-Inspections",
        "60-03_Calibration-Records",
        "60-04_Lifting-Gear-Register",
        "60-05_Vehicle-and-Plant"
    )
    "70_RPT_Reports-and-Statistics" = @(
        "70-01_Daily-Reports",
        "70-02_Weekly-Reports",
        "70-03_Monthly-HSE-Reports",
        "70-04_KPI-and-Dashboard-Exports",
        "70-05_Man-Hours-Log"
    )
    "80_MED_Site-Media" = @(
        "80-01_Site-Photos-General",
        "80-02_Incident-Photos",
        "80-03_Progress-Photos",
        "80-04_Observation-Photos",
        "80-05_Videos"
    )
    "90_DWG_Drawings-and-Reference" = @(
        "90-01_Site-Layout-and-Maps",
        "90-02_As-Built",
        "90-03_Reference-Standards",
        "90-04_Vendor-Data-Sheets-MSDS"
    )
    "99_ARC_Archive-Superseded" = @(
        "99-01_Superseded-Revisions",
        "99-02_Closed-Records",
        "99-03_Old-Backups"
    )
}

# Short note dropped into each top folder to guide users.
$notes = @{
    "00_PM_Project-Management"              = "CODE = PM  | Project setup, contracts, correspondence, meeting minutes, org charts."
    "10_HSE_Plans-and-Procedures"           = "CODE = HSE | HSE plan, method statements, risk assessments/JSA, emergency response."
    "20_PTW_Permits-to-Work"                = "CODE = PTW | All work permits sorted by permit type. One sub-folder per permit type."
    "30_INC_Incidents-and-Investigations"   = "CODE = INC | Incidents, investigations/RCA, near-miss, first-aid, lessons learned, stats."
    "40_OBS_Observations-and-Inspections"   = "CODE = OBS | Safety observations, inspections, audits, corrective actions (CAPA), NCRs."
    "50_TRN_Training-and-Competency"        = "CODE = TRN | Training records, competency certs, inductions, toolbox talks, matrix."
    "60_CRT_Certificates-and-Equipment"     = "CODE = CRT | Equipment/third-party certs, calibration, lifting gear, plant & vehicles."
    "70_RPT_Reports-and-Statistics"         = "CODE = RPT | Daily/weekly/monthly reports, KPIs, dashboard exports, man-hours."
    "80_MED_Site-Media"                     = "CODE = MED | Photos and videos. Name photos with the record they belong to."
    "90_DWG_Drawings-and-Reference"         = "CODE = DWG | Layouts, as-built, reference standards, MSDS/vendor data."
    "99_ARC_Archive-Superseded"             = "CODE = ARC | Superseded revisions and closed records. Never delete - move here."
}

$namingHelp = @"
--------------------------------------------------------------------
  FILE NAMING RULE (use for every file you drop into this project)
--------------------------------------------------------------------
  APP-[CAT]-[TYPE]-[NNN]-[YYYYMMDD]-[REV]_Short-Description.ext

  APP   = project (Alhasa Palm Project)
  CAT   = folder code (PM, HSE, PTW, INC, OBS, TRN, CRT, RPT, MED, DWG, ARC)
  TYPE  = document type (RPT report, FRM form, CHK checklist, PMT permit,
          CERT certificate, MOM minutes, LTR letter, RA risk assessment,
          MS method statement, INV investigation, PHO photo, LOG register,
          PLN plan, PRO procedure, TBT toolbox talk, AUD audit)
  NNN   = running number within that type (001, 002, ...)
  YYYYMMDD = document date        REV = revision (R0, R1, R2 ...)

  EXAMPLES
  APP-INC-INV-001-20260715-R0_Scaffold-Fall-NearMiss.pdf
  APP-PTW-PMT-045-20260718-R0_HotWork-ZoneB.pdf
  APP-OBS-RPT-012-20260719-R0_Unsafe-Housekeeping-GateA.xlsx
  APP-RPT-RPT-006-20260701-R1_Monthly-HSE-Report-Jun2026.pdf

  Keep the description short, use hyphens (no spaces), keep the .ext.
--------------------------------------------------------------------
"@

# ---- BUILD ------------------------------------------------------------------
$created = 0
$existed = 0

foreach ($top in $structure.Keys) {
    $topPath = Join-Path $TargetRoot $top
    if (Test-Path -LiteralPath $topPath) { $existed++ } else {
        New-Item -ItemType Directory -Path $topPath -Force | Out-Null
        $created++
    }
    Write-Host ("  [{0}]" -f $top) -ForegroundColor Green

    foreach ($sub in $structure[$top]) {
        $subPath = Join-Path $topPath $sub
        if (Test-Path -LiteralPath $subPath) { $existed++ } else {
            New-Item -ItemType Directory -Path $subPath -Force | Out-Null
            $created++
        }
        Write-Host ("      - {0}" -f $sub) -ForegroundColor DarkGray
    }

    # Drop the _ABOUT note (only if missing)
    $aboutPath = Join-Path $topPath "_ABOUT-this-folder.txt"
    if (-not (Test-Path -LiteralPath $aboutPath)) {
        $body = $notes[$top] + "`r`n" + $namingHelp
        Set-Content -LiteralPath $aboutPath -Value $body -Encoding UTF8
    }
}

# Top-level readme
$rootReadme = Join-Path $TargetRoot "_START-HERE_File-System-Guide.txt"
if (-not (Test-Path -LiteralPath $rootReadme)) {
@"
ALHASA PALM PROJECT (TAMIMI) - HSE FILE ORGANIZATION SYSTEM
===========================================================

The numbered folders below hold every project document. The 2-3 letter CODE
in each folder name is what you put in your file names.

  00_PM   Project Management        50_TRN  Training & Competency
  10_HSE  Plans & Procedures        60_CRT  Certificates & Equipment
  20_PTW  Permits to Work           70_RPT  Reports & Statistics
  30_INC  Incidents & Investig.     80_MED  Site Media (photos/video)
  40_OBS  Observations & Inspect.   90_DWG  Drawings & Reference
                                    99_ARC  Archive / Superseded

$namingHelp

TIP: Never delete an old file - move it to 99_ARC. Log every controlled
document in the Excel File Register that came with this system.
"@ | Set-Content -LiteralPath $rootReadme -Encoding UTF8
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor DarkCyan
Write-Host ("  Done.  New folders created: {0}   Already existed: {1}" -f $created, $existed) -ForegroundColor Cyan
Write-Host "  Open _START-HERE_File-System-Guide.txt for the naming rule." -ForegroundColor Gray
Write-Host "==============================================================" -ForegroundColor DarkCyan
Write-Host ""
