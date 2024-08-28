#Requires Autohotkey v2
#SingleInstance Force

; Only EN US & RU RU Keyboard Layout

ConfigFile := "C:\Users\" . A_UserName . "\DSLKeyPadConfig.ini"

FastKeysIsActive := False
InputHTMLEntities := False

DefaultConfig := [
  ["Settings", "FastKeysIsActive", "False"],
  ["Settings", "InputHTMLEntities", "False"],
  ["Settings", "UserLanguage", ""],
  ["LatestPrompts", "Unicode", ""],
  ["LatestPrompts", "Altcode", ""],
  ["LatestPrompts", "Search", ""],
  ["LatestPrompts", "Ligature", ""],
]

if FileExist(ConfigFile) {
  isFastKeysEnabled := IniRead(ConfigFile, "Settings", "FastKeysIsActive", "False")
  isInputHTMLEntities := IniRead(ConfigFile, "Settings", "InputHTMLEntities", "False")

  FastKeysIsActive := (isFastKeysEnabled = "True")
  InputHTMLEntities := (isInputHTMLEntities = "True")
} else {
  for index, config in DefaultConfig {
    IniWrite config[3], ConfigFile, config[1], config[2]
  }
}


GetLanguageCode()
{
  SupportedLanguages := [
    "en",
    "ru",
  ]

  ValidateLanguage(LanguageSource) {
    for language in SupportedLanguages {
      if (LanguageSource = language) {
        return language
      }
    }

    return "en"
  }

  UserLanguageKey := IniRead(ConfigFile, "Settings", "UserLanguage", "")

  if (UserLanguageKey != "") {
    return ValidateLanguage(UserLanguageKey)
  }
  else {
    SysLanguageKey := RegRead("HKEY_CURRENT_USER\Control Panel\International", "LocaleName")
    SysLanguageKey := SubStr(SysLanguageKey, 1, 2)

    return ValidateLanguage(SysLanguageKey)
  }
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


CharCodes := {}
CharCodes.acute := ["{U+0301}", "&#769;"]
CharCodes.dacute := ["{U+030B}", "&#779;"]
CharCodes.acutebelow := ["{U+0317}", "&#791;"]
CharCodes.breve := ["{U+0306}", "&#774;"]
CharCodes.brevebelow := ["{U+032E}", "&#814;"]
CharCodes.ibreve := ["{U+0311}", "&#785;"]
CharCodes.ibrevebelow := ["{U+032F}", "&#815;"]
CharCodes.circumflex := ["{U+0302}", "&#770;"]
CharCodes.circumflexbelow := ["{U+032D}", "&#813;"]
CharCodes.caron := ["{U+030C}", "&#780;"]
CharCodes.caronbelow := ["{U+032C}", "&#812;"]
CharCodes.diaeresis := ["{U+0308}", "&#776;"]
CharCodes.dotabove := ["{U+0307}", "&#775;"]
CharCodes.fermata := ["{U+0352}", "&#850;"]
CharCodes.grave := ["{U+0300}", "&#768;"]
CharCodes.gravebelow := ["{U+0316}", "&#790;"]
CharCodes.dgrave := ["{U+030F}", "&#783;"]
CharCodes.hookabove := ["{U+0309}", "&#777;"]
CharCodes.horn := ["{U+031B}", "&#795;"]
CharCodes.phookbelow := ["{U+0321}", "&#801;"]
CharCodes.rhookbelow := ["{U+0322}", "&#802;"]
CharCodes.bridgeabove := ["{U+0346}", "&#838;"]
CharCodes.bridgebelow := ["{U+032A}", "&#810;"]
CharCodes.ibridgebelow := ["{U+033A}", "&#825;"]

CharCodes.macron := ["{U+0304}", "&#772;"]
CharCodes.macronbelow := ["{U+0331}", "&#817;"]

CharCodes.grapjoiner := ["{U+034F}", "&#847;"]


CharCodes.emsp := ["{U+2003}", "&emsp;"]
CharCodes.ensp := ["{U+2002}", "&ensp;"]
CharCodes.emsp13 := ["{U+2004}", "&emsp13;"]
CharCodes.emsp14 := ["{U+2005}", "&emsp14;"]
CharCodes.emsp16 := ["{U+2006}", "&#8198;"]
CharCodes.nnbsp := ["{U+202F}", "&#8239;"]
CharCodes.thinsp := ["{U+2009}", "&#ThinSpace;"]
CharCodes.hairsp := ["{U+200A}", "&#8202;"]
CharCodes.puncsp := ["{U+2008}", "&puncsp;"]
CharCodes.zwsp := ["{U+200B}", "&#8203;"]
CharCodes.wj := ["{U+2060}", "&NoBreak;"]
CharCodes.numsp := ["{U+2007}", "&numsp;"]
CharCodes.nbsp := ["{U+00A0}", "&nbsp;"]

UniTrim(str) {
  return SubStr(str, 4, StrLen(str) - 4)
}

BindDiacriticF1 := [
  [["a", "ф"], CharCodes.acute, ["Акут", "Acute", "Ударение"]],
  [["A", "Ф"], CharCodes.dacute, ["2Акут", "2Acute", "Двойной Акут", "Double Acute", "Двойное ударение"]],
  [["b", "и"], CharCodes.breve, ["Бреве", "Бревис", "Breve", "Кратка"]],
  [["B", "И"], CharCodes.ibreve, ["Перевёрнутый бреве", "Перевёрнутый бревис", "Inverted Breve", "Перевёрнутая кратка"]],
  [["c", "с"], CharCodes.circumflex, ["Циркумфлекс", "Circumflex", "Крышечка", "Домик"]],
  [["C", "С"], CharCodes.caron, ["Карон", "Caron", "Гачек", "Hachek", "Hacek"]],
  [["d", "в"], CharCodes.dotabove, ["Точка сверху", "Dot Above"]],
  [["D", "В"], CharCodes.diaeresis, ["Диерезис", "Diaeresis", "Умлаут", "Umlaut"]],
  [["f", "а"], CharCodes.fermata, ["Фермата", "Fermata"]],
  [["g", "п"], CharCodes.grave, ["Гравис", "Grave"]],
  [["G", "П"], CharCodes.dgrave, ["2Гравис", "Двойной Гравис", "2Grave", "Double Grave"]],
  [["h", "р"], CharCodes.hookabove, ["Хвостик сверху", "Hook Above"]],
  [["H", "Р"], CharCodes.horn, ["Рожок", "Horn"]],
]

BindDiacriticF2 := [
  [["a", "ф"], CharCodes.acutebelow, ["Акут снизу", "Acute Below", "Ударение снизу"]],
  [["b", "и"], CharCodes.brevebelow, ["Бреве снизу", "Бревис снизу", "Breve Below", "Кратка снизу"]],
  [["B", "И"], CharCodes.ibrevebelow, ["Перевёрнутый бреве снизу", "Перевёрнутый бревис снизу", "Inverted Breve Below", "Перевёрнутая кратка снизу"]],
  [["c", "с"], CharCodes.circumflexbelow, ["Циркумфлекс снизу", "Circumflex Below", "Крышечка снизу", "Домик снизу"]],
  [["C", "С"], CharCodes.caronbelow, ["Карон снизу", "Caron Below", "Гачек снизу", "Hachek Below", "Hacek below"]],
  [["g", "п"], CharCodes.gravebelow, ["Гравис снизу", "Grave Below"]],
  [["h", "р"], CharCodes.phookbelow, ["Палатальный крюк", "Palatalized Hook Below"]],
  [["H", "Р"], CharCodes.rhookbelow, ["Ретрофлексный крюк", "Retroflex Hook Below"]],
]

BindDiacriticF3 := [
  [["b", "и"], CharCodes.bridgeabove, ["Мостик сверху", "Bridge Above"]],
  [["B", "И"], CharCodes.bridgebelow, ["Мостик снизу", "Bridge Below"]],
  [CtrlB, CharCodes.ibridgebelow, ["Перевёрнутый мостик снизу", "Inverted Bridge Below"]],
]

BindSpaces := [
  ["1", CharCodes.emsp, ["Em Space", "EmSP", "EM_SPACE", "Круглая Шпация"]],
  ["2", CharCodes.ensp, ["En Space", "EnSP", "EN_SPACE", "Полукруглая Шпация"]],
  ["3", CharCodes.emsp13, ["1/3 Em Space", "1/3EmSP", "13 Em Space", "EmSP13", "1/3_SPACE", "1/3 Круглой Шпация"]],
  ["4", CharCodes.emsp14, ["1/4 Em Space", "1/4EmSP", "14 Em Space", "EmSP14", "1/4_SPACE", "1/4 Круглой Шпация"]],
  ["5", CharCodes.nnbsp, ["Thin No-Break Space", "ThinNoBreakSP", "Тонкий Неразрывный Пробел", "Узкий Неразрывный Пробел"]],
  ["6", CharCodes.emsp16, ["1/6 Em Space", "1/6EmSP", "16 Em Space", "EmSP16", "1/6_SPACE", "1/6 Круглой Шпация"]],
  ["7", CharCodes.thinsp, ["Thin Space", "ThinSP", "Тонкий Пробел", "Узкий Пробел"]],
  ["8", CharCodes.hairsp, ["Hair Space", "HairSP", "Волосяная Шпация"]],
  ["9", CharCodes.puncsp, ["Punctuation Space", "PunctuationSP", "Пунктуационный Пробел"]],
  ["0", CharCodes.zwsp, ["Zero-Width Space", "ZeroWidthSP", "Пробел Нулевой Ширины"]],
  ["-", CharCodes.wj, ["Zero-Width No-Break Space", "ZeroWidthSP", "Word Joiner", "WJoiner", "Неразрывный Пробел Нулевой Ширины", "Соединитель слов"]],
  ["=", CharCodes.numsp, ["Number Space", "NumSP", "Figure Space", "FigureSP", "Цифровой пробел"]],
  [SpaceKey, CharCodes.nbsp, ["No-Break Space", "NBSP", "Неразрывный Пробел"]],
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

LigaturesDictionary := [
  ["AA", "{U+A732}"],
  ["aa", "{U+A733}"],
  ["AE", "{U+00C6}"],
  ["ae", "{U+00E6}"],
  ["AU", "{U+A736}"],
  ["au", "{U+A737}"],
  ["OE", "{U+0152}"],
  ["oe", "{U+0153}"],
  ["ff", "{U+FB00}"],
  ["ff", "{U+FB00}"],
  ["fl", "{U+FB02}"],
  ["fi", "{U+FB01}"],
  ["fti", "{U+FB05}"],
  ["ffi", "{U+FB03}"],
  ["ffl", "{U+FB04}"],
  ["st", "{U+FB06}"],
  ["ts", "{U+02A6}"],
  ["IJ", "{U+0132}"],
  ["ij", "{U+0133}"],
  ["LJ", "{U+01C7}"],
  ["Lj", "{U+01C8}"],
  ["lj", "{U+01C9}"],
  ["fs", "{U+00DF}"],
  ["Fs", "{U+1E9E}"],
  ["ue", "{U+1D6B}"],
  ["OO", "{U+A74E}"],
  ["oo", "{U+A74F}"],
  ["ie", "{U+AB61}"],
  ["IЄ", "{U+0464}"],
  ["iє", "{U+0465}"],
  ["Iѣ", "{U+A652}"],
  ["iѣ", "{U+A653}"],
  ["IА", "{U+A656}"],
  ["iа", "{U+A657}"],
  ["IѪ", "{U+046C}"],
  ["iѫ", "{U+046D}"],
  ["IѦ", "{U+0468}"],
  ["iѧ", "{U+0469}"],
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
          if IsObject(pair[2]) {
            if InputHTMLEntities {
              SendText(pair[2][2])
            } else {
              Send(pair[2][1])
            }
          } else {
            Send(pair[2])
          }
          return
        }
      }
    } else {
      if (keyPressed == pair[1]) {
        if IsObject(pair[2]) {
          if InputHTMLEntities {
            SendText(pair[2][2])
          } else {
            Send(pair[2][1])
          }
        } else {
          Send(pair[2])
        }
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
  LanguageCode := GetLanguageCode()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "Поиск знака"
  Labels["en"].SearchTitle := "Search symbol"
  Labels["ru"].WindowPrompt := "Введите название знака"
  Labels["en"].WindowPrompt := "Enter symbol name"

  PromptValue := IniRead(ConfigFile, "LatestPrompts", "Search", "")
  SearchOfArray := []
  IB := InputBox(Labels[LanguageCode].WindowPrompt, Labels[LanguageCode].SearchTitle, "w256 h92", PromptValue)

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
          if IsObject(pair[2]) {
            if InputHTMLEntities {
              SendText(pair[2][2])
            } else {
              Send(pair[2][1])
            }
          } else {
            Send(pair[2])
          }
          IniWrite PromptValue, ConfigFile, "LatestPrompts", "Search"
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
  LanguageCode := GetLanguageCode()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "UNICODE"
  Labels["en"].SearchTitle := "UNICODE"
  Labels["ru"].WindowPrompt := "Введите кодовое обозначение"
  Labels["en"].WindowPrompt := "Enter code ID"

  PromptValue := IniRead(ConfigFile, "LatestPrompts", "Unicode", "")
  IB := InputBox(Labels[LanguageCode].WindowPrompt, Labels[LanguageCode].SearchTitle, "w256 h92", PromptValue)

  if IB.Result = "Cancel"
    return

  PromptValue := IB.Value
  UnicodeCodes := StrSplit(PromptValue, " ")

  Output := ""
  for code in UnicodeCodes {
    if code
      Output .= Chr("0x" . code)
  }

  Send(Output)
  IniWrite PromptValue, ConfigFile, "LatestPrompts", "Unicode"
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
  LanguageCode := GetLanguageCode()
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

  IB := InputBox(Labels[LanguageCode].WindowPrompt, Labels[LanguageCode].SearchTitle, "w256 h92")
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
  LanguageCode := GetLanguageCode()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "Альт-коды"
  Labels["en"].SearchTitle := "Alt Codes"
  Labels["ru"].WindowPrompt := "Введите кодовые обозначения через пробел"
  Labels["en"].WindowPrompt := "Enter code IDs separated by spaces"
  Labels["ru"].Err := "Введите числовые значения через пробел"
  Labels["en"].Err := "Enter numeric values separated by spaces"

  PromptValue := IniRead(ConfigFile, "LatestPrompts", "Altcode", "")
  IB := InputBox(Labels[LanguageCode].WindowPrompt, Labels[LanguageCode].SearchTitle, "w256 h92", PromptValue)
  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value

  ; Разделяем введенные значения на массив
  AltCodes := StrSplit(PromptValue, " ")

  ; Отправляем каждый код поочередно
  for code in AltCodes {
    if (code ~= "^\d+$") {
      SendAltNumpad(code)
    } else {
      MsgBox(Labels[LanguageCode].Err, Labels[LanguageCode].SearchTitle, 0x30)
      return
    }
  }

  IniWrite PromptValue, ConfigFile, "LatestPrompts", "Altcode"
}

SendAltNumpad(CharacterCode) {
  Send("{Alt Down}")
  Loop Parse, CharacterCode
    Send("{Numpad" A_LoopField "}")
  Send("{Alt Up}")
}

Ligaturise() {
  LanguageCode := GetLanguageCode()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "Лигатуризатор"
  Labels["en"].SearchTitle := "Ligaturise"
  Labels["ru"].WindowPrompt := "Введите комбинацию для лигатуры"
  Labels["en"].WindowPrompt := "Enter combination for ligature"
  Labels["ru"].Err := "Лигатуры не найдено"
  Labels["en"].Err := "Ligatures not found"

  PromptValue := IniRead(ConfigFile, "LatestPrompts", "Ligature", "")
  IB := InputBox(Labels[LanguageCode].WindowPrompt, Labels[LanguageCode].SearchTitle, "w256 h92", PromptValue)
  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value
  Found := False
  for index, pair in LigaturesDictionary {
    if (PromptValue == pair[1]) {
      Send(pair[2])
      IniWrite PromptValue, ConfigFile, "LatestPrompts", "Ligature"
      Found := True
      return
    }
  }
  if (!Found) {
    MsgBox(Labels[LanguageCode].Err, Labels[LanguageCode].SearchTitle, 0x30)
  }
}


<#<!F1:: InputBridge(BindDiacriticF1)
<#<!F2:: InputBridge(BindDiacriticF2)
<#<!F3:: InputBridge(BindDiacriticF3)
<#<!Space:: InputBridge(BindSpaces)
<#<!f:: SearchKey()
<#<!u:: InsertUnicodeKey()
<#<!a:: InsertAltCodeKey()
<#<!l:: Ligaturise()
<#<!1:: SwitchToScript("sup")
<#<^>!1:: SwitchToScript("sub")


; Setting up of Diacritics-Spaces-Letters KeyPad

LocaliseArrayKeys(ObjectPath) {
  for index, item in ObjectPath {
    if IsObject(item[1]) {
      item[1] := item[1][GetLanguageCode()]
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


SwitchLanguage(LanguageCode) {
  IniWrite LanguageCode, ConfigFile, "Settings", "UserLanguage"

  if (IsGuiOpen(DSLPadTitle))
  {
    WinClose(DSLPadTitle)
  }

  DSLPadGUI := Constructor()
  DSLPadGUI.Show()
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
      "ru", ["Диакритика", "Буквы", "Пробелы", "Команды", "Быстрые ключи", "О программе", "Полезное"],
      "en", ["Diacritics", "Letters", "Spaces", "Commands", "Fast Keys", "About", "Useful"]
    )],
    [Map(
      "ru", ["Имя", "Ключ", "Вид", "Unicode"],
      "en", ["Name", "Key", "View", "Unicode"]
    )],
  ]
  LocaliseArrayKeys(DSLContent["UI"].TabsNCols)

  LanguageCode := GetLanguageCode()

  DSLPadGUI := Gui()


  ColumnWidths := [300, 140, 60, 85]
  ThreeColumnWidths := [300, 140, 145]
  ColumnAreaWidth := "w620"
  ColumnAreaHeight := "h510"
  ColumnAreaRules := "+NoSort -Multi"
  ColumnListStyle := ColumnAreaWidth . " " . ColumnAreaHeight . " " . ColumnAreaRules

  Tab := DSLPadGUI.Add("Tab3", "w650 h550", DSLContent["UI"].TabsNCols[1][1])
  DSLPadGUI.SetFont("s11")
  Tab.UseTab(1)
  DSLContent["BindList"].Diacritics := [
    ["", "Win Alt F1", "", ""],
    [Map("ru", "Акут", "en", "Acute"), "[a][ф]", "◌́", UniTrim(CharCodes.acute[1])],
    [Map("ru", "Двойной Акут", "en", "Double Acute"), "[A][Ф]", "◌̋", UniTrim(CharCodes.dacute[1])],
    [Map("ru", "Кратка", "en", "Breve"), "[b][и]", "◌̆", UniTrim(CharCodes.breve[1])],
    [Map("ru", "Перевёрнутая кратка", "en", "Inverted Breve"), "[B][И]", "◌̑", UniTrim(CharCodes.ibreve[1])],
    [Map("ru", "Циркумфлекс", "en", "Circumflex"), "[c][с]", "◌̂", UniTrim(CharCodes.circumflex[1])],
    [Map("ru", "Гачек", "en", "Caron"), "[C][С]", "◌̌", UniTrim(CharCodes.caron[1])],
    [Map("ru", "Точка сверху", "en", "Dot Above"), "[d][в]", "◌̇", UniTrim(CharCodes.dotabove[1])],
    [Map("ru", "Диерезис", "en", "Diaeresis"), "[D][В]", "◌̈", UniTrim(CharCodes.diaeresis[1])],
    [Map("ru", "Фермата", "en", "Fermata"), "[f][а]", "◌͒", UniTrim(CharCodes.fermata[1])],
    [Map("ru", "Гравис", "en", "Grave"), "[g][п]", "◌̀", UniTrim(CharCodes.grave[1])],
    [Map("ru", "Двойной гравис", "en", "Double Grave"), "[G][П]", "◌̏", UniTrim(CharCodes.dgrave[1])],
    [Map("ru", "Хвостик сверху", "en", "Hook Above"), "[h][р]", "◌̉", UniTrim(CharCodes.hookabove[1])],
    [Map("ru", "Рожок", "en", "Horn"), "[H][Р]", "◌̛", UniTrim(CharCodes.horn[1])],
    ["", "", "", ""],
    ["", "Win Alt F2", "", ""],
    [Map("ru", "Акут снизу", "en", "Acute Below"), "[a][ф]", "◌̗", UniTrim(CharCodes.acutebelow[1])],
    [Map("ru", "Кратка снизу", "en", "Breve Below"), "[b][и]", "◌̮", UniTrim(CharCodes.brevebelow[1])],
    [Map("ru", "Перевёрнутая кратка снизу", "en", "Inverted Breve Below"), "[B][И]", "◌̯", UniTrim(CharCodes.ibrevebelow[1])],
    [Map("ru", "Циркумфлекс снизу", "en", "Circumflex Below"), "[c][с]", "◌̭", UniTrim(CharCodes.circumflexbelow[1])],
    [Map("ru", "Гачек снизу", "en", "Caron Below"), "[C][С]", "◌̬", UniTrim(CharCodes.caronbelow[1])],
    [Map("ru", "Гравис снизу", "en", "Grave Below"), "[g][п]", "◌̖", UniTrim(CharCodes.gravebelow[1])],
    [Map("ru", "Палатальный крюк", "en", "Palatalized Hook Below"), "[g][р]", "◌̡", UniTrim(CharCodes.phookbelow[1])],
    [Map("ru", "Ретрофлексный крюк", "en", "Retroflex Hook Below"), "[G][Р]", "◌̢", UniTrim(CharCodes.rhookbelow[1])],
    ["", "", "", ""],
    ["", "Win Alt F3", "", ""],
    [Map("ru", "Мостик сверху", "en", "Bridge Above"), "[b][и]", "◌͆", UniTrim(CharCodes.bridgeabove[1])],
    [Map("ru", "Мостик снизу", "en", "Bridge Below"), "[B][И]", "◌̪", UniTrim(CharCodes.brevebelow[1])],
    [Map("ru", "Перевёрнутый мостик снизу", "en", "Inverted Bridge Below"), "LCtrl [B][И]", "◌̺", UniTrim(CharCodes.ibridgebelow[1])],
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
    [Map("ru", "Круглая шпация", "en", "Em Space"), "[1]", "[ ]", UniTrim(CharCodes.emsp[1])],
    [Map("ru", "Полукруглая шпация", "en", "En Space"), "[2]", "[ ]", UniTrim(CharCodes.ensp[1])],
    [Map("ru", "⅓ Круглой шпации", "en", "⅓ Em Space"), "[3]", "[ ]", UniTrim(CharCodes.emsp13[1])],
    [Map("ru", "¼ Круглой шпации", "en", "¼ Em Space"), "[4]", "[ ]", UniTrim(CharCodes.emsp14[1])],
    [Map("ru", "Узкий неразрывный пробел", "en", "Narrow No-Break Space"), "[5]", "[ ]", UniTrim(CharCodes.nnbsp[1])],
    [Map("ru", "⅙ Круглой шпации", "en", "⅙ Em Space"), "[6]", "[ ]", UniTrim(CharCodes.emsp16[1])],
    [Map("ru", "Узкий пробел", "en", "Thin Space"), "[7]", "[ ]", UniTrim(CharCodes.thinsp[1])],
    [Map("ru", "Волосяная шпация", "en", "Hair Space"), "[8]", "[ ]", UniTrim(CharCodes.hairsp[1])],
    [Map("ru", "Пунктуационный пробел", "en", "Punctuation Space"), "[9]", "[ ]", UniTrim(CharCodes.puncsp[1])],
    [Map("ru", "Пробел нулевой ширины", "en", "Zero-Width Space"), "[0]", "[​]", UniTrim(CharCodes.zwsp[1])],
    [Map("ru", "Соединитель слов", "en", "Word Joiner"), "[-]", "[⁠]", UniTrim(CharCodes.wj[1])],
    [Map("ru", "Цифровой пробел", "en", "Figure Space"), "[=]", "[ ]", UniTrim(CharCodes.numsp[1])],
    [Map("ru", "Неразрывный пробел", "en", "No-Break Space"), "[Space]", "[ ]", UniTrim(CharCodes.nbsp[1])],
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
  DSLContent["ru"].EntrydblClick := "2×ЛКМ"
  DSLContent["en"].EntrydblClick := "2×LMB"
  DSLContent["ru"].CommandsNote := "Unicode/Alt-code поддерживает ввод множества кодов через пробел, например «44F2 5607 9503» → «䓲嘇锃».`nРежим ввода HTML-энтити не влияет на «Быстрые ключи»."
  DSLContent["en"].CommandsNote := "Unicode/Alt-code supports input of multiple codes separated by spaces, for example “44F2 5607 9503” → “䓲嘇锃.”`nHTML entities mode does not affect “Fast keys.”"
  DSLContent["BindList"].Commands := [
    [Map("ru", "Перейти на страницу символа", "en", "Go to symbol page"), DSLContent[LanguageCode].EntrydblClick, ""],
    [Map("ru", "Копировать символ из списка", "en", "Copy from list"), "Ctrl " . DSLContent[LanguageCode].EntrydblClick, ""],
    [Map("ru", "Поиск по названию", "en", "Find by name"), "Win Alt F", ""],
    [Map("ru", "Вставить по Unicode", "en", "Unicode insertion"), "Win Alt U", ""],
    [Map("ru", "Вставить по Альт-коду", "en", "Alt-code insertion"), "Win Alt A", ""],
    [Map("ru", "Вставить лигатуру", "en", "Insert ligature"), "Win Alt L", "AE → Æ, OE → Œ"],
    [Map("ru", "Конвертировать в верхний индекс", "en", "Convert into superscript"), "Win LAlt 1", "‌¹‌²‌³‌⁴‌⁵‌⁶‌⁷‌⁸‌⁹‌⁰‌⁽‌⁻‌⁼‌⁾"],
    [Map("ru", "Конвертировать в нижний индекс", "en", "Convert into subscript"), "Win RAlt 1", "‌₁‌₂‌₃‌₄‌₅‌₆‌₇‌₈‌₉‌₀‌₍‌₋‌₌‌₎"],
    [Map("ru", "Активировать быстрые ключи", "en", "Activate fastkeys"), "RAlt Home", ""],
    [Map("ru", "Активировать ввод HTML-энтити", "en", "Activate input of HTML entities"), "RAlt RShift Home", "á → a&#769;"],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].Commands)

  CommandsLV := DSLPadGUI.Add("ListView", ColumnAreaWidth . " h450 " . ColumnAreaRules,
    [DSLContent["UI"].TabsNCols[2][1][1], DSLContent["UI"].TabsNCols[2][1][2], DSLContent["UI"].TabsNCols[2][1][3]])
  CommandsLV.ModifyCol(1, ThreeColumnWidths[1])
  CommandsLV.ModifyCol(2, ThreeColumnWidths[2])
  CommandsLV.ModifyCol(3, ThreeColumnWidths[3])

  for item in DSLContent["BindList"].Commands
  {
    CommandsLV.Add(, item[1], item[2], item[3])
  }

  DSLPadGUI.SetFont("s9")
  DSLPadGUI.Add("Text", "w600", DSLContent[LanguageCode].CommandsNote)

  DSLPadGUI.SetFont("s11")
  Tab.UseTab(5)
  DSLContent["BindList"].FasKeysLV := [
    ["", "LCtrl LAlt", "", ""],
    [Map("ru", "Акут", "en", "Acute"), "[a][ф]", "◌́", UniTrim(CharCodes.acute[1])],
    [Map("ru", "Двойной Акут", "en", "Double Acute"), "LShift [a][ф]", "◌̋", UniTrim(CharCodes.dacute[1])],
    [Map("ru", "Кратка", "en", "Breve"), "[b][и]", "◌̆", UniTrim(CharCodes.breve[1])],
    [Map("ru", "Перевёрнутая кратка", "en", "Inverted Breve"), "LShift [b][и]", "◌̑", UniTrim(CharCodes.ibreve[1])],
    [Map("ru", "Циркумфлекс", "en", "Circumflex"), "[c][с]", "◌̂", UniTrim(CharCodes.circumflex[1])],
    [Map("ru", "Гачек", "en", "Caron"), "LShift [c][с]", "◌̌", UniTrim(CharCodes.caron[1])],
    [Map("ru", "Точка сверху", "en", "Dot Above"), "[d][в]", "◌̇", UniTrim(CharCodes.dotabove[1])],
    [Map("ru", "Диерезис", "en", "Diaeresis"), "LShift [d][в]", "◌̈", UniTrim(CharCodes.diaeresis[1])],
    [Map("ru", "Гравис", "en", "Grave"), "[g][п]", "◌̀", UniTrim(CharCodes.grave[1])],
    [Map("ru", "Двойной гравис", "en", "Double Grave"), "LShift [g][п]", "◌̏", UniTrim(CharCodes.dgrave[1])],
    [Map("ru", "Хвостик сверху", "en", "Hook Above"), "[h][р]", "◌̉", UniTrim(CharCodes.hookabove[1])],
    [Map("ru", "Рожок", "en", "Horn"), "LShift [h][р]", "◌̛", UniTrim(CharCodes.horn[1])],
    ["", "", "", ""],
    ["", "RAlt RShift", "", ""],
    [Map("ru", "Круглая шпация", "en", "Em Space"), "[1]", "[ ]", UniTrim(CharCodes.emsp[1])],
    [Map("ru", "Полукруглая шпация", "en", "En Space"), "[2]", "[ ]", UniTrim(CharCodes.ensp[1])],
    [Map("ru", "⅓ Круглой шпации", "en", "⅓ Em Space"), "[3]", "[ ]", UniTrim(CharCodes.emsp13[1])],
    [Map("ru", "¼ Круглой шпации", "en", "¼ Em Space"), "[4]", "[ ]", UniTrim(CharCodes.emsp13[1])],
    [Map("ru", "Узкий неразрывный пробел", "en", "Narrow No-Break Space"), "[5]", "[ ]", UniTrim(CharCodes.nnbsp[1])],
    [Map("ru", "⅙ Круглой шпации", "en", "⅙ Em Space"), "[6]", "[ ]", UniTrim(CharCodes.emsp16[1])],
    [Map("ru", "Узкий пробел", "en", "Thin Space"), "[7]", "[ ]", UniTrim(CharCodes.thinsp[1])],
    [Map("ru", "Волосяная шпация", "en", "Hair Space"), "[8]", "[ ]", UniTrim(CharCodes.hairsp[1])],
    [Map("ru", "Пунктуационный пробел", "en", "Punctuation Space"), "[9]", "[ ]", UniTrim(CharCodes.puncsp[1])],
    [Map("ru", "Пробел нулевой ширины", "en", "Zero-Width Space"), "[0]", "[​]", UniTrim(CharCodes.zwsp[1])],
    [Map("ru", "Соединитель слов", "en", "Word Joiner"), "[-]", "[⁠]", UniTrim(CharCodes.wj[1])],
    [Map("ru", "Цифровой пробел", "en", "Figure Space"), "[=]", "[ ]", UniTrim(CharCodes.numsp[1])],
    [Map("ru", "Неразрывный пробел", "en", "No-Break Space"), "[Space]", "[ ]", UniTrim(CharCodes.nbsp[1])],
    ["", "", "", ""],
    [Map("ru", "Верхний индекс", "en", "Superscript"), "LCtrl LAlt [1…0]", "¹²³⁴⁵⁶⁷⁸⁹⁰", ""],
    [Map("ru", "Нижний индекс", "en", "Subscript"), "LCtrl LAlt [1…0]", "₁₂₃₄₅₆₇₈₉₀", ""],
    ["", "", "", ""],
    [Map("ru", "Соединитель графем ✅", "en", "Grapheme Joiner ✅"), "LShift RShift [g]", "◌͏", UniTrim(CharCodes.grapjoiner[1])],
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
    "Режимы`nОбычный — требует «активации» группы знаков: Win Alt [Группа] (F1, Space…) необходимо нажать, но не удерживать, после чего нажать на символ ключа нужного знака.`nБыстрые ключи — необходимо удерживать модифицирующие клавиши, например, LCtrl LAlt + m, что бы ввести знак макрона [◌̄].`nБыстрые ключи, отмеченные ✅, активны всегда."
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
    "This window displays all available key combinations. Double-clicking the LMB on any line containing Unicode will take you to the Symbl.cc site with an overview of the corresponding symbol.",
    "Modes`nCommon: requires “activation” of characters groups: Win Alt [Groups] (F1, Space…) must be pressed, but not held, after which to enter the macro [◌̄].`nFast keys: must be held down modifier keys, for example, LCtrl LAlt + m, to enter the macro [◌̄].`nFast keys, marked ✅, always active."
  ]

  DSLPadGUI.SetFont("s16")
  DSLPadGUI.Add("Text", , DSLContent[LanguageCode].About.Title)
  DSLPadGUI.SetFont("s11")
  DSLPadGUI.Add("Text", , DSLContent[LanguageCode].About.SubTitle)

  for item in DSLContent[LanguageCode].About.Texts
  {
    DSLPadGUI.Add("Text", "w600", item)
  }
  DSLPadGUI.Add("Link", "w600", DSLContent[LanguageCode].About.Repository . '<a href="https://github.com/DemerNkardaz/Misc-Scripts/tree/main/AutoHotkey2.0">GitHub “Misc-Scripts”</a>')

  DSLPadGUI.Add("Link", "w600", DSLContent[LanguageCode].About.AuthorGit . '<a href="https://github.com/DemerNkardaz">GitHub</a>; <a href="http://steamcommunity.com/profiles/76561198177249942">STEAM</a>; <a href="https://ficbook.net/authors/4241255">Фикбук</a>')

  BtnAutoLoad := DSLPadGUI.Add("Button", "x454 y30 w200 h32", DSLContent[LanguageCode].About.AutoLoadAdd)
  BtnAutoLoad.OnEvent("Click", AddScriptToAutoload)

  BtnSwitchRU := DSLPadGUI.Add("Button", "x454 y63 w32 h32", "РУ")
  BtnSwitchRU.OnEvent("Click", (*) => SwitchLanguage("ru"))

  BtnSwitchEN := DSLPadGUI.Add("Button", "x487 y63 w32 h32", "EN")
  BtnSwitchEN.OnEvent("Click", (*) => SwitchLanguage("en"))

  Tab.UseTab(7)
  DSLContent["ru"].Useful := {}
  DSLContent["ru"].Useful.Unicode := "Unicode-ресурсы"
  DSLContent["ru"].Useful.Dictionaries := "Словари"
  DSLContent["ru"].Useful.JPnese := "Японский: "
  DSLContent["ru"].Useful.CHnese := "Китайский: "
  DSLContent["ru"].Useful.VTnese := "Вьетнамский: "


  DSLContent["en"].Useful := {}
  DSLContent["en"].Useful.Unicode := "Unicode-Resources"
  DSLContent["en"].Useful.Dictionaries := "Dictionaries"
  DSLContent["en"].Useful.JPnese := "Japanese: "
  DSLContent["en"].Useful.CHnese := "Chinese: "
  DSLContent["en"].Useful.VTnese := "Vietnamese: "

  DSLPadGUI.SetFont("s13")
  DSLPadGUI.Add("Text", , DSLContent[LanguageCode].Useful.Unicode)
  DSLPadGUI.SetFont("s11")
  DSLPadGUI.Add("Link", "w600", '<a href="https://symbl.cc/">Symbl.cc</a> <a href="https://www.compart.com/en/unicode/">Compart</a>')
  DSLPadGUI.SetFont("s13")
  DSLPadGUI.Add("Text", , DSLContent[LanguageCode].Useful.Dictionaries)
  DSLPadGUI.SetFont("s11")
  DSLPadGUI.Add("Link", "w600", DSLContent[LanguageCode].Useful.JPnese . '<a href="https://yarxi.ru">ЯРКСИ</a> <a href="https://www.warodai.ruu">Warodai</a>')
  DSLPadGUI.Add("Link", "w600", DSLContent[LanguageCode].Useful.CHnese . '<a href="https://bkrs.info">БКРС</a>')
  DSLPadGUI.Add("Link", "w600", DSLContent[LanguageCode].Useful.VTnese . '<a href="https://chunom.org">Chữ Nôm</a>')

  DiacriticLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  SpacesLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  FasKeysLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  CommandsLV.OnEvent("DoubleClick", LV_RunCommand)


  DSLPadGUI.Title := DSLPadTitle

  screenWidth := A_ScreenWidth
  screenHeight := A_ScreenHeight

  windowWidth := 650
  windowHeight := 562
  xPos := screenWidth - windowWidth - 40
  yPos := screenHeight - windowHeight - 75

  DSLPadGUI.Show()
  DSLPadGUI.Move(xPos, yPos)

  return DSLPadGUI
}

LV_OpenUnicodeWebsite(LV, RowNumber)
{
  LanguageCode := GetLanguageCode()
  SelectedRow := LV.GetText(RowNumber, 4)
  URIComponent := "https://symbl.cc/" . LanguageCode . "/" . SelectedRow
  if (SelectedRow != "")
  {
    IsCtrlDown := GetKeyState("LControl")
    if (IsCtrlDown) {
      UnicodeCodePoint := "0x" . SelectedRow
      A_Clipboard := Chr(UnicodeCodePoint)
      SoundPlay("C:\Windows\Media\Speech On.wav")
    }
    else {
      Run(URIComponent)
    }
  }
}


LV_RunCommand(LV, RowNumber)
{
  Shortcut := LV.GetText(RowNumber, 2)

  if (Shortcut = "Win Alt F")
    SearchKey()

  if (Shortcut = "Win Alt U")
    InsertUnicodeKey()

  if (Shortcut = "Win Alt A")
    InsertAltCodeKey()

  if (Shortcut = "Win Alt L")
    Ligaturise()

  if (Shortcut = "Win LAlt 1")
    SwitchToScript("sup")

  if (Shortcut = "Win RAlt 1")
    SwitchToScript("sub")

  if (Shortcut = "RAlt Home")
    ToggleFastKeys()

  if (Shortcut = "RAlt RShift Home")
    ToggleInputHTMLEntities()
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
  LanguageCode := GetLanguageCode()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].Success := "Ярлык для автозагрузки создан или обновлен."
  Labels["en"].Success := "Shortcut for autoloading created or updated."
  CurrentScriptPath := A_ScriptFullPath
  AutoloadFolder := A_StartMenu "\Programs\Startup"
  ShortcutPath := AutoloadFolder "\DSLKeyPad.lnk"

  if (FileExist(ShortcutPath)) {
    FileDelete(ShortcutPath)
  }

  Command := "powershell -command " "$shell = New-Object -ComObject WScript.Shell; $shortcut = $shell.CreateShortcut('" ShortcutPath "'); $shortcut.TargetPath = '" CurrentScriptPath "'; $shortcut.WorkingDirectory = '" A_ScriptDir "'; $shortcut.Description = 'DSLKeyPad AutoHotkey Script'; $shortcut.Save()" ""
  RunWait(Command)

  MsgBox(Labels[LanguageCode].Success, DSLPadTitle, 0x40)
}

