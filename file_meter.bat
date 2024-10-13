@echo off
setlocal enabledelayedexpansion

:input
set /p "directory=Enter the path to scan: "
set /p "num_files=Enter the number of largest files to find: "

if not exist "!directory!" (
    echo Error: Directory does not exist.
    goto input
)

echo.
echo Running File Meter on directory: !directory!
echo Finding the !num_files! largest files...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0file_meter.ps1" "!directory!" !num_files!

echo.
echo Press any key to exit...
pause >nul