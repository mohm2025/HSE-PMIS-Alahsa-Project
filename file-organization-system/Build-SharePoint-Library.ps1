<#
================================================================================
  Alhasa Palm Project (Tamimi) - HSE File Organization System
  SharePoint Online / OneDrive-for-Business version
  Provisions the SAME coded folder tree directly inside a document library
================================================================================

  WHICH VERSION DO I NEED?

    * If your "Alhasa Palm Project-Tamimi" folder is a SYNCED OneDrive/SharePoint
      folder on your PC (the usual case), you do NOT need this script.
      Just run Build-AlhasaPalmFolders.ps1 (or RUN-ME_Build-Folders.bat) inside
      that folder - the folders you create sync up to the cloud automatically.

    * Use THIS script only when you want to build the structure straight into a
      SharePoint document library on the server (no local sync needed), e.g. a
      shared Project / HSE team site that the whole team opens in the browser.

  ----------------------------------------------------------------------------
  ONE-TIME SETUP (run once per PC)
    1) Open PowerShell and install the PnP module:
           Install-Module PnP.PowerShell -Scope CurrentUser
       (If your tenant blocks it, ask IT to approve "PnP.PowerShell".)

  RUN
    1) Edit the two settings in the CONFIG block below (site URL + library).
    2) Right-click this file -> Run with PowerShell, or:
           powershell -ExecutionPolicy Bypass -File .\Build-SharePoint-Library.ps1
    3) Sign in with your work account when the browser prompts.

  SAFE TO RE-RUN: it skips folders that already exist and never deletes anything.
================================================================================
#>

# ---- CONFIG -----------------------------------------------------------------
# Your SharePoint site (team site or project site). Examples:
#   https://tamimi.sharepoint.com/sites/AlhasaPalmProject
#   https://<tenant>.sharepoint.com/sites/<YourSite>
$SiteUrl = "https://<tenant>.sharepoint.com/sites/<YourSite>"

# The document library to build into. "Documents" is the default library that
# every site has (its internal name is "Shared Documents").
$LibraryName = "Documents"

# Optional top folder created inside the library to hold everything.
# Leave "" to build the categories at the library root.
$RootFolder = "Alhasa Palm Project-Tamimi"
# -----------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# ---- FOLDER MAP (identical codes to the local/Windows version) --------------
$structure = [ordered]@{
    "00_PM_Project-Management" = @(
        "00-01_Project-Charter-and-Scope","00-02_Contracts-and-Agreements",
        "00-03_Correspondence-Letters","00-04_Meeting-Minutes",
        "00-05_Organization-and-Roster","00-06_Mobilization")
    "10_HSE_Plans-and-Procedures" = @(
        "10-01_HSE-Plan","10-02_Method-Statements","10-03_Risk-Assessments-and-JSA",
        "10-04_Emergency-Response-Plan","10-05_HSE-Policies-and-Objectives",
        "10-06_Environmental-Waste")
    "20_PTW_Permits-to-Work" = @(
        "20-01_Hot-Work","20-02_Cold-Work-General","20-03_Confined-Space",
        "20-04_Excavation","20-05_Work-at-Height","20-06_Electrical-and-LOTO",
        "20-07_Lifting-Operations")
    "30_INC_Incidents-and-Investigations" = @(
        "30-01_Incident-Reports","30-02_Investigations-and-RCA","30-03_Near-Miss",
        "30-04_First-Aid-Cases","30-05_Lessons-Learned","30-06_Statistics-LTI-TRIR")
    "40_OBS_Observations-and-Inspections" = @(
        "40-01_Safety-Observations","40-02_Site-Inspections",
        "40-03_Audits-Internal-External","40-04_Corrective-Actions-CAPA",
        "40-05_Non-Conformance-NCR")
    "50_TRN_Training-and-Competency" = @(
        "50-01_Training-Records","50-02_Competency-Certificates",
        "50-03_Site-Inductions","50-04_Toolbox-Talks","50-05_Training-Matrix")
    "60_CRT_Certificates-and-Equipment" = @(
        "60-01_Equipment-Certificates","60-02_Third-Party-Inspections",
        "60-03_Calibration-Records","60-04_Lifting-Gear-Register","60-05_Vehicle-and-Plant")
    "70_RPT_Reports-and-Statistics" = @(
        "70-01_Daily-Reports","70-02_Weekly-Reports","70-03_Monthly-HSE-Reports",
        "70-04_KPI-and-Dashboard-Exports","70-05_Man-Hours-Log")
    "80_MED_Site-Media" = @(
        "80-01_Site-Photos-General","80-02_Incident-Photos","80-03_Progress-Photos",
        "80-04_Observation-Photos","80-05_Videos")
    "90_DWG_Drawings-and-Reference" = @(
        "90-01_Site-Layout-and-Maps","90-02_As-Built","90-03_Reference-Standards",
        "90-04_Vendor-Data-Sheets-MSDS")
    "99_ARC_Archive-Superseded" = @(
        "99-01_Superseded-Revisions","99-02_Closed-Records","99-03_Old-Backups")
}

