@echo off
REM ================================================================
REM  Alhasa Palm Project (Tamimi) - HSE File Auto-Sorter
REM  Double-click. It shows a PLAN first and moves nothing until you
REM  type YES. It writes _SORT-LOG.txt and _UNDO-SORT.bat (to revert).
REM  Put this file in your project folder next to your files.
REM ================================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"
set "SELF=%~nx0"
set "PLAN=_SORT-PLAN.txt"
set "LOG=_SORT-LOG.txt"
set "UNDO=_UNDO-SORT.bat"
if exist "%PLAN%" del "%PLAN%"
set /a match=0
set /a skip=0

echo.
echo  Scanning files and building a plan (nothing is moved yet)...
echo.

for %%F in (*) do (
  set "FN=%%~nxF"
  set "EXT=%%~xF"
  set "DEST="
  set "DROP="
  REM --- skip system / script / deliverable files ---
  if /i "!FN!"=="%SELF%"  set "DROP=1"
  if /i "!EXT!"==".bat"   set "DROP=1"
  if /i "!EXT!"==".ps1"   set "DROP=1"
  if /i "!FN:~0,1!"=="_"   set "DROP=1"
  if /i "!FN!"=="Alhasa-Palm-HSE-Folders.zip" set "DROP=1"
  if /i "!FN!"=="Alhasa-Palm-HSE-File-Register.xlsx" set "DROP=1"
  if /i "!FN!"=="Alhasa-Palm-HSE-File-Organization-Guide.docx" set "DROP=1"
  if not defined DROP (
    REM --- photos and videos go to Site Media by extension ---
    if /i "!EXT!"==".jpg" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".jpeg" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".png" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".gif" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".bmp" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".tif" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".tiff" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".heic" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".webp" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".mp4" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".mov" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".avi" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".wmv" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".mkv" set "DEST=80_MED_Site-Media"
    if /i "!EXT!"==".m4v" set "DEST=80_MED_Site-Media"
    REM --- otherwise classify by keywords in the file name ---
    if not defined DEST echo(!FN!| findstr /i /c:"permit" /c:"ptw" /c:"hot work" /c:"cold work" /c:"confined" /c:"excavation" /c:"work at height" /c:"lifting operation" /c:"loto" /c:"lockout" /c:"scaffold erect" >nul && set "DEST=20_PTW_Permits-to-Work"
    if not defined DEST echo(!FN!| findstr /i /c:"incident" /c:"accident" /c:"injury" /c:"near miss" /c:"nearmiss" /c:"investigation" /c:"fatality" /c:"first aid" /c:"lost time" /c:"lti" /c:"root cause" /c:"rca" >nul && set "DEST=30_INC_Incidents-and-Investigations"
    if not defined DEST echo(!FN!| findstr /i /c:"observation" /c:"inspection" /c:"audit" /c:"ncr" /c:"non-conformance" /c:"nonconformance" /c:"conformance" /c:"capa" /c:"corrective" /c:"walkdown" /c:"walkthrough" >nul && set "DEST=40_OBS_Observations-and-Inspections"
    if not defined DEST echo(!FN!| findstr /i /c:"training" /c:"induction" /c:"toolbox" /c:"tool box" /c:"tbt" /c:"competency" /c:"orientation" /c:"awareness" /c:"course" >nul && set "DEST=50_TRN_Training-and-Competency"
    if not defined DEST echo(!FN!| findstr /i /c:"certificate" /c:"cert" /c:"calibration" /c:"third party" /c:"3rd party" /c:"lifting gear" /c:"crane" /c:"equipment" /c:"vehicle" /c:"plant register" >nul && set "DEST=60_CRT_Certificates-and-Equipment"
    if not defined DEST echo(!FN!| findstr /i /c:"report" /c:"monthly" /c:"weekly" /c:"daily" /c:"kpi" /c:"statistic" /c:"man hour" /c:"manhour" /c:"dashboard" >nul && set "DEST=70_RPT_Reports-and-Statistics"
    if not defined DEST echo(!FN!| findstr /i /c:"method statement" /c:"risk assessment" /c:"jsa" /c:"job safety" /c:"procedure" /c:"policy" /c:"hse plan" /c:"emergency" /c:"erp" /c:"environmental" /c:"waste" /c:"objective" >nul && set "DEST=10_HSE_Plans-and-Procedures"
    if not defined DEST echo(!FN!| findstr /i /c:"drawing" /c:"dwg" /c:"layout" /c:"as built" /c:"asbuilt" /c:"map" /c:"msds" /c:"data sheet" /c:"datasheet" /c:"standard" /c:"specification" >nul && set "DEST=90_DWG_Drawings-and-Reference"
    if not defined DEST echo(!FN!| findstr /i /c:"minutes" /c:"mom" /c:"contract" /c:"agreement" /c:"correspondence" /c:"letter" /c:"kickoff" /c:"kick off" /c:"roster" /c:"mobilization" /c:"organization" /c:"memo" >nul && set "DEST=00_PM_Project-Management"
    if defined DEST (
      >>"%PLAN%" echo !FN!^|!DEST!
      set /a match+=1
    ) else (
      set /a skip+=1
      echo   [no match - will stay put]  !FN!
    )
  )
)

echo.
echo  ============================================================
echo   PLAN READY:  !match! file(s) will be moved,  !skip! left in place.
echo  ============================================================
echo.
if !match! EQU 0 (
  echo  Nothing to move. Close this window.
  pause >nul
  goto :eof
)
echo  The moves are listed in %PLAN% (open it to review).
echo.
set "CONF="
set /p "CONF=Type  YES  and press Enter to MOVE the files (or just close to cancel): "
if /i not "!CONF!"=="YES" (
  echo  Cancelled. No files were moved.
  pause >nul
  goto :eof
)

REM --- perform the moves; build log + undo ---
> "%LOG%" echo Alhasa Palm HSE sort log
>> "%LOG%" echo -------------------------------
> "%UNDO%" echo @echo off
>> "%UNDO%" echo REM Run this to move every sorted file back to the main folder.
>> "%UNDO%" echo cd /d "%%~dp0"
for /f "usebackq tokens=1,2 delims=|" %%A in ("%PLAN%") do (
  if not exist "%%B" md "%%B"
  move "%%A" "%%B\" >nul 2>&1 && (
    >> "%LOG%" echo MOVED  %%A  --^>  %%B
    >> "%UNDO%" echo move "%%B\%%A" "%%~dp0" ^>nul 2^>^&1
  ) || (
    >> "%LOG%" echo FAILED %%A  (maybe a file with the same name already exists there)
  )
)
echo.
echo  ============================================================
echo   DONE. See _SORT-LOG.txt for details.
echo   To undo everything, double-click _UNDO-SORT.bat
echo  ============================================================
start "" "%~dp0"
echo.
echo  Press any key to close.
pause >nul
