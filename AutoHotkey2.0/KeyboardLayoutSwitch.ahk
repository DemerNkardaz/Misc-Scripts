#Requires Autohotkey v2
#SingleInstance Force

CodeEn := "00000419"
CodeRu := "00000409"
CodeJP := "00000411"
CodeHKTC := "00000404"
CodeKR := "00000412"
CodeAkkad := "0000045A"

ChangeKeyboardLayout(LocaleID, LayoutID := 2) {
	LanguageCode := ""

	if LocaleID == "en" {
		LanguageCode := CodeEn
	} else if LocaleID == "ru" {
		LanguageCode := CodeRu
	} else {
		LanguageCode := LocaleID
	}

	layout := DllCall("LoadKeyboardLayout", "Str", LanguageCode, "Int", LayoutID)
	hwnd := DllCall("GetForegroundWindow")
	pid := DllCall("GetWindowThreadProcessId", "UInt", hwnd, "Ptr", 0)
	DllCall("PostMessage", "UInt", hwnd, "UInt", 0x50, "UInt", 0, "UInt", layout)
}


<^Numpad1:: ChangeKeyboardLayout(CodeEn) ; RU Second
<^Numpad2:: ChangeKeyboardLayout(CodeRu) ; EN Second
<^Numpad3:: ChangeKeyboardLayout(CodeJP) ; JP Google Input
<^Numpad4:: ChangeKeyboardLayout(CodeHKTC) ; HK TChinese MS Bopomofo
<^Numpad5:: ChangeKeyboardLayout(CodeKR) ; KR MS IME
<^Numpad6:: ChangeKeyboardLayout(CodeAkkad) ; Šumeru-Akkaditum Cuneiform
