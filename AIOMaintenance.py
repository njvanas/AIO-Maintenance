
import os
import subprocess
import tkinter as tk
from tkinter import messagebox, filedialog

class AIOMaintenanceApp:
    def __init__(self, root):
        self.root = root
        self.root.title("AIO Maintenance")
        self.root.geometry("600x400")
        self.create_widgets()
        self.load_scripts()

    def create_widgets(self):
        self.script_listbox = tk.Listbox(self.root, width=50)
        self.script_listbox.pack(pady=10)

        self.run_button = tk.Button(self.root, text="Run Script", command=self.run_script)
        self.run_button.pack(pady=5)

        self.edit_button = tk.Button(self.root, text="Edit Script", command=self.edit_script)
        self.edit_button.pack(pady=5)

        self.add_button = tk.Button(self.root, text="Add Script", command=self.add_script)
        self.add_button.pack(pady=5)

    def load_scripts(self):
        self.scripts = []
        script_dir = os.path.join(os.getcwd(), "scripts")
        if not os.path.exists(script_dir):
            os.makedirs(script_dir)
        for file in os.listdir(script_dir):
            if file.endswith((".ps1", ".bat", ".cmd")):
                self.scripts.append(file)
                self.script_listbox.insert(tk.END, file)

    def run_script(self):
        selected = self.script_listbox.curselection()
        if selected:
            script_name = self.scripts[selected[0]]
            script_path = os.path.join(os.getcwd(), "scripts", script_name)
            try:
                if script_name.endswith(".ps1"):
                    subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path], check=True)
                else:
                    subprocess.run([script_path], check=True)
            except subprocess.CalledProcessError as e:
                messagebox.showerror("Execution Error", f"An error occurred:\n{e}")
        else:
            messagebox.showwarning("No Selection", "Please select a script to run.")

    def edit_script(self):
        selected = self.script_listbox.curselection()
        if selected:
            script_name = self.scripts[selected[0]]
            script_path = os.path.join(os.getcwd(), "scripts", script_name)
            os.startfile(script_path)
        else:
            messagebox.showwarning("No Selection", "Please select a script to edit.")

    def add_script(self):
        file_path = filedialog.askopenfilename(title="Select Script", filetypes=[("Script Files", "*.ps1 *.bat *.cmd")])
        if file_path:
            dest_path = os.path.join(os.getcwd(), "scripts", os.path.basename(file_path))
            try:
                with open(file_path, 'rb') as src_file:
                    with open(dest_path, 'wb') as dest_file:
                        dest_file.write(src_file.read())
                self.script_listbox.insert(tk.END, os.path.basename(file_path))
                self.scripts.append(os.path.basename(file_path))
            except Exception as e:
                messagebox.showerror("File Error", f"An error occurred while adding the script:\n{e}")

if __name__ == "__main__":
    root = tk.Tk()
    app = AIOMaintenanceApp(root)
    root.mainloop()
