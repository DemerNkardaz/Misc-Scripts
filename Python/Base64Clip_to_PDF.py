import base64
import pyperclip
import tkinter as tk
from tkinter import filedialog

def save_pdf_from_clipboard():
    # Получаем данные из буфера обмена
    b64_data = pyperclip.paste().strip()
    
    # Проверяем и добавляем префикс, если отсутствует
    prefix = "data:application/pdf;base64,"
    if not b64_data.startswith(prefix):
        b64_data = prefix + b64_data
    
    # Убираем префикс для декодирования
    b64_data = b64_data[len(prefix):]
    
    try:
        pdf_bytes = base64.b64decode(b64_data)
    except base64.binascii.Error:
        print("Ошибка: некорректные данные Base64")
        return
    
    # Окно для выбора пути сохранения
    root = tk.Tk()
    root.withdraw()  # Скрываем главное окно
    file_path = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF files", "*.pdf")])
    
    if file_path:
        with open(file_path, "wb") as pdf_file:
            pdf_file.write(pdf_bytes)
        print(f"Файл сохранён: {file_path}")
    else:
        print("Сохранение отменено")

if __name__ == "__main__":
    save_pdf_from_clipboard()
