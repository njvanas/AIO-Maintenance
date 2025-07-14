@echo off
title System Cleanup Tool
echo ================================================================
echo                      SYSTEM CLEANUP TOOL
echo ================================================================
echo.
echo This script will perform comprehensive system cleanup.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

echo.
echo [1/8] Cleaning temporary files...
del /q /s "%TEMP%\*" 2>nul
del /q /s "%TMP%\*" 2>nul
del /q /s "C:\Windows\Temp\*" 2>nul

echo [2/8] Cleaning browser caches...
:: Chrome
if exist "%LocalAppData%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache" 2>nul
)
:: Edge
if exist "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" (
    rd /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" 2>nul
)
:: Firefox
for /d %%D in ("%AppData%\Mozilla\Firefox\Profiles\*") do (
    if exist "%%D\cache2" rd /s /q "%%D\cache2" 2>nul
)

echo [3/8] Emptying Recycle Bin...
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

echo [4/8] Cleaning Windows Update cache...
net stop wuauserv >nul 2>&1
rd /s /q "C:\Windows\SoftwareDistribution\Download" 2>nul
net start wuauserv >nul 2>&1

echo [5/8] Cleaning system logs...
for /f "tokens=*" %%G in ('wevtutil.exe el') do (
    wevtutil.exe cl "%%G" >nul 2>&1
)

echo [6/8] Cleaning prefetch files...
del /q /s "C:\Windows\Prefetch\*" 2>nul

echo [7/8] Running disk cleanup...
cleanmgr /sagerun:1 /verylowdisk

echo [8/8] Defragmenting system files...
sfc /scannow

echo.
echo ================================================================
echo                    CLEANUP COMPLETED
echo ================================================================
echo System cleanup has been completed successfully.
echo Your system should now have more free space and better performance.
echo.
pause