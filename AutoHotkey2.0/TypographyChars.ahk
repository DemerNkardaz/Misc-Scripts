#Requires Autohotkey v2
#SingleInstance Force

; Only EN US & RU RU Keyboard Layout

GetSystemLanguage()
{
  langID := RegRead("HKEY_CURRENT_USER\Control Panel\International", "LocaleName")
  langID := SubStr(langID, 1, 2)
  return langID ? langID : "en"
}

CtrlA := Chr(1)
CtrlB := Chr(2)
CtrlC := Chr(3)
CtrlD := Chr(4)
CtrlE := Chr(5)
CtrlF := Chr(6)
CtrlG := Chr(7)
CtrlH := Chr(8)
CtrlI := Chr(9)
CtrlJ := Chr(10)
CtrlK := Chr(11)
CtrlL := Chr(12)
CtrlM := Chr(13)
CtrlN := Chr(14)
CtrlO := Chr(15)
CtrlP := Chr(16)
CtrlQ := Chr(17)
CtrlR := Chr(18)
CtrlS := Chr(19)
CtrlT := Chr(20)
CtrlU := Chr(21)
CtrlV := Chr(22)
CtrlW := Chr(23)
CtrlX := Chr(24)
CtrlY := Chr(25)
CtrlZ := Chr(26)
SpaceKey := Chr(32)

BindDiacriticF1 := [
  [["a", "ф"], "{U+0301}", ["Акут", "Acute", "Ударение"]],
  [["A", "Ф"], "{U+030B}", ["2Акут", "2Acute", "Двойной Акут", "Double Acute", "Двойное Ударение"]],
]

BindSpaces := [
  ["1", "{U+2003}", ["Em Space", "EmSP", "EM_SPACE", "Круглая Шпация"]],
  ["2", "{U+2002}", ["En Space", "EnSP", "EN_SPACE", "Полукруглая Шпация"]],
  ["3", "{U+2004}", ["1/3 Em Space", "1/3EmSP", "13 Em Space", "EmSP13", "1/3_SPACE", "1/3 Круглой Шпация"]],
  ["4", "{U+2005}", ["1/4 Em Space", "1/4EmSP", "14 Em Space", "EmSP14", "1/4_SPACE", "1/4 Круглой Шпация"]],
  ["5", "{U+202F}", ["Thin No-Break Space", "ThinNoBreakSP", "Тонкий Неразрывный Пробел", "Узкий Неразрывный Пробел"]],
  ["6", "{U+2006}", ["1/6 Em Space", "1/6EmSP", "16 Em Space", "EmSP16", "1/6_SPACE", "1/6 Круглой Шпация"]],
  ["7", "{U+2009}", ["Thin Space", "ThinSP", "Тонкий Пробел", "Узкий Пробел"]],
  ["8", "{U+200A}", ["Hair Space", "HairSP", "Волосяная Шпация"]],
  ["9", "{U+2008}", ["Punctuation Space", "PunctuationSP", "Пунктуационный Пробел"]],
  ["0", "{U+200B}", ["Zero-Width Space", "ZeroWidthSP", "Пробел Нулевой Ширины"]],
  ["-", "{U+2060}", ["Zero-Width No-Break Space", "ZeroWidthSP", "Word Joiner", "WJoiner", "Неразрывный Пробел Нулевой Ширины"]],
  [SpaceKey, "{U+00A0}", ["No-Break Space", "NBSP", "Неразрывный Пробел"]],
]

InputBridge(BindsArray) {
  ih := InputHook("L1 M", "L")
  ih.Start()
  ih.Wait()
  keyPressed := ih.Input
  for index, pair in BindsArray {
    if IsObject(pair[1]) {
      for _, key in pair[1] {
        if (keyPressed = key) {
          Send(pair[2])
          return
        }
      }
    } else {
      if (keyPressed = pair[1]) {
        Send(pair[2])
        return
      }
    }
  }
  ih.Stop()
}

CombineArrays(destinationArray, sourceArray*)
{
  for array in sourceArray
  {
    for value in array
    {
      destinationArray.Push(value)
    }
  }
}

SearchKey() {
  SystemLanguage := GetSystemLanguage()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "Поиск знака"
  Labels["en"].SearchTitle := "Search symbol"
  Labels["ru"].WindowPrompt := "Введите название знака"
  Labels["en"].WindowPrompt := "Enter symbol name"

  PromptValue := ""
  SearchOfArray := []
  IB := InputBox(Labels[SystemLanguage].WindowPrompt, Labels[SystemLanguage].SearchTitle, "w256 h92")

  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value

  CombineArrays(SearchOfArray, BindDiacriticF1, BindSpaces)

  Found := False
  for index, pair in SearchOfArray {
    if IsObject(pair[3]) {
      for _, key in pair[3] {
        if (StrLower(PromptValue) = StrLower(key)) {
          Send(pair[2])
          Found := True
          break 2
        }
      }
    }
  }

  if !Found {
    MsgBox "Знак не найден."
  }
}

