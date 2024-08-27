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
  [["A", "Ф"], "{U+030B}", ["2Акут", "2Acute", "Двойной Акут", "Double Acute", "Двойное ударение"]],
  [["b", "и"], "{U+0306}", ["Бреве", "Бревис", "Breve", "Кратка"]],
  [["B", "И"], "{U+0311}", ["Перевёрнутый бреве", "Перевёрнутый бревис", "Inverted Breve", "Перевёрнутая кратка"]],
  [["c", "с"], "{U+0302}", ["Циркумфлекс", "Circumflex", "Крышечка", "Домик"]],
  [["C", "С"], "{U+030C}", ["Карон", "Caron", "Гачек", "Hachek", "Hacek"]],
  [["d", "в"], "{U+0307}", ["Точка сверху", "Circumflex", "Dot Above"]],
  [["D", "В"], "{U+0308}", ["Диерезис", "Diaeresis", "Умлаут", "Umlaut"]],
]

BindDiacriticF2 := [
  [["b", "и"], "{U+032E}", ["Бреве снизу", "Бревис снизу", "Breve Below", "Кратка снизу"]],
  [["B", "И"], "{U+032F}", ["Перевёрнутый бреве снизу", "Перевёрнутый бревис снизу", "Inverted Breve Below", "Перевёрнутая кратка снизу"]],
  [["c", "с"], "{U+032D}", ["Циркумфлекс снизу", "Circumflex Below", "Крышечка снизу", "Домик снизу"]],
  [["C", "С"], "{U+032C}", ["Карон снизу", "Caron Below", "Гачек снизу", "Hachek Below", "Hacek below"]],
]

BindDiacriticF3 := [
  [["b", "и"], "{U+0346}", ["Мостик сверху", "Bridge Above"]],
  [["B", "И"], "{U+032A}", ["Мостик снизу", "Bridge Below"]],
  [CtrlB, "{U+033A}", ["Перевёрнутый мостик снизу", "Inverted Bridge Below"]],
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
  ["-", "{U+2060}", ["Zero-Width No-Break Space", "ZeroWidthSP", "Word Joiner", "WJoiner", "Неразрывный Пробел Нулевой Ширины", "Соединитель слов"]],
  ["=", "{U+2007}", ["Number Space", "NumSP", "Figure Space", "FigureSP", "Цифровой пробел"]],
  [SpaceKey, "{U+00A0}", ["No-Break Space", "NBSP", "Неразрывный Пробел"]],
]


SuperscriptDictionary := [
  ["1", "{U+00B9}"],
  ["2", "{U+00B2}"],
  ["3", "{U+00B3}"],
  ["4", "{U+2074}"],
  ["5", "{U+2075}"],
  ["6", "{U+2076}"],
  ["7", "{U+2077}"],
  ["8", "{U+2078}"],
  ["9", "{U+2079}"],
  ["0", "{U+2070}"],
  ["+", "{U+207A}"],
  ["-", "{U+207B}"],
  ["=", "{U+207C}"],
  ["(", "{U+207D}"],
  [")", "{U+207E}"],
  ["a", "{U+1D43}"],
  ["b", "{U+1D47}"],
  ["c", "{U+1D9C}"],
  ["d", "{U+1D48}"],
  ["e", "{U+1D49}"],
  ["f", "{U+1DA0}"],
  ["g", "{U+1DA2}"],
  ["k", "{U+1D4F}"],
  ["m", "{U+1D50}"],
  ["n", "{U+207F}"],
  ["o", "{U+1D52}"],
  ["p", "{U+1D56}"],
  ["r", "{U+1D63}"],
  ["t", "{U+1D57}"],
  ["u", "{U+1D58}"],
  ["v", "{U+1D5B}"],
  ["x", "{U+1D61}"],
  ["z", "{U+1DBB}"],
  ["A", "{U+1D2C}"],
  ["B", "{U+1D2E}"],
  ["D", "{U+1D30}"],
  ["E", "{U+1D31}"],
  ["H", "{U+1D34}"],
  ["J", "{U+1D36}"],
  ["I", "{U+1D35}"],
  ["K", "{U+1D37}"],
  ["L", "{U+1D38}"],
  ["M", "{U+1D39}"],
  ["N", "{U+1D3A}"],
  ["O", "{U+1D3C}"],
  ["P", "{U+1D3E}"],
  ["R", "{U+1D3F}"],
  ["T", "{U+1D40}"],
  ["U", "{U+1D41}"],
  ["W", "{U+1D42}"],
]

