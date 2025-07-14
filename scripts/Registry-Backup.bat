@echo off
title Registry Backup Tool
echo ================================================================
echo                     REGISTRY BACKUP TOOL
echo ================================================================
echo.
echo This tool will create a backup of critical registry keys.
echo Backups will be saved to: %~dp0registry_backups\
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

:: Create backup directory
set "BACKUP_DIR=%~dp0registry_backups"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Generate timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%-%dt:~10,2%-%dt:~12,2%"

echo.
echo Creating registry backups...
echo Timestamp: %timestamp%
echo.

:: Backup critical registry keys
echo [1/6] Backing up HKEY_LOCAL_MACHINE\SOFTWARE...
reg export "HKEY_LOCAL_MACHINE\SOFTWARE" "%BACKUP_DIR%\HKLM_SOFTWARE_%timestamp%.reg" /y >nul 2>&1
if %errorlevel%==0 (echo ✓ HKLM\SOFTWARE backed up successfully) else (echo ✗ Failed to backup HKLM\SOFTWARE)

echo [2/6] Backing up HKEY_LOCAL_MACHINE\SYSTEM...
reg export "HKEY_LOCAL_MACHINE\SYSTEM" "%BACKUP_DIR%\HKLM_SYSTEM_%timestamp%.reg" /y >nul 2>&1
if %errorlevel%==0 (echo ✓ HKLM\SYSTEM backed up successfully) else (echo ✗ Failed to backup HKLM\SYSTEM)

echo [3/6] Backing up HKEY_CURRENT_USER...
reg export "HKEY_CURRENT_USER" "%BACKUP_DIR%\HKCU_%timestamp%.reg" /y >nul 2>&1
if %errorlevel%==0 (echo ✓ HKCU backed up successfully) else (echo ✗ Failed to backup HKCU)

echo [4/6] Backing up HKEY_LOCAL_MACHINE\HARDWARE...
reg export "HKEY_LOCAL_MACHINE\HARDWARE" "%BACKUP_DIR%\HKLM_HARDWARE_%timestamp%.reg" /y >nul 2>&1
if %errorlevel%==0 (echo ✓ HKLM\HARDWARE backed up successfully) else (echo ✗ Failed to backup HKLM\HARDWARE)

echo [5/6] Backing up Boot Configuration...
bcdedit /export "%BACKUP_DIR%\BCD_BACKUP_%timestamp%.bcd" >nul 2>&1
if %errorlevel%==0 (echo ✓ Boot configuration backed up successfully) else (echo ✗ Failed to backup boot configuration)

echo [6/6] Creating system restore point...
powershell -Command "Checkpoint-Computer -Description 'Registry Backup %timestamp%' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
if %errorlevel%==0 (echo ✓ System restore point created successfully) else (echo ✗ Failed to create system restore point)

echo.
echo ================================================================
echo                    BACKUP COMPLETED
echo ================================================================
echo Registry backup has been completed.
echo Backup location: %BACKUP_DIR%
echo.
echo Files created:
dir /b "%BACKUP_DIR%\*%timestamp%*"
echo.
echo IMPORTANT: Store these backups in a safe location.
echo To restore, double-click the .reg files or use 'reg import filename.reg'
echo.
pause