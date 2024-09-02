ChangeKeyboardLayout(LocaleID, LayoutID := 1) {
  layout := DllCall("LoadKeyboardLayout", "Str", LocaleID, "Int", LayoutID)
  hwnd := DllCall("GetForegroundWindow")
  pid := DllCall("GetWindowThreadProcessId", "UInt", hwnd, "Ptr", 0)
  DllCall("PostMessage", "UInt", hwnd, "UInt", 0x50, "UInt", 0, "UInt", layout)
}


<^Numpad1:: ChangeKeyboardLayout("00000419", 2) ; RU Second
<^Numpad2:: ChangeKeyboardLayout("00000409", 2) ; EN Second
<^Numpad3:: ChangeKeyboardLayout("00000411", 2) ; JP Google Input
<^Numpad4:: ChangeKeyboardLayout("00000404", 2) ; HK TChinese MS Bopomofo
<^Numpad5:: ChangeKeyboardLayout("00000412", 2) ; KR MS IME
