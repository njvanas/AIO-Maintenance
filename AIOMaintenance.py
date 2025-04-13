import os
import subprocess
import threading
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from tkinter.scrolledtext import ScrolledText

class AIOMaintenanceApp:
    def __init__(self, root):
        self.root = root
        self.root.title("AIO Maintenance - Dark Mode")
        self.root.geometry("900x600")
        self.root.configure(bg="#1e1e1e")

        self.scripts = []
        self.current_process = None
        self.script_dir = os.path.join(os.getcwd(), "scripts")
        self.log_file = "output.log"

        self.setup_style()
        self.create_widgets()
        self.load_scripts()

    def setup_style(self):
        style = ttk.Style()
        style.theme_use("default")
        style.configure("TLabel", background="#1e1e1e", foreground="#ffffff")
        style.configure("TButton", background="#333", foreground="#ffffff", padding=6)
        style.configure("TListbox", background="#252526", foreground="#ffffff")
        style.configure("TProgressbar", troughcolor="#3c3c3c", background="#0078d7")

    def create_widgets(self):
        frame_top = ttk.Frame(self.root)
        frame_top.pack(fill='x', padx=10, pady=10)

        self.script_listbox = tk.Listbox(frame_top, height=15, bg="#252526", fg="#ffffff", selectbackground="#0078d7", width=40)
        self.script_listbox.pack(side='left', fill='y')
        self.script_listbox.bind("<<ListboxSelect>>", self.display_script)

        self.script_editor = ScrolledText(frame_top, bg="#1e1e1e", fg="#d4d4d4", insertbackground="#ffffff")
        self.script_editor.pack(side='left', fill='both', expand=True, padx=(10, 0))

        frame_buttons = ttk.Frame(self.root)
        frame_buttons.pack(fill='x', padx=10, pady=5)

        ttk.Button(frame_buttons, text="Run Script", command=self.run_script).pack(side='left')
        ttk.Button(frame_buttons, text="Save Script", command=self.save_script).pack(side='left', padx=(10, 0))
        ttk.Button(frame_buttons, text="Open Scripts Folder", command=self.open_script_folder).pack(side='left', padx=(10, 0))
        ttk.Button(frame_buttons, text="Open Log", command=self.open_log).pack(side='left', padx=(10, 0))

        self.progress = ttk.Progressbar(self.root, mode="indeterminate")
        self.progress.pack(fill='x', padx=10, pady=(0, 10))

        self.log_viewer = ScrolledText(self.root, height=10, bg="#1e1e1e", fg="#d4d4d4", insertbackground="#ffffff", state='disabled')
        self.log_viewer.pack(fill='both', expand=True, padx=10, pady=(0, 10))

    def load_scripts(self):
        self.scripts = []
        self.script_listbox.delete(0, tk.END)
        if not os.path.exists(self.script_dir):
            os.makedirs(self.script_dir)
        for file in os.listdir(self.script_dir):
            if file.endswith((".ps1", ".bat", ".cmd")):
                self.scripts.append(file)
                self.script_listbox.insert(tk.END, file)

    def display_script(self, event=None):
        selection = self.script_listbox.curselection()
        if not selection:
            return
        script_name = self.scripts[selection[0]]
        script_path = os.path.join(self.script_dir, script_name)
        try:
            with open(script_path, 'r', encoding='utf-8') as f:
                content = f.read()
                self.script_editor.delete("1.0", tk.END)
                self.script_editor.insert(tk.END, content)
        except Exception as e:
            messagebox.showerror("Error", f"Unable to read script:\n{e}")

    def save_script(self):
        selection = self.script_listbox.curselection()
        if not selection:
            return
        script_name = self.scripts[selection[0]]
        script_path = os.path.join(self.script_dir, script_name)
        try:
            with open(script_path, 'w', encoding='utf-8') as f:
                content = self.script_editor.get("1.0", tk.END)
                f.write(content)
                messagebox.showinfo("Saved", f"{script_name} saved successfully.")
        except Exception as e:
            messagebox.showerror("Error", f"Unable to save script:\n{e}")

    def run_script(self):
        selection = self.script_listbox.curselection()
        if not selection:
            return
        script_name = self.scripts[selection[0]]
        script_path = os.path.join(self.script_dir, script_name)

        self.progress.start()
        self.log_viewer.config(state='normal')
        self.log_viewer.delete("1.0", tk.END)
        self.log_viewer.insert(tk.END, f"Running {script_name}...\n")
        self.log_viewer.config(state='disabled')

        def execute():
            with open(self.log_file, 'w', encoding='utf-8') as log_file:
                try:
                    if script_name.endswith(".ps1"):
                        cmd = ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path]
                    else:
                        cmd = [script_path]
                    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, shell=True)
                    self.current_process = process
                    for line in process.stdout:
                        self.root.after(0, self.append_log, line)
                        log_file.write(line)
                    process.wait()
                except Exception as e:
                    self.root.after(0, self.append_log, f"Error: {e}\n")
                finally:
                    self.root.after(0, self.progress.stop)

        threading.Thread(target=execute).start()

    def append_log(self, line):
        self.log_viewer.config(state='normal')
        self.log_viewer.insert(tk.END, line)
        self.log_viewer.see(tk.END)
        self.log_viewer.config(state='disabled')

    def open_script_folder(self):
        os.startfile(self.script_dir)

    def open_log(self):
        if os.path.exists(self.log_file):
            os.startfile(self.log_file)
        else:
            messagebox.showinfo("Log Not Found", "No log file found yet.")

if __name__ == "__main__":
    root = tk.Tk()
    app = AIOMaintenanceApp(root)
    root.mainloop()
