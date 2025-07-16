# 🛠️ AIO Maintenance Tool - Native Windows Edition

A powerful, native Windows script management system that requires no external dependencies, Python installation, or code signing certificates.

## ✨ Features

- **100% Native Windows** - Uses only built-in Windows tools (Batch, PowerShell, CMD)
- **No Installation Required** - Just download and run
- **Admin Rights Management** - Automatically prompts for elevation when needed
- **Script Management** - Create, edit, and run maintenance scripts
- **Multiple Script Types** - Supports .bat, .ps1, and .cmd files
- **Logging System** - Automatic execution logging with timestamps
- **Sample Scripts** - Download common maintenance scripts from GitHub
- **System Information** - Built-in system diagnostics
- **Backup/Restore** - Script backup and restore functionality
- **Configurable Editor** - Choose between Notepad++ or Windows Notepad

## 🚀 Quick Start

1. Download `ScriptManager.bat` and `tee.bat`
2. Right-click `ScriptManager.bat` and select "Run as administrator"
3. Use the menu to manage your maintenance scripts

## 📁 Directory Structure

```
AIO-Maintenance/
├── ScriptManager.bat      # Main application
├── tee.bat               # Logging utility
├── scripts/              # Your maintenance scripts
├── logs/                 # Execution logs
└── config/               # Configuration files
```

## 🎯 Menu Options

1. **Run Script** - Execute any script with automatic logging
2. **Edit Script** - Open scripts in your chosen editor (Notepad++ or Notepad)
3. **Create New Script** - Generate new scripts with templates
4. **View Logs** - Browse execution history
5. **System Information** - Display system diagnostics
6. **Download Sample Scripts** - Get common maintenance scripts
7. **Settings** - Set the default editor, manage logs, backup/restore

## 🔧 Supported Script Types

- **Batch Files (.bat)** - Traditional Windows batch scripts
- **PowerShell (.ps1)** - Modern PowerShell scripts
- **Command Files (.cmd)** - Enhanced command scripts

## 📝 Sample Scripts Included

- Clear browser cache and cookies (all major browsers)
- Empty Downloads folder
- Empty Recycle Bin
- Reset Windows Update cache
- System cleanup utilities
- Network diagnostics
- Registry backup tool

## 🛡️ Security Features

- Automatic admin rights detection
- Safe script execution with logging
- Backup and restore functionality
- No external dependencies or unsigned executables

## 💡 Why This Approach?

- **No Python Required** - Works on any Windows machine
- **No Code Signing** - Avoids certificate requirements
- **No Installation** - Portable and self-contained
- **Native Performance** - Uses built-in Windows tools
- **Easy Distribution** - Just copy the .bat files

## 🔄 Updates

Scripts can be updated by:
1. Using the built-in download feature
2. Manually editing through the interface
3. Copying new scripts to the `scripts/` folder

## 📋 Requirements

- Windows 7 or later
- Administrator privileges (prompted automatically)
- PowerShell 2.0+ (included in modern Windows)

## 🤝 Contributing

Add your own maintenance scripts to the `scripts/` folder or contribute to the main repository.

## 📄 License

MIT License - Free for personal and commercial use.