@echo off
setlocal EnableDelayedExpansion

:: Simple tee implementation for Windows batch
:: Usage: command | tee.bat logfile.txt

set "logfile=%1"
if "%logfile%"=="" (
    echo Usage: command ^| tee.bat logfile.txt
    exit /b 1
)

:loop
set /p line= 2>nul
if errorlevel 1 goto :eof
echo !line!
echo !line! >> "%logfile%"
goto loop