SubscriptDictionary := [
  ["1", "{U+2081}"],
  ["2", "{U+2082}"],
  ["3", "{U+2083}"],
  ["4", "{U+2084}"],
  ["5", "{U+2085}"],
  ["6", "{U+2086}"],
  ["7", "{U+2087}"],
  ["8", "{U+2088}"],
  ["9", "{U+2089}"],
  ["0", "{U+2080}"],
  ["+", "{U+208A}"],
  ["-", "{U+208B}"],
  ["=", "{U+208C}"],
  ["(", "{U+208D}"],
  [")", "{U+208E}"],
  ["a", "{U+2090}"],
  ["e", "{U+2091}"],
  ["i", "{U+1D62}"],
]


InputBridge(BindsArray) {
  ih := InputHook("L1 C M", "L")
  ih.Start()
  ih.Wait()
  keyPressed := ih.Input
  for index, pair in BindsArray {
    if IsObject(pair[1]) {
      for _, key in pair[1] {
        if (keyPressed == key) {
          Send(pair[2])
          return
        }
      }
    } else {
      if (keyPressed == pair[1]) {
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

  CombineArrays(SearchOfArray, BindDiacriticF1, BindDiacriticF2, BindDiacriticF3, BindSpaces)

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
  Labels["en"].WindowPrompt := "Enter code ID"

  PromptValue := ""
  SearchOfArray := []
  IB := InputBox(Labels[SystemLanguage].WindowPrompt, Labels[SystemLanguage].SearchTitle, "w256 h92")

  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value
  Send("{U+" . PromptValue . "}")
}

ScriptConverter(Dictionary, FromValue) {
  if (FromValue = "")
    return

  ConvertedText := ""
  for index, char in StrSplit(FromValue)
  {
    Found := False
    for pair in Dictionary
    {
      if (char = pair[1])
      {
        ConvertedText .= Chr(0x200C) . pair[2]
        Found := True
        break
      }
    }
    if (!Found)
      ConvertedText .= char
  }
  return ConvertedText
}

SwitchToScript(scriptMode) {
  SystemLanguage := GetSystemLanguage()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  if (scriptMode = "sup") {
    Labels["ru"].SearchTitle := "Верхний индекс"
    Labels["en"].SearchTitle := "Superscript"
  }
  else if (scriptMode = "sub") {
    Labels["ru"].SearchTitle := "Нижний индекс"
    Labels["en"].SearchTitle := "Subscript"
  }
  Labels["ru"].WindowPrompt := "Введите знаки для конвертации"
  Labels["en"].WindowPrompt := "Enter chars for convert"

  PromptValue := ""

  IB := InputBox(Labels[SystemLanguage].WindowPrompt, Labels[SystemLanguage].SearchTitle, "w256 h92")
  if IB.Result = "Cancel"
    return
  else {
    PromptValue := IB.Value
    if (scriptMode = "sup") {
      PromptValue := ScriptConverter(SuperscriptDictionary, PromptValue)
    } else if (scriptMode = "sub") {
      PromptValue := ScriptConverter(SubscriptDictionary, PromptValue)
    }
  }

  Send(PromptValue)
}

InsertAltCodeKey() {
  SystemLanguage := GetSystemLanguage()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "Альт-код"
  Labels["en"].SearchTitle := "Alt Code"
  Labels["ru"].WindowPrompt := "Введите кодовое обозначение"
  Labels["en"].WindowPrompt := "Enter code ID"
  Labels["ru"].Err := "Введите числовое значение"
  Labels["en"].Err := "Enter numeric value"

  PromptValue := ""
  IB := InputBox(Labels[SystemLanguage].WindowPrompt, Labels[SystemLanguage].SearchTitle, "w256 h92")
  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value
  if (PromptValue ~= "^\d+$") {
    SendAltNumpad(PromptValue)
  } else {
    MsgBox(Labels[SystemLanguage].Err, Labels[SystemLanguage].SearchTitle, 0x30)
  }
}

SendAltNumpad(CharacterCode) {
  Send("{Alt Down}")
  Loop Parse, CharacterCode
    Send("{Numpad" A_LoopField "}")
  Send("{Alt Up}")
}

<#<!F1:: InputBridge(BindDiacriticF1)
<#<!F2:: InputBridge(BindDiacriticF2)
<#<!F3:: InputBridge(BindDiacriticF3)
<#<!Space:: InputBridge(BindSpaces)
<#<!f:: SearchKey()
<#<!u:: InsertUnicodeKey()
<#<!a:: InsertAltCodeKey()
<#<!1:: SwitchToScript("sup")
<#<^>!1:: SwitchToScript("sub")


; Setting up of Diacritics-Spaces-Letters KeyPad

LocaliseArrayKeys(ObjectPath) {
  for index, item in ObjectPath {
    if IsObject(item[1]) {
      item[1] := item[1][GetSystemLanguage()]
    }
  }
}

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
  DSLContent["BindList"] := {}
  DSLContent["UI"] := {}
  DSLContent["ru"] := {}
  DSLContent["en"] := {}

  DSLContent["UI"].TabsNCols := [
    [Map(
      "ru", ["Диакритика", "Буквы", "Пробелы", "Команды", "Быстрые ключи", "О программе"],
      "en", ["Diacritics", "Letters", "Spaces", "Commands", "Fast Keys", "About"]
    )],
    [Map(
      "ru", ["Имя", "Ключ", "Вид", "Unicode"],
      "en", ["Name", "Key", "View", "Unicode"]
    )],
  ]
  LocaliseArrayKeys(DSLContent["UI"].TabsNCols)

  SystemLanguage := GetSystemLanguage()

  DSLPadGUI := Gui()

  ColumnWidths := [300, 140, 60, 85]
  ThreeColumnWidths := [300, 140, 145]
  ColumnListStyle := "w620 h460 +NoSort"

  Tab := DSLPadGUI.Add("Tab3", "w650 h500", DSLContent["UI"].TabsNCols[1][1])
  DSLPadGUI.SetFont("s11")
  Tab.UseTab(1)
  DSLContent["BindList"].Diacritics := [
    ["", "Win Alt F1", "", ""],
    [Map("ru", "Акут", "en", "Acute"), "[a][ф]", "◌́", "3001"],
    [Map("ru", "Двойной Акут", "en", "Double Acute"), "[A][Ф]", "◌̋", "030B"],
    [Map("ru", "Кратка", "en", "Breve"), "[b][и]", "◌̆", "0306"],
    [Map("ru", "Перевёрнутая кратка", "en", "Inverted Breve"), "[B][И]", "◌̑", "0311"],
    [Map("ru", "Циркумфлекс", "en", "Circumflex"), "[c][с]", "◌̂", "0302"],
    [Map("ru", "Гачек", "en", "Caron"), "[C][С]", "◌̌", "030C"],
    [Map("ru", "Точка сверху", "en", "Dot Above"), "[d][в]", "◌̇", "0307"],
    [Map("ru", "Диерезис", "en", "Diaeresis"), "[D][В]", "◌̈", "0308"],
    ["", "", "", ""],
    ["", "Win Alt F2", "", ""],
    [Map("ru", "Кратка снизу", "en", "Breve Below"), "[b][и]", "◌̮", "032E"],
    [Map("ru", "Перевёрнутая кратка снизу", "en", "Inverted Breve Below"), "[B][И]", "◌̯", "032F"],
    [Map("ru", "Циркумфлекс снизу", "en", "Circumflex Below"), "[c][с]", "◌̂", "032D"],
    [Map("ru", "Гачек снизу", "en", "Caron Below"), "[C][С]", "◌̌", "032C"],
    ["", "", "", ""],
    ["", "Win Alt F3", "", ""],
    [Map("ru", "Мостик сверху", "en", "Bridge Above"), "[b][и]", "◌͆", "0346"],
    [Map("ru", "Мостик снизу", "en", "Bridge Below"), "[B][И]", "◌̪", "032A"],
    [Map("ru", "Перевёрнутый мостик снизу", "en", "Inverted Bridge Below"), "LCtrl [B][И]", "◌̺", "033A"],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].Diacritics)

  DiacriticLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLContent["UI"].TabsNCols[2][1])
  DiacriticLV.ModifyCol(1, ColumnWidths[1])
  DiacriticLV.ModifyCol(2, ColumnWidths[2])
  DiacriticLV.ModifyCol(3, ColumnWidths[3])
  DiacriticLV.ModifyCol(4, ColumnWidths[4])

  for item in DSLContent["BindList"].Diacritics
  {
    DiacriticLV.Add(, item[1], item[2], item[3], item[4])
  }
  Tab.UseTab(2)

  Tab.UseTab(3)
  DSLContent["BindList"].Spaces := [
    ["", "Win Alt Space", "", ""],
    [Map("ru", "Круглая шпация", "en", "Em Space"), "[1]", "[ ]", "2003"],
    [Map("ru", "Полукруглая шпация", "en", "En Space"), "[2]", "[ ]", "2002"],
    [Map("ru", "⅓ Круглой шпации", "en", "⅓ Em Space"), "[3]", "[ ]", "2004"],
    [Map("ru", "¼ Круглой шпации", "en", "¼ Em Space"), "[4]", "[ ]", "2005"],
    [Map("ru", "Узкий неразрывный пробел", "en", "Narrow No-Break Space"), "[5]", "[ ]", "202F"],
    [Map("ru", "⅙ Круглой шпации", "en", "⅙ Em Space"), "[6]", "[ ]", "2006"],
    [Map("ru", "Узкий пробел", "en", "Thin Space"), "[7]", "[ ]", "2009"],
    [Map("ru", "Волосяная шпация", "en", "Hair Space"), "[8]", "[ ]", "200A"],
    [Map("ru", "Пунктуационный пробел", "en", "Punctuation Space"), "[9]", "[ ]", "2008"],
    [Map("ru", "Пробел нулевой ширины", "en", "Zero-Width Space"), "[0]", "[​]", "200B"],
    [Map("ru", "Соединитель слов", "en", "Word Joiner"), "[-]", "[⁠]", "2060"],
    [Map("ru", "Цифровой пробел", "en", "Figure Space"), "[=]", "[ ]", "2007"],
    [Map("ru", "Неразрывный пробел", "en", "No-Break Space"), "[Space]", "[ ]", "00A0"],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].Spaces)


  SpacesLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLContent["UI"].TabsNCols[2][1])
  SpacesLV.ModifyCol(1, ColumnWidths[1])
  SpacesLV.ModifyCol(2, ColumnWidths[2])
  SpacesLV.ModifyCol(3, ColumnWidths[3])
  SpacesLV.ModifyCol(4, ColumnWidths[4])

  for item in DSLContent["BindList"].Spaces
  {
    SpacesLV.Add(, item[1], item[2], item[3], item[4])
  }

  Tab.UseTab(4)
  DSLContent["BindList"].Commands := [
    [Map("ru", "Поиск по названию", "en", "Find by name"), "Win Alt F", ""],
    [Map("ru", "Вставить по Unicode", "en", "Unicode insertion"), "Win Alt U", ""],
    [Map("ru", "Вставить по Альт-коду", "en", "Alt-code insertion"), "Win Alt A", ""],
    [Map("ru", "Конвертировать в верхний индекс", "en", "Convert into superscript"), "Win LAlt 1", "‌¹‌²‌³‌⁴‌⁵‌⁶‌⁷‌⁸‌⁹‌⁰‌⁽‌⁻‌⁼‌⁾"],
    [Map("ru", "Конвертировать в нижний индекс", "en", "Convert into subscript"), "Win RAlt 1", "‌₁‌₂‌₃‌₄‌₅‌₆‌₇‌₈‌₉‌₀‌₍‌₋‌₌‌₎"],
    [Map("ru", "Активировать быстрые ключи", "en", "Activate fastkeys"), "RAlt Home", ""],
    [Map("ru", " (Ускоренный ввод избранных знаков)", "en", " (Faster input of chosen signs)"), "", ""],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].Commands)

  CommandsLV := DSLPadGUI.Add("ListView", ColumnListStyle,
    [DSLContent["UI"].TabsNCols[2][1][1], DSLContent["UI"].TabsNCols[2][1][2], DSLContent["UI"].TabsNCols[2][1][3]])
  CommandsLV.ModifyCol(1, ThreeColumnWidths[1])
  CommandsLV.ModifyCol(2, ThreeColumnWidths[2])
  CommandsLV.ModifyCol(3, ThreeColumnWidths[3])

  for item in DSLContent["BindList"].Commands
  {
    CommandsLV.Add(, item[1], item[2], item[3])
  }


  Tab.UseTab(5)
  DSLContent["BindList"].FasKeysLV := [
    ["", "LCtrl LAlt", "", ""],
    [Map("ru", "Акут", "en", "Acute"), "[a][ф]", "◌́", "3001"],
    [Map("ru", "Двойной Акут", "en", "Double Acute"), "LShift [a][ф]", "◌̋", "030B"],
    [Map("ru", "Кратка", "en", "Breve"), "[b][и]", "◌̆", "0306"],
    [Map("ru", "Перевёрнутая кратка", "en", "Inverted Breve"), "LShift [b][и]", "◌̑", "0311"],
    [Map("ru", "Циркумфлекс", "en", "Circumflex"), "[c][с]", "◌̂", "0302"],
    [Map("ru", "Гачек", "en", "Caron"), "LShift [c][с]", "◌̌", "030C"],
    [Map("ru", "Точка сверху", "en", "Dot Above"), "[d][в]", "◌̇", "0307"],
    [Map("ru", "Диерезис", "en", "Diaeresis"), "LShift [d][в]", "◌̈", "0308"],
    ["", "", "", ""],
    ["", "RAlt RShift", "", ""],
    [Map("ru", "Круглая шпация", "en", "Em Space"), "[1]", "[ ]", "2003"],
    [Map("ru", "Полукруглая шпация", "en", "En Space"), "[2]", "[ ]", "2002"],
    [Map("ru", "⅓ Круглой шпации", "en", "⅓ Em Space"), "[3]", "[ ]", "2004"],
    [Map("ru", "¼ Круглой шпации", "en", "¼ Em Space"), "[4]", "[ ]", "2005"],
    [Map("ru", "Узкий неразрывный пробел", "en", "Narrow No-Break Space"), "[5]", "[ ]", "202F"],
    [Map("ru", "⅙ Круглой шпации", "en", "⅙ Em Space"), "[6]", "[ ]", "2006"],
    [Map("ru", "Узкий пробел", "en", "Thin Space"), "[7]", "[ ]", "2009"],
    [Map("ru", "Волосяная шпация", "en", "Hair Space"), "[8]", "[ ]", "200A"],
    [Map("ru", "Пунктуационный пробел", "en", "Punctuation Space"), "[9]", "[ ]", "2008"],
    [Map("ru", "Пробел нулевой ширины", "en", "Zero-Width Space"), "[0]", "[​]", "200B"],
    [Map("ru", "Соединитель слов", "en", "Word Joiner"), "[-]", "[⁠]", "2060"],
    [Map("ru", "Цифровой пробел", "en", "Figure Space"), "[=]", "[ ]", "2007"],
    [Map("ru", "Неразрывный пробел", "en", "No-Break Space"), "[Space]", "[ ]", "00A0"],
    ["", "", "", ""],
    [Map("ru", "Верхний индекс", "en", "Superscript"), "LCtrl LAlt [1…0]", "¹²³⁴⁵⁶⁷⁸⁹⁰", ""],
    [Map("ru", "Нижний индекс", "en", "Subscript"), "LCtrl LAlt [1…0]", "₁₂₃₄₅₆₇₈₉₀", ""],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].FasKeysLV)

  FasKeysLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLContent["UI"].TabsNCols[2][1])
  FasKeysLV.ModifyCol(1, ColumnWidths[1])
  FasKeysLV.ModifyCol(2, ColumnWidths[2])
  FasKeysLV.ModifyCol(3, ColumnWidths[3])
  FasKeysLV.ModifyCol(4, ColumnWidths[4])

  for item in DSLContent["BindList"].FasKeysLV
  {
    FasKeysLV.Add(, item[1], item[2], item[3], item[4])
  }


  Tab.UseTab(6)
  DSLContent["ru"].About := {}
  DSLContent["ru"].About.AutoLoadAdd := "Добавить в автозагрузку"
  DSLContent["ru"].About.Title := "DSL KeyPad"
  DSLContent["ru"].About.SubTitle := "Diacritics-Spaces-Letters KeyPad"
  DSLContent["ru"].About.Repository := "Папка AHK репозитория: "
  DSLContent["ru"].About.AuthorGit := "Профиль автора: "
  DSLContent["ru"].About.Texts := [
    "Версия: Альфа от 27.08.2024",
    "Автор: Демер Нкардаз",
    "Примечание: Использовать на русской и английской раскладках",
    "Данная программа предназначена для помощи при вводе специальных символов, таких как диакритические знаки, пробельные символы и видоизменённые буквы. Вы можете использовать горячие клавиши, произвести вставку знака по названию (Win Alt F), если для него существует горячая клавиша, или ввести «сырое» обозначение Unicode (Win Alt U) любого символа.",
    "В данном окне представлены все доступные комбинации клавиш. Двойным нажатием ЛКМ по любой из строк, содержащей Unicode,`nможно перейти на сайт Symbl.cc с обзором соответствующего символа.",
    "Режимы`nОбычный — требует «активации» группы знаков: Win Alt [Группа] (F1, Space…) необходимо нажать, но не удерживать, после чего нажать на символ ключа нужного знака.`nБыстрые ключи — необходимо удерживать модифицирующие клавиши, например, LCtrl LAlt + m, что бы ввести знак макрона [◌̄]."
  ]

  DSLContent["en"].About := {}
  DSLContent["en"].About.AutoLoadAdd := "Add to Autoload"
  DSLContent["en"].About.Title := "DSL KeyPad"
  DSLContent["en"].About.SubTitle := "Diacritics-Spaces-Letters KeyPad"
  DSLContent["en"].About.Repository := "AHK Folder on Repository: "
  DSLContent["en"].About.AuthorGit := "Author’s Profile: "
  DSLContent["en"].About.Texts := [
    "Version: Alpha at 27/08/2024",
    "Author: Demer Nkardaz",
    "Note: Use on Russian or English keyboard layout",
    "This program is created to assist in entering special characters, such as diacritics signs, whitespace characters, and modified letters. You can use hotkeys, insert a symbol by name (Win Alt F), if a hotkey exists for it, or enter the “raw” Unicode key (Win Alt U) of any symbol.",
    "This window displays all available key combinations. Double-clicking the LMB on any line containing Unicode will take you to the Symbl.cc site with an overview of the corresponding symbol."
  ]

  DSLPadGUI.SetFont("s16")
  DSLPadGUI.Add("Text", , DSLContent[SystemLanguage].About.Title)
  DSLPadGUI.SetFont("s11")
  DSLPadGUI.Add("Text", , DSLContent[SystemLanguage].About.SubTitle)

  for item in DSLContent[SystemLanguage].About.Texts
  {
    DSLPadGUI.Add("Text", "w600", item)
  }
  DSLPadGUI.Add("Link", "w600", DSLContent[SystemLanguage].About.Repository . '<a href="https://github.com/DemerNkardaz/Misc-Scripts/tree/main/AutoHotkey2.0">GitHub “Misc-Scripts”</a>')

  DSLPadGUI.Add("Link", "w600", DSLContent[SystemLanguage].About.AuthorGit . '<a href="https://github.com/DemerNkardaz">GitHub</a>; <a href="http://steamcommunity.com/profiles/76561198177249942">STEAM</a>; <a href="https://ficbook.net/authors/4241255">Фикбук</a>')

  ButtonOK := DSLPadGUI.Add("Button", "x454 y30 w200 h32", DSLContent[SystemLanguage].About.AutoLoadAdd)
  ButtonOK.OnEvent("Click", AddScriptToAutoload)

  DiacriticLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  SpacesLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  FasKeysLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)


  DSLPadGUI.Title := DSLPadTitle

  screenWidth := A_ScreenWidth
  screenHeight := A_ScreenHeight

  windowWidth := 650
  windowHeight := 512
  xPos := screenWidth - windowWidth - 40
  yPos := screenHeight - windowHeight - 75

  DSLPadGUI.Show()
  DSLPadGUI.Move(xPos, yPos)

  return DSLPadGUI
}