# ---- VALIDATE CONFIG --------------------------------------------------------
if ($SiteUrl -like "*<tenant>*" -or $SiteUrl -like "*<YourSite>*") {
    Write-Host "  STOP: edit `$SiteUrl in the CONFIG block first (your real site URL)." -ForegroundColor Red
    return
}
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "  PnP.PowerShell is not installed. Run this once, then re-run:" -ForegroundColor Red
    Write-Host "      Install-Module PnP.PowerShell -Scope CurrentUser" -ForegroundColor Yellow
    return
}

Import-Module PnP.PowerShell

Write-Host ""
Write-Host "==============================================================" -ForegroundColor DarkCyan
Write-Host "  Building HSE folder tree in SharePoint" -ForegroundColor Cyan
Write-Host "  Site:    $SiteUrl" -ForegroundColor Gray
Write-Host "  Library: $LibraryName" -ForegroundColor Gray
Write-Host "==============================================================" -ForegroundColor DarkCyan

# Sign in (interactive browser login)
Connect-PnPOnline -Url $SiteUrl -Interactive

# Note: Resolve-PnPFolder creates the folder (and any missing parents) if it does
# not exist and simply returns it if it does - so it is idempotent by itself.

# The library's server-relative root (Documents -> "Shared Documents")
$libFolder = Get-PnPList -Identity $LibraryName | Select-Object -ExpandProperty RootFolder
$libServerRel = (Get-PnPProperty -ClientObject $libFolder -Property ServerRelativeUrl)
$siteRel = $libServerRel.Substring((Get-PnPWeb).ServerRelativeUrl.Length).TrimStart('/')

function SiteRel([string]$sub) {
    if ([string]::IsNullOrWhiteSpace($sub)) { return $siteRel }
    return "$siteRel/$sub"
}

$created = 0

# Optional root folder
$base = ""
if (-not [string]::IsNullOrWhiteSpace($RootFolder)) {
    Resolve-PnPFolder -SiteRelativePath (SiteRel $RootFolder) | Out-Null
    $base = $RootFolder
    Write-Host "  [root] $RootFolder" -ForegroundColor Green
}

foreach ($top in $structure.Keys) {
    $topRel = if ($base) { "$base/$top" } else { $top }
    Resolve-PnPFolder -SiteRelativePath (SiteRel $topRel) | Out-Null
    Write-Host "  [$top]" -ForegroundColor Green
    $created++
    foreach ($sub in $structure[$top]) {
        Resolve-PnPFolder -SiteRelativePath (SiteRel "$topRel/$sub") | Out-Null
        Write-Host "      - $sub" -ForegroundColor DarkGray
        $created++
    }
}

Disconnect-PnPOnline
Write-Host ""
Write-Host "==============================================================" -ForegroundColor DarkCyan
Write-Host "  Done. Folders ensured in the library (existing ones kept)." -ForegroundColor Cyan
Write-Host "  Open the site in your browser to see the structure." -ForegroundColor Gray
Write-Host "==============================================================" -ForegroundColor DarkCyan
