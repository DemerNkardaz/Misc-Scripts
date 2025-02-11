#Requires Autohotkey v2
#SingleInstance Force
Persistent

A_IconTip := "Pythons"

PyTray := A_TrayMenu
PyTray.Delete()
PyTray.Add("Python Scripts", (*) => "")
PyTray.Disable("Python Scripts")
PyTray.Add()

SubConvs := Menu()
SubConvs.Add("Base64 to PDF [Clipboard]", (*) => Run(A_ScriptDir "\..\Python\Base64Clip_to_PDF.py"))
SubConvs.Add("Base64 to PDF", (*) => Run(A_ScriptDir "\..\Python\Base64_to_PDF.py"))

PyTray.Add("Converters", SubConvs)


PyTray.Add()
PyTray.Add("Pause", (*) => Pause())
PyTray.Add("Reload", (*) => Reload())
PyTray.Add("Exit", (*) => Exit())

try {
	TraySetIcon("C:\Program Files\Python313\python.exe", 0)
}