LV_OpenUnicodeWebsite(LV, RowNumber)
{
  SystemLanguage := GetSystemLanguage()
  SelectedRow := LV.GetText(RowNumber, 4)
  URIComponent := "https://symbl.cc/" . SystemLanguage . "/" . SelectedRow
  if (SelectedRow != "")
  {
    Run(URIComponent)
  }
}


LV_MouseMove(Control, x, y) {
  RowNumber := Control.GetItemAt(x, y)

  if (RowNumber) {
    FileName := Control.GetText(RowNumber, 1)
    FileSize := Control.GetText(RowNumber, 2)
    Tooltip "File Name: " FileName "`nFile Size: " FileSize " KB"
  } else {
    Tooltip
  }
}

AddScriptToAutoload(*) {
  CurrentScriptPath := A_ScriptFullPath
  AutoloadFolder := A_StartMenu "\Programs\Startup"
  ShortcutPath := AutoloadFolder "\DSLKeyPad.lnk"

  if (FileExist(ShortcutPath)) {
    FileDelete(ShortcutPath)
  }

  Command := "powershell -command " "$shell = New-Object -ComObject WScript.Shell; $shortcut = $shell.CreateShortcut('" ShortcutPath "'); $shortcut.TargetPath = '" CurrentScriptPath "'; $shortcut.WorkingDirectory = '" A_ScriptDir "'; $shortcut.Description = 'DSLKeyPad AutoHotkey Script'; $shortcut.Save()" ""
  RunWait(Command)

  MsgBox("Ярлык для автозагрузки создан или обновлен.", DSLPadTitle, 0x40)
}

