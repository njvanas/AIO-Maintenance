@echo off
REM ======= AIO-Maintenance Build Script =======

echo Installing required modules...
pip install -r requirements.txt

echo Cleaning previous build...
rd /s /q build dist
del AIOMaintenance.spec

echo Building EXE with PyInstaller...
pyinstaller --onefile --windowed --clean --noupx AIOMaintenance.py

echo Done! Check the /dist folder for AIOMaintenance.exe
pause
