import base64
import tkinter as tk
from tkinter import filedialog

def save_pdf_from_input():
    # Создаём окно для ввода данных
    root = tk.Tk()
    root.title("Введите данные PDF в Base64")
    
    # Создаём поле для ввода текста
    text_box = tk.Text(root, width=60, height=15)
    text_box.pack(padx=10, pady=10)
    
    # Кнопка для обработки данных
    def process_input():
        b64_data = text_box.get("1.0", tk.END).strip()

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
        file_path = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF files", "*.pdf")])

        if file_path:
            with open(file_path, "wb") as pdf_file:
                pdf_file.write(pdf_bytes)
            print(f"Файл сохранён: {file_path}")
        else:
            print("Сохранение отменено")
        root.quit()  # Закрываем окно после завершения

    # Кнопка для сохранения
    save_button = tk.Button(root, text="Сохранить PDF", command=process_input)
    save_button.pack(pady=10)

    # Запускаем главное окно
    root.mainloop()

if __name__ == "__main__":
    save_pdf_from_input()