IsGuiOpen(title)
{
  return WinExist(title) != 0
}

; Fastkeys
ConfigFile := "C:\Users\" . A_UserName . "\DSLKeyPadConfig.ini"

FastKeysIsActive := False

if FileExist(ConfigFile) {
  IniValue := IniRead(ConfigFile, "Settings", "FastKeysIsActive", "False")
  FastKeysIsActive := (IniValue = "True")
} else {
  IniWrite "False", ConfigFile, "Settings", "FastKeysIsActive"
}

<^>!Home::
{
  SystemLanguage := GetSystemLanguage()
  global FastKeysIsActive, ConfigFile
  FastKeysIsActive := !FastKeysIsActive
  IniWrite (FastKeysIsActive ? "True" : "False"), ConfigFile, "Settings", "FastKeysIsActive"

  ActivationMessage := {}
  ActivationMessage[] := Map()
  ActivationMessage["ru"] := {}
  ActivationMessage["en"] := {}
  ActivationMessage["ru"].Active := "Быстрые ключи активированы"
  ActivationMessage["ru"].Deactive := "Быстрые ключи деактивированы"
  ActivationMessage["en"].Active := "Fast keys activated"
  ActivationMessage["en"].Deactive := "Fast keys deactivated"
  MsgBox(FastKeysIsActive ? ActivationMessage[SystemLanguage].Active : ActivationMessage[SystemLanguage].Deactive, "FastKeys", 0x40)

  return
}


