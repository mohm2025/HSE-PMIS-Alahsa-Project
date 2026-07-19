@echo off
REM ================================================================
REM  Alhasa Palm Project (Tamimi) - ORGANIZE NOW (final)
REM  Path is built-in. Sweeps loose security files at the top level
REM  AND inside folders into 15_SEC, then moves every folder into
REM  its coded category. Shows a plan; moves nothing until you type
REM  YES.  ***Do NOT run any _UNDO file unless you want to reverse.***
REM ================================================================
setlocal enabledelayedexpansion
set "ROOT=C:\Users\malshehri\OneDrive - DAN COMPANY\Desktop\Alhasa Palm Project-Tamimi"
if not exist "%ROOT%\" set "ROOT=%~dp0."
cd /d "%ROOT%"
set "UNDO=%ROOT%\_UNDO-FOLDERS.bat"
title Alhasa Palm - ORGANIZE NOW
echo.
echo  Working in: %ROOT%
echo.
echo  PLANNED MOVES (nothing has moved yet):
echo  ------------------------------------------------------------
set "MODE=PLAN"
set /a n=0
call :RUN
echo  ------------------------------------------------------------
if !n! EQU 0 (
  echo.
  echo  Could not find anything to move in the path above.
  echo  Make sure this file is in your project folder, then retry.
  echo.
  pause>nul
  goto :eof
)
echo.
echo  Total items to move: !n!
set "CONF="
set /p "CONF=Type  YES  and press Enter to organize (or close to cancel): "
if /i not "!CONF!"=="YES" (
  echo  Cancelled. Nothing was moved.
  pause>nul
  goto :eof
)
> "%UNDO%" echo @echo off
>> "%UNDO%" echo REM WARNING: this reverses the organize and returns items to the main folder.
>> "%UNDO%" echo cd /d "%%~dp0"
md "15_SEC_Security-and-Access\15-01_Security-Plans" 2>nul
md "15_SEC_Security-and-Access\15-02_Security-Incidents-Breaches" 2>nul
md "15_SEC_Security-and-Access\15-03_Visitor-and-Access-Logs" 2>nul
md "15_SEC_Security-and-Access\15-04_Security-Minutes" 2>nul
md "15_SEC_Security-and-Access\15-05_Guard-Force-and-Patrols" 2>nul
set "MODE=MOVE"
echo.
call :RUN
echo.
echo  ============================================================
echo   DONE. Everything is now in the coded folders (incl. 15_SEC).
echo   Your files are safe. Do NOT run _UNDO unless you want them
echo   moved back to the main folder.
echo  ============================================================
start "" "%ROOT%"
echo.
echo  Press any key to close.
pause>nul
goto :eof

:RUN
REM 1) loose security files sitting at the top level
for %%G in (*) do call :SECFILE "%%G"
REM 2) security files still inside these folders
call :SCANSEC "MOM"
call :SCANSEC "Letters"
call :SCANSEC "HSSE Plans"
call :SCANSEC "Mehtod Of Statement"
REM 3) move each existing folder into its coded category
call :ALL
REM 4) loose admin file
call :LOOSE "Interview Evaluation Form.xlsx" "00_PM_Project-Management"
exit /b

:ALL
call :H "Al-Tamimi Contract" "00_PM_Project-Management"
call :H "PMC Contract" "00_PM_Project-Management"
call :H "PMC Folder" "00_PM_Project-Management"
call :H "Letters" "00_PM_Project-Management"
call :H "MOM" "00_PM_Project-Management"
call :H "HSSE Staff" "00_PM_Project-Management"
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
call :H "Visitor Log" "15_SEC_Security-and-Access\15-03_Visitor-and-Access-Logs"
exit /b

:H
set "SRC=%~1"
set "DST=%~2"
if not exist "!SRC!\" exit /b
if "!MODE!"=="PLAN" (
  echo     [folder]  !SRC!   into   !DST!
  set /a n+=1
  exit /b
)
if not exist "!DST!\" md "!DST!"
move "!SRC!" "!DST!" >nul 2>&1 && (
  >> "%UNDO%" echo move "!DST!\!SRC!" "%%~dp0" ^>nul 2^>^&1
  echo     moved folder:  !SRC!
) || (
  echo     SKIPPED (already there?):  !SRC!
)
exit /b

:LOOSE
set "LF=%~1"
set "LD=%~2"
if not exist "!LF!" exit /b
if "!MODE!"=="PLAN" (
  echo     [file]  !LF!   into   !LD!
  set /a n+=1
  exit /b
)
if not exist "!LD!\" md "!LD!"
move "!LF!" "!LD!" >nul 2>&1 && (
  >> "%UNDO%" echo move "!LD!\!LF!" "%%~dp0" ^>nul 2^>^&1
  echo     moved file:  !LF!
) || (
  echo     SKIPPED file:  !LF!
)
exit /b

:SCANSEC
set "SF=%~1"
if not exist "!SF!\" exit /b
pushd "!SF!"
for %%G in (*) do call :SECFILE "%%G"
popd
exit /b

:SECFILE
set "GN=%~nx1"
set "EX=%~x1"
if /i "!EX!"==".bat" exit /b
if /i "!EX!"==".ps1" exit /b
if /i "!EX!"==".zip" exit /b
if /i "!GN:~0,1!"=="_" exit /b
set "isSec="
echo(!GN!| findstr /i /c:"security" >nul && set "isSec=1"
echo(!GN!| findstr /i /c:"breach" >nul && set "isSec=1"
if not defined isSec exit /b
set "SDEST=%ROOT%\15_SEC_Security-and-Access\15-01_Security-Plans"
echo(!GN!| findstr /i /c:"breach" >nul && set "SDEST=%ROOT%\15_SEC_Security-and-Access\15-02_Security-Incidents-Breaches"
echo(!GN!| findstr /i /c:"minutes" >nul && set "SDEST=%ROOT%\15_SEC_Security-and-Access\15-04_Security-Minutes"
if "!MODE!"=="PLAN" (
  echo     [file]  !GN!   into   15_SEC Security
  set /a n+=1
  exit /b
)
if not exist "!SDEST!\" md "!SDEST!"
move "%~1" "!SDEST!\" >nul 2>&1 && (
  >> "%UNDO%" echo move "!SDEST!\!GN!" "%%~dp0" ^>nul 2^>^&1
  echo     moved file:  !GN!
) || (
  echo     SKIPPED file:  !GN!
)
exit /b
