@echo off
setlocal EnableDelayedExpansion
title AIO Maintenance - Script Manager

:: Check for admin rights
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo This tool requires administrator privileges.
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

:: Set up directories
set "SCRIPT_DIR=%~dp0scripts"
set "LOG_DIR=%~dp0logs"
set "CONFIG_DIR=%~dp0config"

if not exist "%SCRIPT_DIR%" mkdir "%SCRIPT_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

set "EDITOR_FILE=%CONFIG_DIR%\editor.cfg"
if exist "%EDITOR_FILE%" (
    set /p EDITOR=<"%EDITOR_FILE%"
) else (
    call :detect_editor
)

:: Main menu loop
:main_menu
cls
echo ================================================================
echo                    AIO MAINTENANCE TOOL
echo                    Native Windows Edition
echo ================================================================
echo.
echo [1] Run Script
echo [2] Edit Script
echo [3] Create New Script
echo [4] View Logs
echo [5] System Information
echo [6] Download Sample Scripts
echo [7] Settings
echo [0] Exit
echo.
set /p choice="Select an option (0-7): "

if "%choice%"=="1" goto run_script
if "%choice%"=="2" goto edit_script
if "%choice%"=="3" goto create_script
if "%choice%"=="4" goto view_logs
if "%choice%"=="5" goto system_info
if "%choice%"=="6" goto download_scripts
if "%choice%"=="7" goto settings
if "%choice%"=="0" goto exit_program
goto main_menu

:run_script
cls
echo ================================================================
echo                        RUN SCRIPT
echo ================================================================
echo.
echo Available scripts:
echo.
set count=0
for %%f in ("%SCRIPT_DIR%\*.bat" "%SCRIPT_DIR%\*.ps1" "%SCRIPT_DIR%\*.cmd") do (
    set /a count+=1
    echo [!count!] %%~nxf
    set "script[!count!]=%%f"
)

if %count%==0 (
    echo No scripts found in the scripts directory.
    echo Press any key to return to main menu...
    pause >nul
    goto main_menu
)

echo.
set /p script_choice="Select script to run (1-%count%) or 0 to go back: "

if "%script_choice%"=="0" goto main_menu
if not defined script[%script_choice%] (
    echo Invalid selection.
    pause
    goto run_script
)

set "selected_script=!script[%script_choice%]!"
echo.
echo Running: !selected_script!
echo ================================================================

:: Create log file
set "timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "logfile=%LOG_DIR%\execution_%timestamp%.log"

echo Script execution started at %date% %time% > "%logfile%"
echo Script: !selected_script! >> "%logfile%"
echo ================================================================ >> "%logfile%"

:: Run the script based on extension
if /i "!selected_script:~-4!"==".ps1" (
    powershell -ExecutionPolicy Bypass -File "!selected_script!" 2>&1 | tee "%logfile%"
) else (
    call "!selected_script!" 2>&1 | tee "%logfile%"
)

echo.
echo ================================================================
echo Script execution completed.
echo Log saved to: %logfile%
echo Press any key to continue...
pause >nul
goto main_menu

:edit_script
cls
echo ================================================================
echo                       EDIT SCRIPT
echo ================================================================
echo.
echo Available scripts:
echo.
set count=0
for %%f in ("%SCRIPT_DIR%\*.bat" "%SCRIPT_DIR%\*.ps1" "%SCRIPT_DIR%\*.cmd") do (
    set /a count+=1
    echo [!count!] %%~nxf
    set "script[!count!]=%%f"
)

if %count%==0 (
    echo No scripts found in the scripts directory.
    echo Press any key to return to main menu...
    pause >nul
    goto main_menu
)

echo.
set /p script_choice="Select script to edit (1-%count%) or 0 to go back: "

if "%script_choice%"=="0" goto main_menu
if not defined script[%script_choice%] (
    echo Invalid selection.
    pause
    goto edit_script
)

set "selected_script=!script[%script_choice%]!"
echo.
echo Opening: !selected_script!
start "" "!EDITOR!" "!selected_script!"

echo Script opened in editor.
echo Press any key to continue...
pause >nul
goto main_menu

:create_script
cls
echo ================================================================
echo                      CREATE NEW SCRIPT
echo ================================================================
echo.
echo [1] Batch Script (.bat)
echo [2] PowerShell Script (.ps1)
echo [3] Command Script (.cmd)
echo [0] Back to main menu
echo.
set /p script_type="Select script type (0-3): "

