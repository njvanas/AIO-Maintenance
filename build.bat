@echo off
REM Build the project using PyInstaller with hidden import for requests
pyinstaller --onefile --windowed --clean --noupx --hidden-import=requests AIOMaintenance.py

pause
