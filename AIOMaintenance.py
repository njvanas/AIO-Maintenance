
import os
import subprocess
import threading
import requests
import customtkinter as ctk
from tkinter import filedialog, messagebox
from tkinter.scrolledtext import ScrolledText

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")


class AIOMaintenanceApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("AIO Maintenance Tool")
        self.geometry("1000x650")
        self.resizable(False, False)

        self.script_dir = os.path.join(os.getcwd(), "scripts")
        self.log_file = "output.log"
        self.scripts = []
        self.current_process = None

        self.create_layout()
        self.fetch_scripts_if_needed()
        self.load_scripts()

    def create_layout(self):
        self.sidebar = ctk.CTkFrame(self, width=200)
        self.sidebar.pack(side="left", fill="y", padx=10, pady=10)

        self.script_listbox = ctk.CTkScrollableFrame(self.sidebar, width=180, height=400)
        self.script_listbox.pack(pady=(10, 10))

        self.script_buttons = []
        self.script_label = ctk.CTkLabel(self.sidebar, text="Scripts", font=("Arial", 16))
        self.script_label.pack()

        self.open_script_folder_btn = ctk.CTkButton(self.sidebar, text="📂 Open Scripts Folder", command=self.open_script_folder)
        self.open_script_folder_btn.pack(pady=(5, 5))

        self.open_log_btn = ctk.CTkButton(self.sidebar, text="📄 Open Log File", command=self.open_log)
        self.open_log_btn.pack(pady=(5, 5))

        self.main_panel = ctk.CTkFrame(self)
        self.main_panel.pack(fill="both", expand=True, padx=(0, 10), pady=10)

        self.script_editor = ScrolledText(self.main_panel, wrap="word", font=("Consolas", 12), height=20, bg="#2b2b2b", fg="#ffffff", insertbackground="white")
        self.script_editor.pack(fill="x", padx=10, pady=(10, 5))

        self.progress_bar = ctk.CTkProgressBar(self.main_panel)
        self.progress_bar.set(0)
        self.progress_bar.pack(fill="x", padx=10, pady=(0, 10))

        self.log_viewer = ScrolledText(self.main_panel, wrap="word", font=("Consolas", 10), height=12, bg="#1e1e1e", fg="#d4d4d4", insertbackground="white", state='disabled')
        self.log_viewer.pack(fill="both", padx=10, pady=(0, 10), expand=True)

        self.control_panel = ctk.CTkFrame(self.main_panel)
        self.control_panel.pack(fill="x", padx=10, pady=(0, 10))

        self.run_btn = ctk.CTkButton(self.control_panel, text="▶ Run Script", command=self.run_script)
        self.run_btn.pack(side="left", padx=(0, 10))

        self.save_btn = ctk.CTkButton(self.control_panel, text="💾 Save Script", command=self.save_script)
        self.save_btn.pack(side="left")

    def fetch_scripts_if_needed(self):
        os.makedirs(self.script_dir, exist_ok=True)
        if not os.listdir(self.script_dir):
            files = [
                "example_script.bat",
                "example_script.ps1"
            ]
            base_url = "https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/"
            for file in files:
                try:
                    r = requests.get(base_url + file)
                    if r.status_code == 200:
                        with open(os.path.join(self.script_dir, file), 'w', encoding='utf-8') as f:
                            f.write(r.text)
                except Exception as e:
                    print(f"Error downloading {file}: {e}")

    def load_scripts(self):
        self.scripts = []
        for widget in self.script_listbox.winfo_children():
            widget.destroy()

        for file in os.listdir(self.script_dir):
            if file.endswith((".ps1", ".bat", ".cmd")):
                self.scripts.append(file)
                button = ctk.CTkButton(self.script_listbox, text=file, command=lambda f=file: self.load_script_content(f))
                button.pack(fill="x", pady=2, padx=5)
                self.script_buttons.append(button)

    def load_script_content(self, script_name):
        script_path = os.path.join(self.script_dir, script_name)
        try:
            with open(script_path, 'r', encoding='utf-8') as f:
                content = f.read()
                self.script_editor.delete("1.0", "end")
                self.script_editor.insert("end", content)
                self.selected_script = script_name
        except Exception as e:
            messagebox.showerror("Error", f"Unable to load script:\n{e}")

    def save_script(self):
        if not hasattr(self, 'selected_script'):
            return
        path = os.path.join(self.script_dir, self.selected_script)
        try:
            with open(path, 'w', encoding='utf-8') as f:
                content = self.script_editor.get("1.0", "end")
                f.write(content)
                messagebox.showinfo("Success", f"{self.selected_script} saved.")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save script:\n{e}")

    def run_script(self):
        if not hasattr(self, 'selected_script'):
            return
        script_path = os.path.join(self.script_dir, self.selected_script)
        self.progress_bar.set(0.1)
        self.log_viewer.config(state='normal')
        self.log_viewer.delete("1.0", "end")
        self.log_viewer.insert("end", f"Running {self.selected_script}...\n")
        self.log_viewer.config(state='disabled')

        def execute():
            with open(self.log_file, 'w', encoding='utf-8') as log_file:
                try:
                    if self.selected_script.endswith(".ps1"):
                        cmd = ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path]
                    else:
                        cmd = [script_path]
                    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, shell=True)
                    self.current_process = process
                    for line in process.stdout:
                        self.after(0, self.append_log, line)
                        log_file.write(line)
                    process.wait()
                except Exception as e:
                    self.after(0, self.append_log, f"Error: {e}\n")
                finally:
                    self.after(0, lambda: self.progress_bar.set(1))

        threading.Thread(target=execute).start()

    def append_log(self, line):
        self.log_viewer.config(state='normal')
        self.log_viewer.insert("end", line)
        self.log_viewer.see("end")
        self.log_viewer.config(state='disabled')

    def open_script_folder(self):
        os.startfile(self.script_dir)

    def open_log(self):
        if os.path.exists(self.log_file):
            os.startfile(self.log_file)
        else:
            messagebox.showinfo("Log Not Found", "No log file found yet.")


if __name__ == "__main__":
    app = AIOMaintenanceApp()
    app.mainloop()
