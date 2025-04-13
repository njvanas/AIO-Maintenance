@echo off
setlocal EnableDelayedExpansion

:: ============================
:: Universal KMS Activator - Office / Visio / Project / Windows
:: Author: Dolfie | github.com/njvanas
:: ============================

:: === Require Admin ===
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
  echo Please run as administrator.
  powershell -Command "Start-Process '%~f0' -Verb runAs"
  exit /b
)

:: === Logging ===
set "LOGDIR=%~dp0Error"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set "LOGFILE=%LOGDIR%\kms-activator-log.txt"
set "RESULTFILE=%LOGDIR%\activation-summary.txt"
echo Running script at %DATE% %TIME% > "%LOGFILE%"
echo KMS Activation Summary - %DATE% %TIME% > "%RESULTFILE%"

:: === KMS Servers ===
set "kms[1]=kms7.MSGuides.com"
set "kms[2]=s8.uk.to"
set "kms[3]=s9.us.to"
set "kms[4]=kms.digiboy.ir"
set "kms[5]=kms8.msguides.com"

:: === Menu ===
echo ================================================================
echo   Select activation target:
echo   [1] Microsoft Office Only
echo   [2] Windows Only
echo   [3] Visio Only
echo   [4] Project Only
echo   [5] All (Office, Visio, Project, Windows)
echo.
set /p mode="Enter your choice (1-5): "

:: === Locate ospp.vbs ===
set "osppPath="
for %%D in ("%ProgramFiles%", "%ProgramFiles(x86)%") do (
  for %%V in (Office16 Office15 Office14) do (
    if exist "%%~D\Microsoft Office\%%~V\ospp.vbs" (
      set "osppPath=%%~D\Microsoft Office\%%~V"
    )
  )
)

:: === Routing ===
if "%mode%"=="1" call :activate_office
if "%mode%"=="2" call :activate_windows
if "%mode%"=="3" call :activate_visio
if "%mode%"=="4" call :activate_project
if "%mode%"=="5" (
  call :activate_office
  call :activate_visio
  call :activate_project
  call :activate_windows
)

:: === Show Results ===
echo. >> "%RESULTFILE%"
echo Activation complete. Summary saved to: %RESULTFILE%
echo ================================================================
echo               ACTIVATION SUMMARY
echo ================================================================
type "%RESULTFILE%"
echo ================================================================
pause
exit /b

:: === License Filtering ===
:activate_office
if not defined osppPath (
  echo [SKIPPED] Office not found. >> "%RESULTFILE%"
  goto :eof
)
set "officeKey="
for /f "tokens=* delims=" %%v in ('cscript //nologo "%osppPath%\ospp.vbs" /dstatus ^| findstr /i "Office"') do (
  echo %%v >> "%LOGFILE%"
  echo %%v | findstr /i "2016" >nul && set "officeKey=JNRGM-WHDWX-FJJG3-K47QV-DRTFM"
  echo %%v | findstr /i "2019" >nul && set "officeKey=NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP"
  echo %%v | findstr /i "2021" >nul && set "officeKey=FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH"
  echo %%v | findstr /i "2024" >nul && set "officeKey=FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH"
)
if not defined officeKey (
  echo [SKIPPED] Office version not detected. >> "%RESULTFILE%"
  goto :eof
)
for %%f in ("%osppPath%\..\root\Licenses16\ProPlus*VL_KMS_Client*.xrm-ms") do (
  echo Installing Office license: %%~nxf >> "%LOGFILE%"
  cscript //nologo "%osppPath%\ospp.vbs" /inslic:"%%f" >> "%LOGFILE%" 2>>&1
)
cscript //nologo "%osppPath%\ospp.vbs" /inpkey:!officeKey! >> "%LOGFILE%" 2>>&1
call :activate_loop "Office"
goto :eof

