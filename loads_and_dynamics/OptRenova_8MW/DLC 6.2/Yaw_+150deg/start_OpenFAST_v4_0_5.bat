@echo off
setlocal EnableExtensions

REM Fixed OpenFAST executable path
set "FAST_EXE=E:\Optimus-Renova\loads_and_dynamics\openfast_x64_v4-05.exe"

REM Go to the folder where this BAT file is located
cd /d "%~dp0"

REM Check OpenFAST executable
if not exist "%FAST_EXE%" (
    echo ERROR: OpenFAST executable not found!
    echo %FAST_EXE%
    pause
    exit /b 1
)

REM Automatically detect the FST file
set "FST_FILE="

for %%F in (*.fst) do (
    if defined FST_FILE (
        echo ERROR: More than one FST file found!
        echo Keep only one FST file in this folder.
        pause
        exit /b 1
    )
    set "FST_FILE=%%F"
)

REM Check if an FST file was found
if not defined FST_FILE (
    echo ERROR: No FST file found in this folder!
    pause
    exit /b 1
)

REM Display selected simulation
echo ==========================================
echo OpenFAST Simulation
echo ==========================================
echo Folder: %CD%
echo Input:  %FST_FILE%
echo ==========================================

REM Run OpenFAST
"%FAST_EXE%" "%FST_FILE%"

REM Check simulation result
if errorlevel 1 (
    echo.
    echo ERROR: OpenFAST simulation failed!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Simulation completed successfully!
echo Results saved in: %CD%
echo ==========================================

pause
exit /b 0