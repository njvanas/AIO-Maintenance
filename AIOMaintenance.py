from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QVBoxLayout, QHBoxLayout, QSplitter, QWidget, QPushButton,
    QLabel, QProgressBar, QListWidget, QFileDialog, QTextEdit, QMessageBox
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal, QMimeData
from PyQt5.QtGui import QDragEnterEvent, QDropEvent
import os
import subprocess
import sys


class ScriptExecutor(QThread):
    update_status = pyqtSignal(str)  # Signal to update status pane
    update_output = pyqtSignal(str)  # Signal to append script output
    update_progress = pyqtSignal(int)  # Signal to update progress bar

    def __init__(self, script, is_powershell=False, script_name="Unknown Script"):
        super().__init__()
        self.script = script
        self.is_powershell = is_powershell
        self.script_name = script_name  # Pass the script name

    def run(self):
        try:
            self.update_status.emit(f"Status: Running script '{self.script_name}'...")
            if self.is_powershell:
                command = ["powershell.exe", "-NoProfile", "-Command", self.script]
            else:
                command = self.script

            process = subprocess.Popen(
                command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
            )

            total_lines = 100  # Assumed max for estimating progress
            current_progress = 0

            for line in process.stdout:
                self.update_output.emit(line.strip())
                current_progress += 1
                progress_percentage = min(int((current_progress / total_lines) * 100), 100)
                self.update_progress.emit(progress_percentage)

            stderr_output = process.stderr.read()

            process.wait()
            self.update_progress.emit(100)  # Ensure progress reaches 100% when done

            if process.returncode == 0:
                self.update_status.emit(f"Status: Script '{self.script_name}' completed successfully!")
            else:
                self.log_error(f"Script '{self.script_name}' failed with error code {process.returncode}:\n{stderr_output}")
                self.update_status.emit(f"Status: Script '{self.script_name}' failed with error code {process.returncode}. See error logs for details.")
        except Exception as e:
            error_message = f"Script '{self.script_name}' execution failed: {str(e)}"
            self.log_error(error_message)
            self.update_status.emit(f"Status: {error_message}")

    def log_error(self, message):
        error_dir = os.path.join(r"C:\\BAT", "Error")
        if not os.path.exists(error_dir):
            os.makedirs(error_dir)
        error_file = os.path.join(error_dir, f"error_log.txt")
        with open(error_file, "a") as file:
            file.write(f"{message}\n\n")