if "%script_type%"=="0" goto main_menu

set /p script_name="Enter script name (without extension): "
if "%script_name%"=="" (
    echo Script name cannot be empty.
    pause
    goto create_script
)

if "%script_type%"=="1" (
    set "extension=.bat"
    set "template=@echo off%nl%echo This is a new batch script%nl%pause"
)
if "%script_type%"=="2" (
    set "extension=.ps1"
    set "template=# This is a new PowerShell script%nl%Write-Host "Hello from PowerShell!"%nl%Read-Host "Press Enter to continue""
)
if "%script_type%"=="3" (
    set "extension=.cmd"
    set "template=@echo off%nl%echo This is a new command script%nl%pause"
)

set "new_script=%SCRIPT_DIR%\%script_name%%extension%"

if exist "%new_script%" (
    echo Script already exists. Overwrite? (y/n)
    set /p overwrite=
    if /i not "!overwrite!"=="y" goto create_script
)

:: Create the script with template
(
    echo %template%
) > "%new_script%"

echo.
echo Script created: %new_script%
echo Opening in editor...
start "" "!EDITOR!" "%new_script%"

echo Press any key to continue...
pause >nul
goto main_menu

:view_logs
cls
echo ================================================================
echo                        VIEW LOGS
echo ================================================================
echo.
echo Recent log files:
echo.
set count=0
for /f "delims=" %%f in ('dir /b /o-d "%LOG_DIR%\*.log" 2^>nul') do (
    set /a count+=1
    if !count! leq 10 (
        echo [!count!] %%f
        set "log[!count!]=%LOG_DIR%\%%f"
    )
)

if %count%==0 (
    echo No log files found.
    echo Press any key to return to main menu...
    pause >nul
    goto main_menu
)

echo.
set /p log_choice="Select log to view (1-%count%) or 0 to go back: "

if "%log_choice%"=="0" goto main_menu
if not defined log[%log_choice%] (
    echo Invalid selection.
    pause
    goto view_logs
)

cls
echo ================================================================
echo LOG CONTENT
echo ================================================================
type "!log[%log_choice%]!"
echo.
echo ================================================================
echo Press any key to continue...
pause >nul
goto main_menu

:system_info
cls
echo ================================================================
echo                     SYSTEM INFORMATION
echo ================================================================
echo.
echo Computer Name: %COMPUTERNAME%
echo User Name: %USERNAME%
echo OS Version: 
ver
echo.
echo Processor:
wmic cpu get name /value | findstr "Name="
echo.
echo Memory:
wmic computersystem get TotalPhysicalMemory /value | findstr "TotalPhysicalMemory="
echo.
echo Disk Space:
wmic logicaldisk get size,freespace,caption /value | findstr "="
echo.
echo Network Adapters:
wmic path win32_NetworkAdapter where NetEnabled=true get Name /value | findstr "Name="
echo.
echo ================================================================
echo Press any key to continue...
pause >nul
goto main_menu

:download_scripts
cls
echo ================================================================
echo                    DOWNLOAD SAMPLE SCRIPTS
echo ================================================================
echo.
echo This will download sample maintenance scripts from GitHub.
echo Continue? (y/n)
set /p download_confirm=
if /i not "%download_confirm%"=="y" goto main_menu

echo.
echo Downloading sample scripts...

:: Use PowerShell to download scripts
powershell -Command ^
"& { ^
    $scripts = @{ ^
        'Clear-BrowserCache.bat' = 'https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/Clear%%20Browser%%20Cache%%20and%%20Cookies.bat'; ^
        'Empty-Downloads.bat'    = 'https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/Empty%%20Downloads%%20Folder.bat'; ^
        'Empty-RecycleBin.ps1'   = 'https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/Empty%%20Recycle%%20Bin.ps1'; ^
        'Reset-WindowsUpdate.bat'= 'https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/Reset%%20Windows%%20Update%%20Cache.bat' ^
    }; ^
    foreach ($script in $scripts.GetEnumerator()) { ^
        try { ^
            $output = Join-Path '%SCRIPT_DIR%' $script.Key; ^
            Invoke-WebRequest -Uri $script.Value -OutFile $output -UseBasicParsing; ^
            Write-Host \"Downloaded: $($script.Key)\"; ^
        } catch { ^
            Write-Host \"Failed to download: $($script.Key)\"; ^
        } ^
    } ^
}"

