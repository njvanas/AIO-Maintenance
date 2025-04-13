import os
import tkinter as tk
from tkinter import messagebox, filedialog
import customtkinter
import requests  # <- Added to make sure PyInstaller includes it

class ScriptManagerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("AIO Maintenance - Script Manager")
        self.root.geometry("1000x600")

        self.text_font = ("Consolas", 12)
        self.script_dir = os.path.join(os.getcwd(), "scripts")
        os.makedirs(self.script_dir, exist_ok=True)

        self.create_widgets()
        self.load_scripts()

    def create_widgets(self):
        self.left_frame = customtkinter.CTkFrame(self.root)
        self.left_frame.pack(side=tk.LEFT, fill=tk.Y)

        self.script_listbox = customtkinter.CTkListbox(self.left_frame, command=self.load_script)
        self.script_listbox.pack(fill=tk.Y, expand=True, padx=10, pady=10)

        self.right_frame = customtkinter.CTkFrame(self.root)
        self.right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

        self.text_editor = customtkinter.CTkTextbox(self.right_frame, font=self.text_font)
        self.text_editor.pack(fill=tk.BOTH, expand=True, padx=10, pady=(10, 0))

        self.save_button = customtkinter.CTkButton(self.right_frame, text="Save", command=self.save_script)
        self.save_button.pack(pady=10)

    def load_scripts(self):
        self.script_listbox.delete(0, tk.END)
        for filename in os.listdir(self.script_dir):
            if filename.endswith((".ps1", ".bat", ".cmd")):
                self.script_listbox.insert(tk.END, filename)

    def load_script(self, filename):
        try:
            with open(os.path.join(self.script_dir, filename), "r", encoding="utf-8") as file:
                content = file.read()
                self.text_editor.delete("1.0", tk.END)
                self.text_editor.insert(tk.END, content)
                self.current_script = filename
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load script:\n{e}")

    def save_script(self):
        try:
            content = self.text_editor.get("1.0", tk.END)
            with open(os.path.join(self.script_dir, self.current_script), "w", encoding="utf-8") as file:
                file.write(content)
            messagebox.showinfo("Success", f"{self.current_script} saved successfully.")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save script:\n{e}")

if __name__ == "__main__":
    customtkinter.set_appearance_mode("System")
    customtkinter.set_default_color_theme("blue")

    root = customtkinter.CTk()
    app = ScriptManagerApp(root)
    root.mainloop()
