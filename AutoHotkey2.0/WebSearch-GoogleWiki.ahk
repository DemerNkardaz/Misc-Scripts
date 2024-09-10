#Requires Autohotkey v2
#SingleInstance Force

Hotkey("<#SC022", (*) => WebSearch())
Hotkey("<#SC011", (*) => WebSearch("WikipediaRU"))
Hotkey("<#<+SC011", (*) => WebSearch("WikipediaEN"))

WebSearch(Mode := "Google") {
  BackupClipboard := A_Clipboard
  PromptValue := ""
  A_Clipboard := ""

  Send("^c")
  Sleep 120
  PromptValue := A_Clipboard

  if (PromptValue != "") {
    if (Mode = "Google") {
      Run("https://www.google.com/search?q=" . PromptValue)
    } else if (Mode = "WikipediaRU") {
      Run("https://ru.wikipedia.org/w/index.php?search=" . PromptValue)
    } else if (Mode = "WikipediaEN") {
      Run("https://en.wikipedia.org/w/index.php?search=" . PromptValue)
    }
  }

  A_Clipboard := BackupClipboard
}