echo.
echo Download completed.
echo Press any key to continue...
pause >nul
goto main_menu

:settings
cls
echo ================================================================
echo                         SETTINGS
echo ================================================================
echo.
echo [1] Set Default Editor
echo [2] Clear All Logs
echo [3] Backup Scripts
echo [4] Restore Scripts
echo [0] Back to main menu
echo.
set /p settings_choice="Select option (0-4): "

if "%settings_choice%"=="0" goto main_menu
if "%settings_choice%"=="1" goto set_editor
if "%settings_choice%"=="2" goto clear_logs
if "%settings_choice%"=="3" goto backup_scripts
if "%settings_choice%"=="4" goto restore_scripts
goto settings

:set_editor
cls
echo ================================================================
echo                        SET DEFAULT EDITOR
echo ================================================================
call :find_npp
echo.
echo Current editor: !EDITOR!
echo.
if defined NPP_PATH (
    echo [1] Use Notepad++
)
echo [2] Use Windows Notepad
echo [0] Cancel
set /p ed_choice="Select option: "
if "%ed_choice%"=="1" (
    if defined NPP_PATH (
        set "EDITOR=!NPP_PATH!"
        echo !EDITOR!>"%EDITOR_FILE%"
        echo Default editor set to Notepad++.
    ) else (
        echo Notepad++ not found on this system.
    )
) else if "%ed_choice%"=="2" (
    set "EDITOR=notepad"
    echo !EDITOR!>"%EDITOR_FILE%"
    echo Default editor set to Windows Notepad.
)
echo.
echo Press any key to continue...
pause >nul
goto settings

:clear_logs
echo.
echo This will delete all log files. Continue? (y/n)
set /p clear_confirm=
if /i "%clear_confirm%"=="y" (
    del /q "%LOG_DIR%\*.log" 2>nul
    echo All logs cleared.
) else (
    echo Operation cancelled.
)
echo Press any key to continue...
pause >nul
goto settings

:backup_scripts
echo.
set "backup_file=%~dp0scripts_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.zip"
echo Creating backup: %backup_file%

powershell -Command "Compress-Archive -Path '%SCRIPT_DIR%\*' -DestinationPath '%backup_file%' -Force"

if exist "%backup_file%" (
    echo Backup created successfully.
) else (
    echo Backup failed.
)
echo Press any key to continue...
pause >nul
goto settings

:restore_scripts
echo.
echo Select backup file to restore:
set count=0
for %%f in ("%~dp0scripts_backup_*.zip") do (
    set /a count+=1
    echo [!count!] %%~nxf
    set "backup[!count!]=%%f"
)

if %count%==0 (
    echo No backup files found.
    echo Press any key to continue...
    pause >nul
    goto settings
)

echo.
set /p backup_choice="Select backup to restore (1-%count%) or 0 to cancel: "

if "%backup_choice%"=="0" goto settings
if not defined backup[%backup_choice%] (
    echo Invalid selection.
    pause
    goto restore_scripts
)

echo.
echo This will overwrite existing scripts. Continue? (y/n)
set /p restore_confirm=
if /i "%restore_confirm%"=="y" (
    powershell -Command "Expand-Archive -Path '!backup[%backup_choice%]!' -DestinationPath '%SCRIPT_DIR%' -Force"
    echo Scripts restored successfully.
) else (
    echo Operation cancelled.
)
echo Press any key to continue...
pause >nul
goto settings

:find_npp
where notepad++ >nul 2>&1
if %errorlevel%==0 (
    set "NPP_PATH=notepad++"
    goto :eof
)
if exist "%ProgramFiles%\Notepad++\notepad++.exe" (
    set "NPP_PATH=%ProgramFiles%\Notepad++\notepad++.exe"
    goto :eof
)
if exist "%ProgramFiles(x86)%\Notepad++\notepad++.exe" (
    set "NPP_PATH=%ProgramFiles(x86)%\Notepad++\notepad++.exe"
    goto :eof
)
set "NPP_PATH="
goto :eof

:detect_editor
call :find_npp
if defined NPP_PATH (
    set "EDITOR=!NPP_PATH!"
) else (
    set "EDITOR=notepad"
)
echo !EDITOR!>"%EDITOR_FILE%"
goto :eof

:exit_program
cls
echo Thank you for using AIO Maintenance Tool!
echo.
timeout /t 2 >nul
exit /b 0