InsertUnicodeKey() {
  SystemLanguage := GetSystemLanguage()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "UNICODE"
  Labels["en"].SearchTitle := "UNICODE"
  Labels["ru"].WindowPrompt := "Введите кодовое обозначение"
  Labels["en"].WindowPrompt := "Enter code name"

  PromptValue := ""
  SearchOfArray := []
  IB := InputBox(Labels[SystemLanguage].WindowPrompt, Labels[SystemLanguage].SearchTitle, "w256 h92")

  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value
  Send("{U+" . PromptValue . "}")
}

<#<!F1:: InputBridge(BindDiacriticF1)
<#<!Space:: InputBridge(BindSpaces)
<#<!f:: SearchKey()
<#<!u:: InsertUnicodeKey()


; Setting up of Diacritics-Spaces-Letters KeyPad

DSLPadTitle := "DSL KeyPad (αλφα)"
<#<!Home::
{
  if (IsGuiOpen(DSLPadTitle))
  {
    WinActivate(DSLPadTitle)
  }
  else
  {
    DSLPadGUI := Constructor()
    DSLPadGUI.Show()
  }
}

Constructor()
{
  DSLContent := {}
  DSLContent[] := Map()
  DSLContent["ru"] := {}
  DSLContent["en"] := {}
  DSLContent["ru"].TabTitles := ["Диакритика", "Буквы", "Пробелы"]
  DSLContent["en"].TabTitles := ["Diacritics", "Letters", "Spaces"]
  DSLContent["ru"].BindListTitle := ["Имя", "Ключ", "Вид", "Unicode"]
  DSLContent["ru"].BindList := {}
  DSLContent["ru"].BindList.Diacritics := [
    ["", "Win Alt F1", "", ""],
    ["Акут", "[a][ф]", "◌́", "3001"],
    ["Двойной Акут", "[A][Ф]", "◌̋", "030B"]
  ]

  SystemLanguage := GetSystemLanguage()

  DSLPadGUI := Gui()

  Tab := DSLPadGUI.Add("Tab3", "x8 y8 w458 h500", DSLContent[SystemLanguage].TabTitles)
  DSLPadGUI.SetFont("s11")
  Tab.UseTab(1)
  DiacriticLV := DSLPadGUI.Add("ListView", "w435 h460", DSLContent[SystemLanguage].BindListTitle)
  DiacriticLV.ModifyCol(1, 140)
  DiacriticLV.ModifyCol(2, 140)
  DiacriticLV.ModifyCol(3, 60)
  DiacriticLV.ModifyCol(4, 85)

  for item in DSLContent[SystemLanguage].BindList.Diacritics
  {
    DiacriticLV.Add(, item[1], item[2], item[3], item[4])
  }


  Tab.UseTab()
  DSLPadGUI.Title := DSLPadTitle

  screenWidth := A_ScreenWidth
  screenHeight := A_ScreenHeight

  windowWidth := 470
  windowHeight := 512
  xPos := screenWidth - windowWidth - 25
  yPos := screenHeight - windowHeight - 75

  DSLPadGUI.Show()
  DSLPadGUI.Move(xPos, yPos)

  return DSLPadGUI
}

IsGuiOpen(title)
{
  return WinExist(title) != 0
}


<^<!m:: Send("{U+0304}") ; Combining macron
<^<+<!m:: Send("{U+0331}") ; Combining macron below
<^<!b:: Send("{U+0306}") ; Combining breve
<^<+<!b:: Send("{U+0311}") ; Combining inverted breve
<^<!c:: Send("{U+0302}") ; Combining circumflex
<^<+<!c:: Send("{U+030C}") ; Combining caron
<^<!a:: Send("{U+0301}") ; Combining acute
<^<+<!a:: Send("{U+030B}") ; Combining double acute
<^<!g:: Send("{U+0300}") ; Combining grave
<^<+<!g:: Send("{U+030F}") ; Combining double grave
<^<!t:: Send("{U+0303}") ; Combining tilde
<^<+<!t:: Send("{U+0330}") ; Combining tilde below
<^<!d:: Send("{U+0307}") ; Combining dot above
<^<+<!d:: Send("{U+0308}") ; Combining diaeresis
<^<!r:: Send("{U+030A}") ; Combining ring above
<^<+<!r:: Send("{U+0325}") ; Combining ring below

<^<!l:: Send("{U+0332}") ; Combining low line
<^<+<!l:: Send("{U+0333}") ; Combining double low line

<^<!p:: Send("{U+0321}") ; Combining palatilized hook below
<^<+<!p:: Send("{U+0322}") ; Combining retroflex hood below

<^<!o:: Send("{U+0305}") ; Combining overline
<^<!h:: Send("{U+0309}") ; Combining hook above
<^<+<!h:: Send("{U+031B}") ; Combining horn
<^<!v:: Send("{U+030D}") ; Combining vertical line above
<^<+<!v:: Send("{U+030E}") ; Combining double vertical line above

<^<!,:: Send("{U+0326}") ; Combining comma below
>^>!,:: Send("{U+0313}") ; Combining comma above
>^>+>!,:: Send("{U+0314}") ; Combining reversed comma aboves
<^<!/:: Send("{U+0312}") ; Combining turned comma above

