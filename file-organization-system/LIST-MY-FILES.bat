@echo off
REM ================================================================
REM  Alhasa Palm Project - list every file so we can tune the sorter
REM  Double-click. It writes _ALL-FILES.txt and opens it. Nothing is
REM  moved, renamed, or deleted - it only reads the file names.
REM ================================================================
setlocal
cd /d "%~dp0"
set "OUT=_ALL-FILES.txt"
> "%OUT%" echo ===== FILES IN THE MAIN FOLDER (not yet sorted) =====
for %%F in (*) do if /i not "%%~nxF"=="%~nx0" if /i not "%%~nxF"=="%OUT%" >> "%OUT%" echo %%~nxF
>> "%OUT%" echo.
>> "%OUT%" echo ===== FILES INSIDE SUB-FOLDERS =====
for /f "delims=" %%D in ('dir /b /ad 2^>nul') do (
  >> "%OUT%" echo(
  >> "%OUT%" echo [%%D]
  for /f "delims=" %%G in ('dir /b /a-d "%%D" 2^>nul') do >> "%OUT%" echo    %%G
)
echo.
echo  Done. _ALL-FILES.txt is opening - copy everything in it and paste it back to me.
start "" "%OUT%"
echo  Press any key to close.
pause >nul
