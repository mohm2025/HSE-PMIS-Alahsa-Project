@echo off
REM ================================================================
REM  Alhasa Palm Project (Tamimi) - Organize existing folders
REM  Moves each of your existing folders (whole) into the matching
REM  coded category folder. Shows a plan first; moves nothing until
REM  you type YES. Creates _UNDO-FOLDERS.bat to reverse everything.
REM ================================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Alhasa Palm - Organize folders into the code system
echo.
echo  These EXISTING folders will move into the coded folders:
echo  ------------------------------------------------------------
set "MODE=PLAN"
call :ALL
echo  ------------------------------------------------------------
echo.
echo  Nothing has moved yet.
set "CONF="
set /p "CONF=Type  YES  and press Enter to move them (or close to cancel): "
if /i not "!CONF!"=="YES" (
  echo  Cancelled. Nothing was moved.
  pause>nul
  goto :eof
)
> "_UNDO-FOLDERS.bat" echo @echo off
>> "_UNDO-FOLDERS.bat" echo REM Double-click to move every folder back to the main project folder.
>> "_UNDO-FOLDERS.bat" echo cd /d "%%~dp0"
set "MODE=MOVE"
echo.
call :ALL
echo.
echo  ============================================================
echo   DONE. Your folders are now inside the coded categories.
echo   To undo everything, double-click _UNDO-FOLDERS.bat
echo  ============================================================
start "" "%~dp0"
echo.
echo  Press any key to close.
pause>nul
goto :eof

:ALL
call :H "Al-Tamimi Contract" "00_PM_Project-Management"
call :H "PMC Contract" "00_PM_Project-Management"
call :H "PMC Folder" "00_PM_Project-Management"
call :H "Letters" "00_PM_Project-Management"
call :H "MOM" "00_PM_Project-Management"
call :H "HSSE Staff" "00_PM_Project-Management"
call :H "Visitor Log" "00_PM_Project-Management"
call :H "HSSE Plans" "10_HSE_Plans-and-Procedures"
call :H "CEMP" "10_HSE_Plans-and-Procedures"
call :H "Mehtod Of Statement" "10_HSE_Plans-and-Procedures"
call :H "Emergency" "10_HSE_Plans-and-Procedures"
call :H "Emergency Management" "10_HSE_Plans-and-Procedures"
call :H "PTWs" "20_PTW_Permits-to-Work"
call :H "Incident Log" "30_INC_Incidents-and-Investigations"
call :H "Clinic Log" "30_INC_Incidents-and-Investigations"
call :H "Audit Checklist" "40_OBS_Observations-and-Inspections"
call :H "NCRs" "40_OBS_Observations-and-Inspections"
call :H "Daily Observation Report" "40_OBS_Observations-and-Inspections"
call :H "Site visit Observations" "40_OBS_Observations-and-Inspections"
call :H "TBTs Records" "50_TRN_Training-and-Competency"
call :H "Training records" "50_TRN_Training-and-Competency"
call :H "Certificate of Appreciation 500K" "50_TRN_Training-and-Competency"
call :H "Safety Data-operators-equipment" "60_CRT_Certificates-and-Equipment"
call :H "Equipment log" "60_CRT_Certificates-and-Equipment"
call :H "Manpower logs" "70_RPT_Reports-and-Statistics"
call :H "Weekly Statistic Report" "70_RPT_Reports-and-Statistics"
call :H "PCI & KPI" "70_RPT_Reports-and-Statistics"
exit /b

:H
set "SRC=%~1"
set "DST=%~2"
if not exist "!SRC!\" exit /b
if "!MODE!"=="PLAN" (
  echo     !SRC!    into    !DST!
  exit /b
)
if not exist "!DST!\" md "!DST!"
move "!SRC!" "!DST!" >nul 2>&1 && (
  >> "_UNDO-FOLDERS.bat" echo move "!DST!\!SRC!" "%%~dp0" ^>nul 2^>^&1
  echo     moved:  !SRC!
) || (
  echo     SKIPPED (already there?):  !SRC!
)
exit /b