class AIOMaintenance(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("AIO Maintenance by Dolfie")  # Updated window title
        self.setGeometry(100, 100, 900, 600)
        self.light_mode = False  # Default to Dark Mode
        self.current_script_name = None  # Track current script name
        self.executor_thread = None  # To track the active thread
        self.default_save_dir = r"C:\\BAT"
        self.ensure_default_directory()
        self.import_default_scripts()
        self.setStyleSheet(self.dark_theme())
        self.initUI()

        # Enable drag-and-drop functionality
        self.setAcceptDrops(True)

    def ensure_default_directory(self):
        """Ensure that the default directory exists."""
        if not os.path.exists(self.default_save_dir):
            os.makedirs(self.default_save_dir)

    def import_default_scripts(self):
        """Import default scripts into the default folder."""
        default_scripts = {
            "Reset Windows Update Cache.bat": (
                "@echo off\n"
                "net stop wuauserv\n"
                "net stop cryptSvc\n"
                "net stop bits\n"
                "net stop msiserver\n"
                "del /f /s /q \"%systemroot%\\SoftwareDistribution\\*\"\n"
                "rd /s /q \"%systemroot%\\SoftwareDistribution\"\n"
                "del /f /s /q \"%systemroot%\\System32\\catroot2\\*\"\n"
                "rd /s /q \"%systemroot%\\System32\\catroot2\"\n"
                "net start wuauserv\n"
                "net start cryptSvc\n"
                "net start bits\n"
                "net start msiserver\n"
            ),
            "DISM Health Restore.bat": "DISM /Online /Cleanup-Image /RestoreHealth",
            "Clear Browser Cache and Cookies.bat": (
                "@echo off\n"
                ":: Example Script Content\n"
                "echo Clearing browser cache and cookies..."
            ),
            "Empty Recycle Bin.ps1": "Clear-RecycleBin -Force -ErrorAction SilentlyContinue",
            "Empty Downloads Folder.bat": "del /q /s \"%UserProfile%\\Downloads\\*\"",
            "Windows 11 Activation.bat": (
                "@echo off\n"
                "slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX\n"
                "slmgr /skms kms8.msguides.com\n"
                "slmgr /ato\n"
            ),
            "Office 2021 Activation.bat": (
                "@echo off\n"
                "title Activate Microsoft Office 2021 (ALL versions) for FREE - MSGuides.com\n"
                "cls\n"
                "echo =====================================================================================\n"
                "echo #Project: Activating Microsoft software products for FREE without additional software\n"
                "echo =====================================================================================\n"
                "echo.\n"
                "echo #Supported products:\n"
                "echo - Microsoft Office Standard 2021\n"
                "echo - Microsoft Office Professional Plus 2021\n"
                "echo.\n"
                "echo.\n"
                "(if exist \"%ProgramFiles%\\Microsoft Office\\Office16\\ospp.vbs\" cd /d \"%ProgramFiles%\\Microsoft Office\\Office16\")\n"
                "(if exist \"%ProgramFiles(x86)%\\Microsoft Office\\Office16\\ospp.vbs\" cd /d \"%ProgramFiles(x86)%\\Microsoft Office\\Office16\")\n"
                "(for /f %%x in ('dir /b ..\\root\\Licenses16\\ProPlus2021VL_KMS*.xrm-ms') do cscript ospp.vbs /inslic:\"..\\root\\Licenses16\\%%x\" >nul)\n"
                "echo =====================================================================================\n"
                "echo Activating your product...\n"
                "cscript //nologo slmgr.vbs /ckms >nul\n"
                "cscript //nologo ospp.vbs /setprt:1688 >nul\n"
                "cscript //nologo ospp.vbs /unpkey:6F7TH >nul\n"
                "set i=1\n"
                "cscript //nologo ospp.vbs /inpkey:FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH >nul || goto notsupported\n"
                ":skms\n"
                "if %i% GTR 10 goto busy\n"
                "if %i% EQU 1 set KMS=kms7.MSGuides.com\n"
                "if %i% EQU 2 set KMS=s8.uk.to\n"
                "if %i% EQU 3 set KMS=s9.us.to\n"
                "if %i% GTR 3 goto ato\n"
                "cscript //nologo ospp.vbs /sethst:%KMS% >nul\n"
                ":ato\n"
                "echo =====================================================================================\n"
                "echo.\n"
                "echo.\n"
                "cscript //nologo ospp.vbs /act | find /i \"successful\" && (\n"
                "    echo.\n"
                "    echo =====================================================================================\n"
                "    echo.\n"
                "    echo #My official blog: MSGuides.com\n"
                "    echo.\n"
                "    echo #How it works: bit.ly/kms-server\n"
                "    echo.\n"
                "    echo #Please feel free to contact me at msguides.com@gmail.com if you have any questions or concerns.\n"
                "    echo.\n"
                "    echo #Please consider supporting this project: donate.msguides.com\n"
                "    echo #Your support is helping me keep my servers running 24/7!\n"
                "    echo.\n"
                "    echo =====================================================================================\n"
                "    choice /n /c YN /m \"Would you like to visit my blog [Y,N]?\" & if errorlevel 2 exit\n"
                ") || (\n"
                "    echo The connection to my KMS server failed! Trying to connect to another one...\n"
                "    echo Please wait...\n"
                "    echo.\n"
                "    echo.\n"
                "    set /a i+=1\n"
                "    goto skms\n"
                ")\n"
                "explorer \"http://MSGuides.com\"\n"
                "goto halt\n"
                ":notsupported\n"
                "echo =====================================================================================\n"
                "echo.\n"
                "echo Sorry, your version is not supported.\n"
                "echo.\n"
                "goto halt\n"
                ":busy\n"
                "echo =====================================================================================\n"
                "echo.\n"
                "echo Sorry, the server is busy and can't respond to your request. Please try again.\n"
                "echo.\n"
                ":halt\n"
                "pause >nul\n"
            ),
        }

        for script_name, content in default_scripts.items():
            script_path = os.path.join(self.default_save_dir, script_name)
            if not os.path.exists(script_path):
                with open(script_path, "w") as script_file:
                    script_file.write(content)

    def initUI(self):
        main_layout = QVBoxLayout()

        # Top Toolbar
        toolbar = QHBoxLayout()
        run_script_btn = QPushButton("Run")
        run_script_btn.setToolTip("Run the selected script")
        run_script_btn.clicked.connect(self.run_selected_script)

        add_script_btn = QPushButton("Add")
        add_script_btn.setToolTip("Add a custom script to the list")
        add_script_btn.clicked.connect(self.add_script)

        delete_script_btn = QPushButton("Delete")
        delete_script_btn.setToolTip("Delete the selected script from the list")
        delete_script_btn.clicked.connect(self.delete_selected_script)

        toggle_theme_btn = QPushButton("Toggle Dark/Light Mode")
        toggle_theme_btn.setToolTip("Switch between light and dark themes")
        toggle_theme_btn.clicked.connect(self.toggle_theme)

        for button in [run_script_btn, add_script_btn, delete_script_btn, toggle_theme_btn]:
            toolbar.addWidget(button)

        # Main Splitter (Left, Right, and Status Pane)
        main_splitter = QSplitter(Qt.Horizontal)

        # Left Pane: Script List
        self.script_list = QListWidget()
        self.load_scripts()
        self.script_list.itemClicked.connect(self.display_script_code)
        main_splitter.addWidget(self.script_list)

        # Right Pane: Script Code Editor
        self.script_editor = QTextEdit()
        self.script_editor.setToolTip("Edit the script code here")
        main_splitter.addWidget(self.script_editor)

        # Bottom Status Pane
        self.status_pane = QTextEdit()
        self.status_pane.setReadOnly(True)
        self.status_pane.setToolTip("Displays script execution status and output")
        main_splitter.addWidget(self.status_pane)

        main_splitter.setSizes([200, 600, 300])  # Initial sizes for left, right, and status panes

        # Bottom Layout: Progress Bar and Open Logs Button
        bottom_layout = QHBoxLayout()
        self.progress_bar = QProgressBar()
        self.progress_bar.setValue(0)
        self.progress_bar.setTextVisible(True)
        self.progress_bar.setFixedHeight(20)

        open_logs_btn = QPushButton("Open Logs")
        open_logs_btn.setToolTip("Open the log directory")
        open_logs_btn.clicked.connect(self.open_logs)
        open_logs_btn.setFixedSize(100, 30)  # Fixed size for consistency

        bottom_layout.addWidget(self.progress_bar)
        bottom_layout.addWidget(open_logs_btn)

        # Combine Layouts
        main_layout.addLayout(toolbar)
        main_layout.addWidget(main_splitter)
        main_layout.addLayout(bottom_layout)

        # Set Central Widget
        central_widget = QWidget()
        central_widget.setLayout(main_layout)
        self.setCentralWidget(central_widget)

    def load_scripts(self):
        """Load scripts from the default folder into the list."""
        self.script_list.clear()
        for script_name in os.listdir(self.default_save_dir):
            if script_name.endswith(".bat") or script_name.endswith(".ps1"):
                self.script_list.addItem(script_name)

    def toggle_theme(self):
        self.light_mode = not self.light_mode
        if self.light_mode:
            self.setStyleSheet(self.light_theme())
        else:
            self.setStyleSheet(self.dark_theme())

    def display_script_code(self, item):
        """Display the code for the selected script in the editor."""
        self.current_script_name = item.text()
        script_path = os.path.join(self.default_save_dir, self.current_script_name)
        with open(script_path, "r") as file:
            self.script_editor.setText(file.read())

    def run_selected_script(self):
        """Run the selected script."""
        if self.executor_thread and self.executor_thread.isRunning():
            self.append_to_status_pane("A script is already running. Please wait.")
            return

        selected_item = self.script_list.currentItem()
        if not selected_item:
            self.append_to_status_pane("No script selected. Please select a script to run.")
            return

        script_name = selected_item.text()
        script_path = os.path.join(self.default_save_dir, script_name)
        is_powershell = script_name.endswith(".ps1")

        self.progress_bar.setValue(0)  # Reset progress bar

        self.executor_thread = ScriptExecutor(script_path, is_powershell=is_powershell, script_name=script_name)
        self.executor_thread.update_status.connect(self.update_status_pane)
        self.executor_thread.update_output.connect(self.append_to_status_pane)
        self.executor_thread.update_progress.connect(self.progress_bar.setValue)  # Connect progress
        self.executor_thread.start()

    def delete_selected_script(self):
        """Delete the selected script."""
        selected_item = self.script_list.currentItem()
        if not selected_item:
            self.append_to_status_pane("No script selected to delete.")
            return

        confirmation = QMessageBox.question(
            self,
            "Delete Script",
            f"Are you sure you want to delete '{selected_item.text()}'?",
            QMessageBox.Yes | QMessageBox.No,
        )
        if confirmation == QMessageBox.Yes:
            os.remove(os.path.join(self.default_save_dir, selected_item.text()))
            self.load_scripts()

    def add_script(self):
        """Add a new script to the list."""
        file_dialog = QFileDialog.getOpenFileName(self, "Select a Script", "", "Batch Files (*.bat);;PowerShell Scripts (*.ps1);;All Files (*)")
        script_path = file_dialog[0]
        if script_path:
            script_name = os.path.basename(script_path)
            destination_path = os.path.join(self.default_save_dir, script_name)
            os.rename(script_path, destination_path)
            self.load_scripts()

    def open_logs(self):
        """Open the default save directory."""
        error_dir = os.path.join(self.default_save_dir, "Error")
        if not os.path.exists(error_dir):
            os.makedirs(error_dir)
        os.startfile(error_dir)

    def append_to_status_pane(self, message):
        """Append a message to the status pane."""
        self.status_pane.append(message)

    def update_status_pane(self, message):
        """Update the status pane with a new message."""
        self.status_pane.append(message)

    def closeEvent(self, event):
        """Handle application close event."""
        if self.executor_thread and self.executor_thread.isRunning():
            self.executor_thread.terminate()
        event.accept()

    def light_theme(self):
        """Define the light theme stylesheet."""
        return """
        QMainWindow { background-color: white; border-radius: 10px; }
        QPushButton { background-color: #f0f0f0; border-radius: 5px; padding: 5px; }
        QPushButton:hover { background-color: #e0e0e0; }
        QListWidget { background-color: #f8f8f8; border-radius: 5px; }
        QTextEdit { background-color: #ffffff; border-radius: 5px; }
        QProgressBar { border: 1px solid #c0c0c0; text-align: center; border-radius: 5px; background-color: #e0e0e0; }
        QProgressBar::chunk { background-color: #5f9ea0; }
        """

    def dark_theme(self):
        """Define the dark theme stylesheet."""
        return """
        QMainWindow { background-color: #1e1e1e; border-radius: 10px; }
        QPushButton { background-color: #333333; color: white; border-radius: 5px; padding: 5px; }
        QPushButton:hover { background-color: #444444; }
        QListWidget { background-color: #2e2e2e; color: white; border-radius: 5px; }
        QTextEdit { background-color: #333333; color: white; border-radius: 5px; }
        QProgressBar { border: 1px solid #444444; text-align: center; border-radius: 5px; background-color: #333333; }
        QProgressBar::chunk { background-color: #4caf50; }
        """


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyle("Fusion")
    window = AIOMaintenance()
    window.show()
    sys.exit(app.exec_())