:activate_visio
if not defined osppPath (
  echo [SKIPPED] Visio not found. >> "%RESULTFILE%"
  goto :eof
)
set "visioKey="
for /f "tokens=* delims=" %%v in ('cscript //nologo "%osppPath%\ospp.vbs" /dstatus ^| findstr /i "Visio"') do (
  echo %%v >> "%LOGFILE%"
  echo %%v | findstr /i "2016" >nul && set "visioKey=PD3PC-RHNGV-FXJ29-8JK7D-RJRJK"
  echo %%v | findstr /i "2019" >nul && set "visioKey=9BGNQ-K37YR-RQHF2-38RQ3-7VCBB"
  echo %%v | findstr /i "2021" >nul && set "visioKey=KNH8D-FGHT4-T8RK3-CTDYJ-K2HT4"
)
if not defined visioKey (
  echo [SKIPPED] Visio version not detected. >> "%RESULTFILE%"
  goto :eof
)
for %%f in ("%osppPath%\..\root\Licenses16\*Visio*VL_KMS_Client*.xrm-ms") do (
  echo Installing Visio license: %%~nxf >> "%LOGFILE%"
  cscript //nologo "%osppPath%\ospp.vbs" /inslic:"%%f" >> "%LOGFILE%" 2>>&1
)
cscript //nologo "%osppPath%\ospp.vbs" /inpkey:!visioKey! >> "%LOGFILE%" 2>>&1
call :activate_loop "Visio"
goto :eof

:activate_project
if not defined osppPath (
  echo [SKIPPED] Project not found. >> "%RESULTFILE%"
  goto :eof
)
set "projKey="
for /f "tokens=* delims=" %%v in ('cscript //nologo "%osppPath%\ospp.vbs" /dstatus ^| findstr /i "Project"') do (
  echo %%v >> "%LOGFILE%"
  echo %%v | findstr /i "2016" >nul && set "projKey=YG9NW-3K39V-2T3HJ-93F3Q-G83KT"
  echo %%v | findstr /i "2019" >nul && set "projKey=B4NPR-3FKK7-T2MBV-FRQ4W-PKD2B"
  echo %%v | findstr /i "2021" >nul && set "projKey=FTNWT-C6WBT-8HMGF-K9PRX-QV9H8"
)
if not defined projKey (
  echo [SKIPPED] Project version not detected. >> "%RESULTFILE%"
  goto :eof
)
for %%f in ("%osppPath%\..\root\Licenses16\*Project*VL_KMS_Client*.xrm-ms") do (
  echo Installing Project license: %%~nxf >> "%LOGFILE%"
  cscript //nologo "%osppPath%\ospp.vbs" /inslic:"%%f" >> "%LOGFILE%" 2>>&1
)
cscript //nologo "%osppPath%\ospp.vbs" /inpkey:!projKey! >> "%LOGFILE%" 2>>&1
call :activate_loop "Project"
goto :eof

:activate_windows
:: Try converting Windows to KMS-compatible edition
set "winKey=VK7JG-NPHTM-C97JM-9MPGT-3V66T"
cscript //nologo slmgr.vbs /dli | findstr /i "VOLUME_KMSCLIENT" >nul
if errorlevel 1 (
  echo Converting Windows to VOLUME_KMSCLIENT... >> "%LOGFILE%"
  if defined winKey (
    cscript //nologo slmgr.vbs /ipk %winKey% >> "%LOGFILE%" 2>>&1
    timeout /t 2 >nul
  ) else (
    echo [ERROR] No GVLK key defined for Windows! Skipping. >> "%RESULTFILE%"
    goto :eof
  )
)
call :activate_loop "Windows"
goto :eof

:activate_loop
set "product=%~1"
for /L %%i in (1,1,5) do (
  set "kms=!kms[%%i]!"
  echo Trying !product! KMS: !kms! >> "%LOGFILE%"
  if "%product%"=="Windows" (
    cscript //nologo slmgr.vbs /skms !kms! >> "%LOGFILE%" 2>>&1
    cscript //nologo slmgr.vbs /ato | find /i "successfully" >nul && (
      echo [SUCCESS] %product% Activated via !kms! >> "%RESULTFILE%"
      goto :eof
    )
  ) else (
    cscript //nologo "%osppPath%\ospp.vbs" /sethst:!kms! >> "%LOGFILE%" 2>>&1
    cscript //nologo "%osppPath%\ospp.vbs" /act | find /i "successful" >nul && (
      echo [SUCCESS] %product% Activated via !kms! >> "%RESULTFILE%"
      goto :eof
    )
  )
  timeout /t 2 >nul
)
echo [FAILED] %product% activation failed. >> "%RESULTFILE%"
goto :eof
