import base64
import pyperclip
import tkinter as tk
from tkinter import filedialog, messagebox

def convert_from_clipboard():
    """Обрабатывает Base64 из буфера обмена и сохраняет PDF"""
    b64_data = pyperclip.paste().strip()

    # Проверяем и добавляем префикс, если отсутствует
    prefix = "data:application/pdf;base64,"
    if not b64_data.startswith(prefix):
        b64_data = prefix + b64_data

    # Убираем префикс
    b64_data = b64_data[len(prefix):]

    try:
        pdf_bytes = base64.b64decode(b64_data)
    except base64.binascii.Error:
        messagebox.showerror("Ошибка", "Некорректные данные Base64")
        return

    # Окно для выбора пути сохранения
    file_path = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF files", "*.pdf")])

    if file_path:
        with open(file_path, "wb") as pdf_file:
            pdf_file.write(pdf_bytes)
        messagebox.showinfo("Успех", f"Файл сохранён:\n{file_path}")
    else:
        messagebox.showwarning("Отмена", "Сохранение отменено")

def main():
    """Создаёт главное окно с кнопкой"""
    root = tk.Tk()
    root.title("Base64 → PDF")
    root.geometry("400x200")

    label = tk.Label(root, text="Нажмите кнопку, чтобы вставить код\nиз буфера и сохранить PDF", font=("Arial", 12))
    label.pack(pady=20)

    convert_button = tk.Button(root, text="Вставить код и конвертировать", command=convert_from_clipboard, font=("Arial", 12))
    convert_button.pack(pady=10)

    root.mainloop()

if __name__ == "__main__":
    main()
