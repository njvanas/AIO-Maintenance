@echo off
REM Build the executable and make sure hidden modules are bundled
pyinstaller --onefile --windowed --clean --noupx ^
  --hidden-import=requests ^
  --hidden-import=customtkinter ^
  AIOMaintenance.py

pause
