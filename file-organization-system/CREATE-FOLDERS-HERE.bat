@echo off
REM ============================================================
REM  Alhasa Palm Project (Tamimi) - HSE Folder Builder
REM  Self-contained. No PowerShell, no other files needed.
REM  Put this file in your project folder and double-click it.
REM  It builds the folders right where this file sits.
REM ============================================================
setlocal
cd /d "%~dp0"
echo.
echo  Building Alhasa Palm HSE folder structure...
echo.
echo   00_PM_Project-Management
md "00_PM_Project-Management\00-01_Project-Charter-and-Scope" 2>nul
md "00_PM_Project-Management\00-02_Contracts-and-Agreements" 2>nul
md "00_PM_Project-Management\00-03_Correspondence-Letters" 2>nul
md "00_PM_Project-Management\00-04_Meeting-Minutes" 2>nul
md "00_PM_Project-Management\00-05_Organization-and-Roster" 2>nul
md "00_PM_Project-Management\00-06_Mobilization" 2>nul
echo   10_HSE_Plans-and-Procedures
md "10_HSE_Plans-and-Procedures\10-01_HSE-Plan" 2>nul
md "10_HSE_Plans-and-Procedures\10-02_Method-Statements" 2>nul
md "10_HSE_Plans-and-Procedures\10-03_Risk-Assessments-and-JSA" 2>nul
md "10_HSE_Plans-and-Procedures\10-04_Emergency-Response-Plan" 2>nul
md "10_HSE_Plans-and-Procedures\10-05_HSE-Policies-and-Objectives" 2>nul
md "10_HSE_Plans-and-Procedures\10-06_Environmental-Waste" 2>nul
echo   20_PTW_Permits-to-Work
md "20_PTW_Permits-to-Work\20-01_Hot-Work" 2>nul
md "20_PTW_Permits-to-Work\20-02_Cold-Work-General" 2>nul
md "20_PTW_Permits-to-Work\20-03_Confined-Space" 2>nul
md "20_PTW_Permits-to-Work\20-04_Excavation" 2>nul
md "20_PTW_Permits-to-Work\20-05_Work-at-Height" 2>nul
md "20_PTW_Permits-to-Work\20-06_Electrical-and-LOTO" 2>nul
md "20_PTW_Permits-to-Work\20-07_Lifting-Operations" 2>nul
echo   30_INC_Incidents-and-Investigations
md "30_INC_Incidents-and-Investigations\30-01_Incident-Reports" 2>nul
md "30_INC_Incidents-and-Investigations\30-02_Investigations-and-RCA" 2>nul
md "30_INC_Incidents-and-Investigations\30-03_Near-Miss" 2>nul
md "30_INC_Incidents-and-Investigations\30-04_First-Aid-Cases" 2>nul
md "30_INC_Incidents-and-Investigations\30-05_Lessons-Learned" 2>nul
md "30_INC_Incidents-and-Investigations\30-06_Statistics-LTI-TRIR" 2>nul
echo   40_OBS_Observations-and-Inspections
md "40_OBS_Observations-and-Inspections\40-01_Safety-Observations" 2>nul
md "40_OBS_Observations-and-Inspections\40-02_Site-Inspections" 2>nul
md "40_OBS_Observations-and-Inspections\40-03_Audits-Internal-External" 2>nul
md "40_OBS_Observations-and-Inspections\40-04_Corrective-Actions-CAPA" 2>nul
md "40_OBS_Observations-and-Inspections\40-05_Non-Conformance-NCR" 2>nul
echo   50_TRN_Training-and-Competency
md "50_TRN_Training-and-Competency\50-01_Training-Records" 2>nul
md "50_TRN_Training-and-Competency\50-02_Competency-Certificates" 2>nul
md "50_TRN_Training-and-Competency\50-03_Site-Inductions" 2>nul
md "50_TRN_Training-and-Competency\50-04_Toolbox-Talks" 2>nul
md "50_TRN_Training-and-Competency\50-05_Training-Matrix" 2>nul
echo   60_CRT_Certificates-and-Equipment
md "60_CRT_Certificates-and-Equipment\60-01_Equipment-Certificates" 2>nul
md "60_CRT_Certificates-and-Equipment\60-02_Third-Party-Inspections" 2>nul
md "60_CRT_Certificates-and-Equipment\60-03_Calibration-Records" 2>nul
md "60_CRT_Certificates-and-Equipment\60-04_Lifting-Gear-Register" 2>nul
md "60_CRT_Certificates-and-Equipment\60-05_Vehicle-and-Plant" 2>nul
echo   70_RPT_Reports-and-Statistics
md "70_RPT_Reports-and-Statistics\70-01_Daily-Reports" 2>nul
md "70_RPT_Reports-and-Statistics\70-02_Weekly-Reports" 2>nul
md "70_RPT_Reports-and-Statistics\70-03_Monthly-HSE-Reports" 2>nul
md "70_RPT_Reports-and-Statistics\70-04_KPI-and-Dashboard-Exports" 2>nul
md "70_RPT_Reports-and-Statistics\70-05_Man-Hours-Log" 2>nul
echo   80_MED_Site-Media
md "80_MED_Site-Media\80-01_Site-Photos-General" 2>nul
md "80_MED_Site-Media\80-02_Incident-Photos" 2>nul
md "80_MED_Site-Media\80-03_Progress-Photos" 2>nul
md "80_MED_Site-Media\80-04_Observation-Photos" 2>nul
md "80_MED_Site-Media\80-05_Videos" 2>nul
echo   90_DWG_Drawings-and-Reference
md "90_DWG_Drawings-and-Reference\90-01_Site-Layout-and-Maps" 2>nul
md "90_DWG_Drawings-and-Reference\90-02_As-Built" 2>nul
md "90_DWG_Drawings-and-Reference\90-03_Reference-Standards" 2>nul
md "90_DWG_Drawings-and-Reference\90-04_Vendor-Data-Sheets-MSDS" 2>nul
echo   99_ARC_Archive-Superseded
md "99_ARC_Archive-Superseded\99-01_Superseded-Revisions" 2>nul
md "99_ARC_Archive-Superseded\99-02_Closed-Records" 2>nul
md "99_ARC_Archive-Superseded\99-03_Old-Backups" 2>nul
echo.
echo  DONE. Folders created in this folder:
echo    %~dp0
echo.
start "" "%~dp0"
echo  Press any key to close this window.
pause >nul
