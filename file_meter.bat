@echo off
setlocal enabledelayedexpansion

:: Check if arguments are provided
if "%~1"=="" goto :input
if "%~2"=="" goto :input

set "directory=%~1"
set "num_items=%~2"
goto :choose_mode

:input
set /p "directory=Enter the path to scan: "
set /p "num_items=Enter the number of items to find: "

:: Validate directory
if not exist "!directory!" (
    echo Error: Directory does not exist.
    goto :input
)

:choose_mode
set /p "count_mode=Analyze by (1) file or (2) file type? Enter 1 or 2: "

if "!count_mode!"=="2" (
    set "t_flag=-t"
    set "item_name=file types"
) else if "!count_mode!"=="1" (
    set "t_flag="
    set "item_name=files"
) else (
    echo Invalid choice. Please enter 1 or 2.
    goto :choose_mode
)

:run
echo.
echo Running File Meter on directory: !directory!
echo Finding the !num_items! largest !item_name!...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0file_meter.ps1" "!directory!" !num_items! !t_flag!

echo.
echo Press any key to exit...
pause >nul