HandleFastKey(char)
{
  global FastKeysIsActive
  if (FastKeysIsActive) {
    Send(char)
  }
}


<^<!a:: HandleFastKey("{U+0301}") ; Combining acute
<^<+<!a:: HandleFastKey("{U+030B}") ; Combining double acute
<^<!b:: HandleFastKey("{U+0306}") ; Combining breve
<^<+<!b:: HandleFastKey("{U+0311}") ; Combining inverted breve
<^<!c:: HandleFastKey("{U+0302}") ; Combining circumflex
<^<+<!c:: HandleFastKey("{U+030C}") ; Combining caron
<^<!d:: HandleFastKey("{U+0307}") ; Combining dot above
<^<+<!d:: HandleFastKey("{U+0308}") ; Combining diaeresis
<^<!g:: HandleFastKey("{U+0300}") ; Combining grave
<^<+<!g:: HandleFastKey("{U+030F}") ; Combining double grave
<^<!m:: HandleFastKey("{U+0304}") ; Combining macron
<^<+<!m:: HandleFastKey("{U+0331}") ; Combining macron below


<^<!t:: Send("{U+0303}") ; Combining tilde
<^<+<!t:: Send("{U+0330}") ; Combining tilde below
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

<^<!1:: HandleFastKey("{U+00B9}") ; Superscript 1
<^<!2:: HandleFastKey("{U+00B2}") ; Superscript 2
<^<!3:: HandleFastKey("{U+00B3}") ; Superscript 3
<^<!4:: HandleFastKey("{U+2074}") ; Superscript 4
<^<!5:: HandleFastKey("{U+2075}") ; Superscript 5
<^<!6:: HandleFastKey("{U+2076}") ; Superscript 6
<^<!7:: HandleFastKey("{U+2077}") ; Superscript 7
<^<!8:: HandleFastKey("{U+2078}") ; Superscript 8
<^<!9:: HandleFastKey("{U+2079}") ; Superscript 9
<^<!0:: HandleFastKey("{U+2070}") ; Superscript 0
<^<+<!1:: HandleFastKey("{U+2081}") ; Subscript 1
<^<+<!2:: HandleFastKey("{U+2082}") ; Subscript 2
<^<+<!3:: HandleFastKey("{U+2083}") ; Subscript 3
<^<+<!4:: HandleFastKey("{U+2084}") ; Subscript 4
<^<+<!5:: HandleFastKey("{U+2085}") ; Subscript 5
<^<+<!6:: HandleFastKey("{U+2086}") ; Subscript 6
<^<+<!7:: HandleFastKey("{U+2087}") ; Subscript 7
<^<+<!8:: HandleFastKey("{U+2088}") ; Subscript 8
<^<+<!9:: HandleFastKey("{U+2089}") ; Subscript 9
<^<+<!0:: HandleFastKey("{U+2080}") ; Subscript 0

<^>!>+1:: HandleFastKey("{U+2003}") ; Em Space
<^>!>+2:: HandleFastKey("{U+2002}") ; En Space
<^>!>+3:: HandleFastKey("{U+2004}") ; 1/3 Em Space
<^>!>+4:: HandleFastKey("{U+2005}") ; 1/4 Em Space
<^>!>+5:: HandleFastKey("{U+202F}") ; Thin Nonbreak Space
<^>!>+6:: HandleFastKey("{U+2006}") ; 1/6 Em Space
<^>!>+7:: HandleFastKey("{U+2009}") ; Thin Space
<^>!>+8:: HandleFastKey("{U+200A}") ; Hair Space
<^>!>+9:: HandleFastKey("{U+2008}") ; Punctuation Space
<^>!>+0:: HandleFastKey("{U+200B}") ; Zero-Width Space
<^>!>+-:: HandleFastKey("{U+2060}") ; Zero-Width Nonbreak Space
<^>!>+=:: HandleFastKey("{U+2007}") ; Number Space
<^>!<+Space:: HandleFastKey("{U+00A0}") ; Nonbreak Space

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
