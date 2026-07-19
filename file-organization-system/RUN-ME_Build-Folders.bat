@echo off
REM ===================================================================
REM  Alhasa Palm Project (Tamimi) - HSE File System Builder
REM  Double-click this file to create the coded folder tree.
REM  It builds the folders in whatever folder this file is sitting in.
REM ===================================================================
echo.
echo  Building the Alhasa Palm HSE folder structure...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Build-AlhasaPalmFolders.ps1"
echo.
echo  Finished. Press any key to close.
pause >nul
