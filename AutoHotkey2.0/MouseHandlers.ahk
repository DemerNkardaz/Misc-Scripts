#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_class Progman") or WinActive("ahk_class CabinetWClass")
~MButton up::
{
  MouseGetPos , , &Win
  class := WinGetClass(win)
  if (class = "CabinetWClass" or class = "Progman")
  {
    Send("{Click}")
    Sleep(100)
    Send("{F2}")
  }
}

; By Chuck (from Discord)