<^<!.:: Send("{U+0323}") ; Combining dot belowВ
<^<+<!.:: Send("{U+0324}") ; Combining diaeresis below

>^>!x:: Send("{U+0327}") ; Combining cedilla
>^>!c:: Send("{U+032D}") ; Combining circumflex
>^>+>!c:: Send("{U+032C}") ; Combining caron
>^>!o:: Send("{U+0327}") ; Combining ogonek
>^>!b:: Send("{U+032E}") ; Combining breve below
>^>+>!b:: Send("{U+032F}") ; Combining inverted breve below
>^>!v:: Send("{U+0329}") ; Combining vertical line below
>^>+>!v:: Send("{U+030E}") ; Combining double vertical line below

>^b:: Send("{U+0346}") ; Combining bridge above
>^>+b:: Send("{U+032A}") ; Combining bridge below

<^<!1:: Send("{U+00B9}") ; Superscript 1
<^<!2:: Send("{U+00B2}") ; Superscript 2
<^<!3:: Send("{U+00B3}") ; Superscript 3
<^<!4:: Send("{U+2074}") ; Superscript 4
<^<!5:: Send("{U+2075}") ; Superscript 5
<^<!6:: Send("{U+2076}") ; Superscript 6
<^<!7:: Send("{U+2077}") ; Superscript 7
<^<!8:: Send("{U+2078}") ; Superscript 8
<^<!9:: Send("{U+2079}") ; Superscript 9
<^<!0:: Send("{U+2070}") ; Superscript 0
<^<+<!1:: Send("{U+2081}") ; Subscript 1
<^<+<!2:: Send("{U+2082}") ; Subscript 2
<^<+<!3:: Send("{U+2083}") ; Subscript 3
<^<+<!4:: Send("{U+2084}") ; Subscript 4
<^<+<!5:: Send("{U+2085}") ; Subscript 5
<^<+<!6:: Send("{U+2086}") ; Subscript 6
<^<+<!7:: Send("{U+2087}") ; Subscript 7
<^<+<!8:: Send("{U+2088}") ; Subscript 8
<^<+<!9:: Send("{U+2089}") ; Subscript 9
<^<+<!0:: Send("{U+2080}") ; Subscript 0

<^>!>+1:: Send("{U+2003}") ; Em Space
<^>!>+2:: Send("{U+2002}") ; En Space
<^>!>+3:: Send("{U+2004}") ; 1/3 Em Space
<^>!>+4:: Send("{U+2005}") ; 1/4 Em Space
<^>!>+6:: Send("{U+2006}") ; 1/6 Em Space
<^>!>+7:: Send("{U+2009}") ; Thin Space
<^>!>+8:: Send("{U+200A}") ; Hair Space
<^>!>+9:: Send("{U+2008}") ; Punctuation Space
<^>!>+0:: Send("{U+200B}") ; Zero-Width Space
<^>!>+-:: Send("{U+2060}") ; Zero-Width Nonbreak Space
<^>!>+NumpadIns:: Send("{U+2007}") ; Number Space

<^>!<+Space:: Send("{U+202F}") ; Thin Nonbreak Space

<^>!m:: Send("{U+2212}") ; Minus


<^>!NumpadMult:: Send("{U+2051}") ; Double Asterisk
<^>!>+NumpadMult:: Send("{U+2042}") ; Asterism
<^>!<+NumpadMult:: Send("{U+204E}") ; Asterisk Below
<^>!NumpadDiv:: Send("{U+2020}") ; Dagger
<^>!>+NumpadDiv:: Send("{U+2021}") ; Double Dagger

<^>!NumpadSub:: Send("{U+00AD}") ; Soft hyphenation

<#[:: Send("{U+300C}") ; Single Asian Quotes
<#<+[:: Send("{U+300E}") ; Double Asian Quotes
<#]:: Send("{U+300D}") ; Single Asian Quotes End
<#<+]:: Send("{U+300F}") ; Double Asian Quotes End

<#<^[:: Send("{U+FE41}") ; Vertical Single Asian Quotes
<#<^<+[:: Send("{U+FE43}") ; Vertical Double Asian Quotes
<#<^]:: Send("{U+FE42}") ; Vertical Single Asian Quotes End
<#<^<+]:: Send("{U+FE44}") ; Vertical Double Asian Quotes End

<^<!e:: Send("{U+045E}") ; Cyrillic u with breve
<^<+<!e:: Send("{U+040E}") ; Cyrillic cap u with breve
<^<!w:: Send("{U+04EF}") ; Cyrillic u with macron
<^<+<!w:: Send("{U+04EE}") ; Cyrillic cap u with macron
<^<!q:: Send("{U+04E3}") ; Cyrillic i with macron
<^<+<!q:: Send("{U+04E2}") ; Cyrillic cap i with macron

<^<!x:: Send("{U+04AB}") ; CYRILLIC SMALL LETTER ES WITH DESCENDER
<^<+<!x:: Send("{U+04AA}") ; CYRILLIC CAPITAL LETTER ES WITH DESCENDER