IsGuiOpen(title)
{
  return WinExist(title) != 0
}

; Fastkeys

<^>!Home:: ToggleFastKeys()

ToggleFastKeys()
{
  LanguageCode := GetLanguageCode()
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
  MsgBox(FastKeysIsActive ? ActivationMessage[LanguageCode].Active : ActivationMessage[LanguageCode].Deactive, "FastKeys", 0x40)

  return
}

<^>!>+Home:: ToggleInputHTMLEntities()

ToggleInputHTMLEntities()
{
  LanguageCode := GetLanguageCode()
  global InputHTMLEntities, ConfigFile
  InputHTMLEntities := !InputHTMLEntities
  IniWrite (InputHTMLEntities ? "True" : "False"), ConfigFile, "Settings", "InputHTMLEntities"

  ActivationMessage := {}
  ActivationMessage[] := Map()
  ActivationMessage["ru"] := {}
  ActivationMessage["en"] := {}
  ActivationMessage["ru"].Active := "Ввод HTML-энтити активирован"
  ActivationMessage["ru"].Deactive := "Ввод HTML-энтити деактивирован"
  ActivationMessage["en"].Active := "Input HTML entities activated"
  ActivationMessage["en"].Deactive := "Input HTML entities deactivated"
  MsgBox(InputHTMLEntities ? ActivationMessage[LanguageCode].Active : ActivationMessage[LanguageCode].Deactive, "HTML-Entities", 0x40)

  return
}


HandleFastKey(char)
{
  global FastKeysIsActive
  if (FastKeysIsActive) {
    Send(char)
  }
}


<^<!a:: HandleFastKey(CharCodes.acute[1])
<^<+<!a:: HandleFastKey(CharCodes.dacute[1])
<^<!b:: HandleFastKey(CharCodes.breve[1])
<^<+<!b:: HandleFastKey(CharCodes.ibreve[1])
<^<!c:: HandleFastKey(CharCodes.circumflex[1])
<^<+<!c:: HandleFastKey(CharCodes.caron[1])
<^<!d:: HandleFastKey(CharCodes.dotabove[1])
<^<+<!d:: HandleFastKey(CharCodes.diaeresis[1])
<^<!g:: HandleFastKey(CharCodes.grave[1])
<^<+<!g:: HandleFastKey(CharCodes.dgrave[1])
<^<!m:: HandleFastKey(CharCodes.macron[1])
<^<+<!m:: HandleFastKey(CharCodes.macronbelow[1])


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

<^>!>+1:: HandleFastKey(CharCodes.emsp[1])
<^>!>+2:: HandleFastKey(CharCodes.ensp[1])
<^>!>+3:: HandleFastKey(CharCodes.emsp13[1])
<^>!>+4:: HandleFastKey(CharCodes.emsp14[1])
<^>!>+5:: HandleFastKey(CharCodes.nnbsp[1])
<^>!>+6:: HandleFastKey(CharCodes.emsp16[1])
<^>!>+7:: HandleFastKey(CharCodes.thinsp[1])
<^>!>+8:: HandleFastKey(CharCodes.hairsp[1])
<^>!>+9:: HandleFastKey(CharCodes.puncsp[1])
<^>!>+0:: HandleFastKey(CharCodes.zwsp[1])
<^>!>+-:: HandleFastKey(CharCodes.wj[1])
<^>!>+=:: HandleFastKey(CharCodes.numsp[1])
<^>!<+Space:: HandleFastKey(CharCodes.nbsp[1])

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


>+<+g:: Send("{U+034F}") ; Combining Grapheme Joiner
