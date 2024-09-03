#Requires Autohotkey v2
#SingleInstance Force


; Only EN US & RU RU Keyboard Layout
ChracterMap := "C:\Windows\System32\charmap.exe"
ImageRes := "C:\Windows\System32\imageres.dll"
Shell32 := "C:\Windows\SysWOW64\shell32.dll"


AppVersion := [0, 1, 1, 0]
CurrentVersionString := Format("{:d}.{:d}.{:d}", AppVersion[1], AppVersion[2], AppVersion[3])
UpdateVersionString := ""

RawRepo := "https://raw.githubusercontent.com/DemerNkardaz/Misc-Scripts/main/AutoHotkey2.0/DSL_KeyPad/"
RepoSource := "https://github.com/DemerNkardaz/Misc-Scripts/blob/main/AutoHotkey2.0/DSL_KeyPad/DSLKeyPad.ahk"

RawSource := RawRepo . "DSLKeyPad.ahk"
UpdateAvailable := False

ChangeLogRaw := Map(
  "ru", RawRepo . "DSLKeyPad.Changelog.ru.md",
  "en", RawRepo . "DSLKeyPad.Changelog.en.md"
)

LocalesRaw := RawRepo . "DSLKeyPad.locales.ini"
AppIcoRaw := RawRepo . "DSLKeyPad.app.ico"


WorkingDir := A_MyDocuments . "\DSLKeyPad"
DirCreate(WorkingDir)


ConfigFile := WorkingDir . "\DSLKeyPad.config.ini"
LocalesFile := WorkingDir . "\DSLKeyPad.locales.ini"
AppIcoFile := WorkingDir . "\DSLKeyPad.app.ico"

DSLPadTitle := "DSL KeyPad (αλφα)" . " — " . CurrentVersionString
DSLPadTitleDefault := "DSL KeyPad"
DSLPadTitleFull := "Diacritics-Spaces-Letters KeyPad"

GetLocales() {
  global LocalesRaw
  ErrMessages := Map(
    "ru", "Произошла ошибка при получении файла перевода.`nСервер недоступен или ошибка соединения с интернетом.",
    "en", "An error occured during receiving locales file.`nServer unavailable or internet connection error."
  )
  http := ComObject("WinHttp.WinHttpRequest.5.1")
  http.Open("GET", LocalesRaw, true)
  http.Send()
  http.WaitForResponse()

  if http.Status != 200 {
    MsgBox(ErrMessages[GetLanguageCode()])
    return
  }

  Download(LocalesRaw, LocalesFile)
}

if !FileExist(LocalesFile) {
  GetLocales()
}

ReadLocale(EntryName, Prefix := "") {
  global LocalesFile
  Section := Prefix != "" ? Prefix . "_" . GetLanguageCode() : GetLanguageCode()
  Intermediate := IniRead(LocalesFile, Section, EntryName, "")
  Intermediate := StrReplace(Intermediate, "\n", "`n")

  while (RegExMatch(Intermediate, "\{U\+(\w+)\}", &match)) {
    Unicode := match[1]
    Replacement := Chr("0x" . Unicode)
    Intermediate := StrReplace(Intermediate, match[0], Replacement)
  }

  while (RegExMatch(Intermediate, "\{([a-zA-Z]{2})\}", &match)) {
    LangCode := match[1]
    SectionOverride := Prefix != "" ? Prefix . "_" . LangCode : LangCode
    Replacement := IniRead(LocalesFile, SectionOverride, EntryName, "")
    Intermediate := StrReplace(Intermediate, match[0], Replacement)
  }

  while (RegExMatch(Intermediate, "\{(?:([^\}_]+)_)?([a-zA-Z]{2}):([^\}]+)\}", &match)) {
    CustomPrefix := match[1] ? match[1] : ""
    LangCode := match[2]
    CustomEntry := match[3]
    SectionOverride := CustomPrefix != "" ? CustomPrefix . "_" . LangCode : LangCode
    Replacement := IniRead(LocalesFile, SectionOverride, CustomEntry, "")
    Intermediate := StrReplace(Intermediate, match[0], Replacement)
  }

  return Intermediate
}

SetStringVars(StringVar, SetVars*) {
  Result := StringVar
  for index, value in SetVars {
    Result := StrReplace(Result, "{" (index - 1) "}", value)
  }
  return Result
}

GetAppIco() {
  global AppIcoRaw, AppIcoFile
  ErrMessages := Map(
    "ru", "Произошла ошибка при получении иконки приложения.`nСервер недоступен или ошибка соединения с интернетом.",
    "en", "An error occured during receiving app icon.`nServer unavailable or internet connection error."
  )
  http := ComObject("WinHttp.WinHttpRequest.5.1")
  http.Open("GET", AppIcoRaw, true)
  http.Send()
  http.WaitForResponse()

  if http.Status != 200 {
    MsgBox(ErrMessages[GetLanguageCode()])
    return
  }

  Download(AppIcoRaw, AppIcoFile)

}

if !FileExist(AppIcoFile) {
  GetAppIco()
}


OpenConfigFile(*) {
  global ConfigFile
  Run(ConfigFile)
}

OpenLocalesFile(*) {
  global LocalesFile
  Run(LocalesFile)
}

FastKeysIsActive := False
SkipGroupMessage := False
InputMode := "Default"
LaTeXMode := "common"

DefaultConfig := [
  ["Settings", "FastKeysIsActive", "False"],
  ["Settings", "SkipGroupMessage", "False"],
  ["Settings", "InputMode", "Default"],
  ["Settings", "UserLanguage", ""],
  ["LatestPrompts", "LaTeX", ""],
  ["LatestPrompts", "Unicode", ""],
  ["LatestPrompts", "Altcode", ""],
  ["LatestPrompts", "Search", ""],
  ["LatestPrompts", "Ligature", ""],
  ["LatestPrompts", "RomanNumeral", ""],
]

if FileExist(ConfigFile) {
  isFastKeysEnabled := IniRead(ConfigFile, "Settings", "FastKeysIsActive", "False")
  isSkipGroupMessage := IniRead(ConfigFile, "Settings", "SkipGroupMessage", "False")
  InputMode := IniRead(ConfigFile, "Settings", "InputMode", "Default")
  LaTeXMode := IniRead(ConfigFile, "Settings", "LaTeXMode", "common")

  FastKeysIsActive := (isFastKeysEnabled = "True")
  SkipGroupMessage := (isSkipGroupMessage = "True")
} else {
  for index, config in DefaultConfig {
    IniWrite config[3], ConfigFile, config[1], config[2]
  }
}

StrRepeat(char, count) {
  result := ""
  Loop count
    result .= char
  return result
}

TrimArray(From, Count) {
  result := []
  for i, item in From {
    if (i > Count)
      break
    result.Push(item)
  }
  return result
}


SupportedLanguages := [
  "en",
  "ru",
]

GetLanguageCode()
{

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

GetChangeLog() {
  global ChangeLogRaw
  ReceiveMap := Map()

  TimeOut := 1000
  Cancelled := False

  http := ComObject("WinHttp.WinHttpRequest.5.1")
  CancelHttp() {
    Cancelled := True
  }

  SetTimer(CancelHttp, TimeOut)
  if Cancelled {
    return
  }

  for language, url in ChangeLogRaw {
    http.Open("GET", url, true)
    http.Send()
    http.WaitForResponse()

    if http.Status != 200 || Cancelled {
      if Cancelled
        http.Abort()
      continue
    }

    if Cancelled {
      return
    }

    ReceiveMap[language] := http.ResponseText
  }


  return ReceiveMap
}

InsertChangesList(TargetGUI) {
  LanguageCode := GetLanguageCode()
  Changes := GetChangeLog()
  IsEmpty := True

  for language, _ in Changes {
    IsEmpty := False
    break
  }

  if IsEmpty {
    return
  }

  Labels := {
    ver: IniRead(LocalesFile, LanguageCode, "version", ""),
    date: IniRead(LocalesFile, LanguageCode, "date", ""),
  }


  for language, content in Changes {
    if language = LanguageCode {
      content := RegExReplace(content, "m)^## " . Labels.ver . " (.*) — (.*)", Labels.ver . ": $1`n" . Labels.date . ": $2")
      content := RegExReplace(content, "m)^- (.*)", " • $1")
      content := RegExReplace(content, "m)^---", " " . StrRepeat("—", 84))

      TargetGUI.Add("Edit", "x30 y58 w810 h480 readonly Left Wrap -HScroll -E0x200", content)
    }
  }
}

GetUpdate(TimeOut := 0, RepairMode := False) {
  Sleep TimeOut
  global AppVersion, RawSource
  LanguageCode := GetLanguageCode()
  Messages := {
    updateSucces: SetStringVars(ReadLocale("update_successful"), CurrentVersionString, UpdateVersionString),
  }

  RepairLabels := Map()
  RepairLabels["ru"] := {
    title: "Восстановление",
    description: "Введите y/n что бы продолжить или отменить восстановление программы.`nОна будет заново скачана из репозитория, включая сопутствующие файлы.",
    success: "Восстановление завершено успешно.",
  }
  RepairLabels["en"] := {
    title: "Restore",
    description: "Enter y/n to continue or cancel the restore program.`nIt will be downloaded from the repository, including other files.",
    success: "Restore completed successfully.",
  }

  if RepairMode == True {
    IB := InputBox(RepairLabels[LanguageCode].description, RepairLabels[LanguageCode].title, "w256", "")
    if IB.Result = "Cancel" || IB.Value != "y" {
      return
    }
  }

  CurrentFilePath := A_ScriptFullPath
  CurrentFileName := StrSplit(CurrentFilePath, "\").Pop()
  UpdateFilePath := A_ScriptDir "\DSLKeyPad.ahk-GettingUpdate"

  UpdatingFileContent := ""

  http := ComObject("WinHttp.WinHttpRequest.5.1")
  http.Open("GET", RawSource, true)
  http.Send()
  http.WaitForResponse()

  if http.Status != 200 {
    MsgBox(ReadLocale("update_failed"), DSLPadTitle)
    return
  }

  UpdatingFileContent := http.ResponseText

  Sleep 50
  FileAppend("", UpdateFilePath, "UTF-8")
  GettingUpdateFile := FileOpen(UpdateFilePath, "w", "UTF-8")
  GettingUpdateFile.Write(UpdatingFileContent)
  GettingUpdateFile.Close()

  Sleep 50
  UpdatingFileContent := FileRead(UpdateFilePath, "UTF-8")
  Sleep 50

  if UpdateAvailable || RepairMode == True {
    DuplicatedCount := 0
    SplitContent := StrSplit(UpdatingFileContent, "`n")
    FixTrimmedContent := ""

    for line in SplitContent {
      if InStr(line, "DuplicateResolver := 'Bad Http…'") {
        DuplicatedCount++
      }
    }
    if (DuplicatedCount > 1) {
      ;ShowInfoMessage([Messages2["ru"].ErrorDuplicated, DSLPadTitle, Messages2["en"].ErrorDuplicated], "Warning")
    }

    for line in SplitContent {
      if (InStr(line, ";Application" . "End")) {
        break
      }
      FixTrimmedContent .= line . "`n"
    }

    FixTrimmedContent := RTrim(FixTrimmedContent, "`n")
    GettingUpdateFile := FileOpen(UpdateFilePath, "w", "UTF-8")
    GettingUpdateFile.Write(FixTrimmedContent)
    GettingUpdateFile.Close()

    FileAppend("`n;Application" . "End`n", UpdateFilePath, "UTF-8")
    UpdatingFileContent := FileRead(UpdateFilePath, "UTF-8")

    DuplicatedCount := 0
    for line in SplitContent {
      if InStr(line, "DuplicateResolver := 'The Second Gate…'") {
        DuplicatedCount++
      }
    }

    if (DuplicatedCount > 1) {
      ;ShowInfoMessage([Messages2["ru"].ErrorOccured, DSLPadTitle, Messages2["en"].ErrorOccured], "Warning")
      FileDelete(UpdateFilePath)
      Sleep 500
      GetUpdate(1500)
      return
    }

    if FileExist(CurrentFilePath . "-Backup") {
      FileDelete(CurrentFilePath . "-Backup")
      Sleep 100
    }

    FileMove(CurrentFilePath, A_ScriptDir "\" CurrentFileName . "-Backup")
    Sleep 200
    FileMove(UpdateFilePath, A_ScriptDir "\" CurrentFileName)
    Sleep 200
    GetLocales()
    GetAppIco()
    if RepairMode == True {
      MsgBox(RepairLabels[LanguageCode].success, DSLPadTitle)
    } else {
      MsgBox(Messages.updateSucces, DSLPadTitle)
    }

    Reload
    return
  }
  FileDelete(UpdateFilePath)
  MsgBox(ReadLocale("update_absent"), DSLPadTitle)
}

CheckUpdate() {
  global AppVersion, RawSource, UpdateAvailable, UpdateVersionString
  http := ComObject("WinHttp.WinHttpRequest.5.1")
  http.Open("GET", RawSource, true)
  http.Send()
  http.WaitForResponse()

  if http.Status != 200 {
    return
  }

  FileContent := http.ResponseText

  if !RegExMatch(FileContent, "AppVersion := \[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]", &match) {
    MsgBox "Application version not found."
    return
  }
  NewVersion := [match[1], match[2], match[3], match[4]]
  Loop 4 {
    if NewVersion[A_Index] > AppVersion[A_Index] {
      UpdateAvailable := True
      UpdateVersionString := Format("{:d}.{:d}.{:d}.{:d}", NewVersion[1], NewVersion[2], NewVersion[3], NewVersion[4])
      return
    } else if NewVersion[A_Index] < AppVersion[A_Index] {
      return
    }
  }
}
CheckUpdate()

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
ExclamationMark := Chr(33)
CommercialAt := Chr(64)
QuotationDouble := Chr(34)
Backquote := Chr(96)
Solidus := Chr(47)
ReverseSolidus := Chr(92)
InformationSymbol := "ⓘ"
DottedCircle := Chr(0x25CC)

RoNum := Map(
  "00-HundredM", Chr(0x2188),
  "01-FiftyTenM", Chr(0x2187),
  "02-TenM", Chr(0x2182),
  "03-FiveM", Chr(0x2181),
  "04-M", Chr(0x216F),
  "05-D", Chr(0x216E),
  "06-C", Chr(0x216D),
  "07-L", Chr(0x216C),
  ;"08-XII", Chr(0x216B),
  ;"09-XI", Chr(0x216A),
  "10-X", Chr(0x2169),
  "11-IX", Chr(0x2168),
  "12-VIII", Chr(0x2167),
  "13-VII", Chr(0x2166),
  "14-VI", Chr(0x2165),
  "15-V", Chr(0x2164),
  "16-IV", Chr(0x2163),
  "17-III", Chr(0x2162),
  "18-II", Chr(0x2161),
  "19-I", Chr(0x2160),
  "20-sHundredM", Chr(0x2188),
  "21-sFiftyTenM", Chr(0x2187),
  "22-sTenM", Chr(0x2182),
  "23-sFiveM", Chr(0x2181),
  "24-sM", Chr(0x217F),
  "25-sD", Chr(0x217E),
  "26-sC", Chr(0x217D),
  "27-sL", Chr(0x217C),
  ;"28-sXII", Chr(0x217B),
  ;"29-sXI", Chr(0x217A),
  "30-sX", Chr(0x2179),
  "31-sIX", Chr(0x2178),
  "32-sVIII", Chr(0x2177),
  "33-sVII", Chr(0x2176),
  "34-sVI", Chr(0x2175),
  "35-sV", Chr(0x2174),
  "36-sIV", Chr(0x2173),
  "37-sIII", Chr(0x2172),
  "38-sII", Chr(0x2171),
  "39-sI", Chr(0x2170),
)


FormatHotKey(HKey, Modifier := "") {
  MakeString := ""

  SpecialCommandsMap := Map(
    CtrlA, "LCtrl [a][ф]", CtrlB, "LCtrl [b][и]", CtrlC, "LCtrl [c][с]", CtrlD, "LCtrl [d][в]", CtrlE, "LCtrl [e][у]", CtrlF, "LCtrl [f][а]", CtrlG, "LCtrl [g][п]",
    CtrlH, "LCtrl [h][р]", CtrlI, "LCtrl [i][ш]", CtrlJ, "LCtrl [j][о]", CtrlK, "LCtrl [k][л]", CtrlL, "LCtrl [l][д]", CtrlM, "LCtrl [m][ь]", CtrlN, "LCtrl [n][т]",
    CtrlO, "LCtrl [o][щ]", CtrlP, "LCtrl [p][з]", CtrlQ, "LCtrl [q][й]", CtrlR, "LCtrl [r][к]", CtrlS, "LCtrl [s][ы]", CtrlT, "LCtrl [t][е]", CtrlU, "LCtrl [u][г]",
    CtrlV, "LCtrl [v][м]", CtrlW, "LCtrl [w][ц]", CtrlX, "LCtrl [x][ч]", CtrlY, "LCtrl [y][н]", CtrlZ, "LCtrl [z][я]", SpaceKey, "[Space]", ExclamationMark, "[!]", CommercialAt, "[@]", QuotationDouble, "[" . QuotationDouble . "]",
  )
  for key, value in SpecialCommandsMap {
    if (HKey = key)
      return value
  }

  if IsObject(HKey) {
    for keys in HKey {
      MakeString .= FormatHotKey(keys)
    }
  } else {
    MakeString := "[" . HKey . "]"
  }

  MakeString := Modifier != "" ? (Modifier . " " . MakeString) : MakeString

  return MakeString
}


InsertCharactersGroups(TargetArray := "", GroupName := "", GroupHotKey := "", AddSeparator := True, ShowOnFastKeys := False, ShowRecipes := False) {
  if GroupName == "" {
    return
  }

  LanguageCode := GetLanguageCode()
  TermporaryArray := []

  RecipesMicroController(recipeEntry) {
    RecipeString := ""
    if IsObject(recipeEntry) {
      totalCount := 0
      for index in recipeEntry {
        totalCount++
      }

      currentIndex := 0
      for index, recipe in recipeEntry {
        RecipeString .= recipe
        currentIndex++
        if (currentIndex < totalCount) {
          RecipeString .= ", "
        }
      }
    } else {
      RecipeString := recipeEntry
    }
    return RecipeString
  }


  if AddSeparator
    TermporaryArray.Push(["", "", "", ""])
  if GroupHotKey != ""
    TermporaryArray.Push(["", GroupHotKey, "", ""])

  for characterEntry, value in Characters {
    if (HasProp(value, "group") && value.group[1] == GroupName) {
      entryName := RegExReplace(characterEntry, "^\S+\s+")
      characterTitle := ""
      if (HasProp(value, "titles") &&
        (!HasProp(value, "titlesAlt") || HasProp(value, "titlesAlt") && value.titlesAlt == True)) {
        characterTitle := value.titles[LanguageCode]
      } else if (HasProp(value, "titlesAlt") && value.titlesAlt == True) {
        characterTitle := ReadLocale(entryName . "_alt", "chars")
      } else {
        characterTitle := ReadLocale(entryName, "chars")
      }


      characterSymbol := HasProp(value, "symbol") ? value.symbol : ""
      characterModifier := (HasProp(value, "modifier") && ShowOnFastKeys) ? value.modifier : ""
      characterBinding := (HasProp(value, "recipe") && ShowRecipes) ? RecipesMicroController(value.recipe) :
        (ShowOnFastKeys && HasProp(value, "alt_on_fast_keys")) ? value.alt_on_fast_keys : FormatHotKey(value.group[2], characterModifier)

      if !ShowOnFastKeys || ShowOnFastKeys && (HasProp(value, "show_on_fast_keys") && value.show_on_fast_keys) {
        TermporaryArray.Push([characterTitle, characterBinding, characterSymbol, UniTrim(value.unicode)])
      }
    }
  }

  if TargetArray == "" {
    return TermporaryArray
  } else {
    for element in TermporaryArray {
      TargetArray.Push(element)
    }
  }
}

Characters := Map(
  "", {
    unicode: "", html: "", entity: "",
    altcode: "",
    LaTeX: "",
    titles: Map("ru", "", "en", ""),
    titlesAlt: False,
    tags: [""],
    group: ["", ""],
    modifier: "",
    recipe: "",
    show_on_fast_keys: False,
    alt_on_fast_keys: "",
    symbol: "",
    symbolAlt: "",
    symbolCustom: ""
  },
    "0000 acute", {
      unicode: "{U+0301}", html: "&#769;",
      LaTeX: ["\'", "\acute"],
      tags: ["acute", "акут", "ударение"],
      group: ["Diacritics Primary", ["a", "ф"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0301)
    },
    "0001 acute_double", {
      unicode: "{U+030B}", html: "&#779;",
      tags: ["double acute", "двойной акут", "двойное ударение"],
      group: ["Diacritics Primary", ["A", "Ф"]],
      modifier: "LShift",
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x030B)
    },
    "0002 acute_below", {
      unicode: "{U+0317}", html: "&#791;",
      tags: ["acute below", "акут снизу"],
      group: ["Diacritics Secondary", ["a", "ф"]],
      symbol: DottedCircle . Chr(0x0317)
    },
    "0003 acute_tone_vietnamese", {
      unicode: "{U+0341}", html: "&#833;",
      tags: ["acute tone", "акут тона"],
      group: ["Diacritics Secondary", ["A", "Ф"]],
      symbol: DottedCircle . Chr(0x0341)
    },
    ;
    ;
    "0004 asterisk_above", {
      unicode: "{U+20F0}", html: "&#8432;",
      tags: ["asterisk above", "астериск сверху"],
      group: ["Diacritics Tertiary", ["a", "ф"]],
      symbol: DottedCircle . Chr(0x20F0)
    },
    "0005 asterisk_below", {
      unicode: "{U+0359}", html: "&#857;",
      tags: ["asterisk below", "астериск снизу"],
      group: ["Diacritics Tertiary", ["A", "Ф"]],
      symbol: DottedCircle . Chr(0x0359)
    },
    ;
    ;
    "0006 breve", {
      unicode: "{U+0306}", html: "&#774;",
      LaTeX: ["\u", "\breve"],
      tags: ["breve", "бреве", "кратка"],
      group: ["Diacritics Primary", ["b", "и"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0306)
    },
    "0007 breve_inverted", {
      unicode: "{U+0311}", html: "&#785;",
      tags: ["inverted breve", "перевёрнутое бреве", "перевёрнутая кратка"],
      group: ["Diacritics Primary", ["B", "И"]],
      modifier: "LShift",
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0311)
    },
    "0008 breve_below", {
      unicode: "{U+032E}", html: "&#814;",
      tags: ["breve below", "бреве снизу", "кратка снизу"],
      group: ["Diacritics Secondary", ["b", "и"]],
      symbol: DottedCircle . Chr(0x032E)
    },
    "0009 breve_inverted_below", {
      unicode: "{U+032F}", html: "&#815;",
      tags: ["inverted breve below", "перевёрнутое бреве снизу", "перевёрнутая кратка снизу"],
      group: ["Diacritics Secondary", ["B", "И"]],
      symbol: DottedCircle . Chr(0x032F)
    },
    ;
    ;
    "0000 bridge_above", {
      unicode: "{U+0346}", html: "&#838;",
      tags: ["bridge above", "мостик сверху"],
      group: ["Diacritics Tertiary", ["b", "и"]],
      symbol: DottedCircle . Chr(0x0346)
    },
    "0000 bridge_below", {
      unicode: "{U+032A}", html: "&#810;",
      tags: ["bridge below", "мостик снизу"],
      group: ["Diacritics Tertiary", ["B", "И"]],
      symbol: DottedCircle . Chr(0x032A)
    },
    "0000 bridge_inverted_below", {
      unicode: "{U+033A}", html: "&#825;",
      tags: ["inverted bridge below", "перевёрнутый мостик снизу"],
      group: ["Diacritics Tertiary", CtrlB],
      symbol: DottedCircle . Chr(0x033A)
    },
    ;
    ;
    "0000 circumflex", {
      unicode: "{U+0302}", html: "&#770;",
      LaTeX: ["\^", "\hat"],
      tags: ["circumflex", "циркумфлекс"],
      group: ["Diacritics Primary", ["c", "с"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0302)
    },
    "0000 caron", {
      unicode: "{U+030C}", html: "&#780;",
      LaTeX: "\v",
      tags: ["caron", "карон", "гачек"],
      group: ["Diacritics Primary", ["C", "С"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x030C)
    },
    "0000 circumflex_below", {
      unicode: "{U+032D}", html: "&#813;",
      tags: ["circumflex below", "циркумфлекс снизу"],
      group: ["Diacritics Secondary", ["c", "с"]],
      symbol: DottedCircle . Chr(0x032D)
    },
    "0000 caron_below", {
      unicode: "{U+032C}", html: "&#812;",
      tags: ["caron below", "карон снизу", "гачек снизу"],
      group: ["Diacritics Secondary", ["C", "С"]],
      symbol: DottedCircle . Chr(0x032C)
    },
    "0000 cedilla", {
      unicode: "{U+0327}", html: "&#807;",
      LaTeX: "\c",
      titles: Map("ru", "Седиль", "en", "Cedilla"),
      tags: ["cedilla", "седиль"],
      group: ["Diacritics Tertiary", ["c", "с"]],
      symbol: DottedCircle . Chr(0x0327)
    },
    "0000 candrabindu", {
      unicode: "{U+0310}", html: "&#784;",
      tags: ["candrabindu", "карон снизу"],
      group: ["Diacritics Tertiary", ["C", "С"]],
      symbol: DottedCircle . Chr(0x0310)
    },
    ;
    ;
    "0000 dot_above", {
      unicode: "{U+0307}", html: "&#775;",
      LaTeX: ["\.", "\dot"],
      tags: ["dot above", "точка сверху"],
      group: ["Diacritics Primary", ["d", "в"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0307)
    },
    "0000 diaeresis", {
      unicode: "{U+0308}", html: "&#776;",
      LaTeX: ["\" . QuotationDouble, "\ddot"],
      tags: ["diaeresis", "диерезис"],
      group: ["Diacritics Primary", ["D", "В"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0308)
    },
    "0000 dot_below", {
      unicode: "{U+0323}", html: "&#803;",
      tags: ["dot below", "точка снизу"],
      group: ["Diacritics Secondary", ["d", "в"]],
      symbol: DottedCircle . Chr(0x0323)
    },
    "0000 diaeresis_below", {
      unicode: "{U+0324}", html: "&#804;",
      tags: ["diaeresis below", "диерезис снизу"],
      group: ["Diacritics Secondary", ["D", "В"]],
      symbol: DottedCircle . Chr(0x0324)
    },
    ;
    ;
    "0000 fermata", {
      unicode: "{U+0352}", html: "&#850;",
      tags: ["fermata", "фермата"],
      group: ["Diacritics Tertiary", ["F", "А"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0352)
    },
    ;
    ;
    "0000 grave", {
      unicode: "{U+0300}", html: "&#768;",
      LaTeX: ["\" . Backquote, "\grave"],
      tags: ["grave", "гравис"],
      group: ["Diacritics Primary", ["g", "п"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0300)
    },
    "0000 grave_double", {
      unicode: "{U+030F}", html: "&#783;",
      tags: ["double grave", "двойной гравис"],
      group: ["Diacritics Primary", ["G", "П"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x030F)
    },
    "0000 grave_below", {
      unicode: "{U+0316}", html: "&#790;",
      tags: ["grave below", "гравис снизу"],
      group: ["Diacritics Secondary", ["g", "п"]],
      symbol: DottedCircle . Chr(0x0316)
    },
    "0000 grave_tone_vietnamese", {
      unicode: "{U+0340}", html: "&#832;",
      tags: ["grave tone", "гравис тона"],
      group: ["Diacritics Secondary", ["G", "П"]],
      symbol: DottedCircle . Chr(0x0340)
    },
    ;
    ;
    "0000 hook_above", {
      unicode: "{U+0309}", html: "&#777;",
      tags: ["hook above", "хвостик сверху"],
      group: ["Diacritics Primary", ["h", "р"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x0309)
    },
    "0000 horn", {
      unicode: "{U+031B}", html: "&#795;",
      tags: ["horn", "рожок"],
      group: ["Diacritics Primary", ["H", "Р"]],
      show_on_fast_keys: True,
      symbol: DottedCircle . Chr(0x031B)
    },
    "0000 palatalized_hook_below", {
      unicode: "{U+0321}", html: "&#801;",
      tags: ["palatalized hook below", "палатальный крюк"],
      group: ["Diacritics Secondary", ["h", "р"]],
      symbol: DottedCircle . Chr(0x0321)
    },
    "0000 retroflex_hook_below", {
      unicode: "{U+0322}", html: "&#802;",
      tags: ["retroflex hook below", "ретрофлексный крюк"],
      group: ["Diacritics Secondary", ["H", "Р"]],
      symbol: DottedCircle . Chr(0x0322)
    },
    ;
    ;
    ; ? Шпации
    "0000 emspace", {
      unicode: "{U+2003}", html: "&#8195;", entity: "&emsp;",
      tags: ["em space", "emspace", "emsp", "круглая шпация"],
      group: ["Spaces", "1"],
      show_on_fast_keys: True,
      symbol: "[" . Chr(0x2003) . "]",
      symbolAlt: Chr(0x2003),
      symbolCustom: "underline"
    },
    "0000 ensp", {
      unicode: "{U+2002}", html: "&#8194;", entity: "&ensp;",
      tags: ["en space", "enspace", "ensp", "полукруглая шпация"],
      group: ["Spaces", "2"],
      symbol: "[" . Chr(0x2002) . "]",
      symbolAlt: Chr(0x2002),
      symbolCustom: "underline"
    },
    "0000 emsp13", {
      unicode: "{U+2004}", html: "&#8196;", entity: "&emsp13;",
      tags: ["emsp13", "1/3emsp", "1/3 круглой Шпации"],
      group: ["Spaces", "3"],
      symbol: "[" . Chr(0x2004) . "]",
      symbolAlt: Chr(0x2004),
      symbolCustom: "underline"
    },
    "0000 emsp14", {
      unicode: "{U+2005}", html: "&#8196;", entity: "&emsp14;",
      tags: ["emsp14", "1/4emsp", "1/4 круглой Шпации"],
      group: ["Spaces", "4"],
      symbol: "[" . Chr(0x2005) . "]",
      symbolAlt: Chr(0x2005),
      symbolCustom: "underline"
    },
    "0000 thinspace", {
      unicode: "{U+2009}", html: "&#8201;", entity: "&thinsp;",
      tags: ["thinsp", "thin space", "узкий пробел", "тонкий пробел"],
      group: ["Spaces", "5"],
      symbol: "[" . Chr(0x2009) . "]",
      symbolAlt: Chr(0x2009),
      symbolCustom: "underline"
    },
    "0000 emsp16", {
      unicode: "{U+2006}", html: "&#8198;", entity: "&emsp16;",
      tags: ["emsp16", "1/6emsp", "1/6 круглой Шпации"],
      group: ["Spaces", "6"],
      symbol: "[" . Chr(0x2006) . "]",
      symbolAlt: Chr(0x2006),
      symbolCustom: "underline"
    },
    "0000 narrow_no_break_space", {
      unicode: "{U+202F}", html: "&#8239;",
      tags: ["nnbsp", "narrow no-break space", "узкий неразрывный пробел", "тонкий неразрывный пробел"],
      group: ["Spaces", "7"],
      symbol: "[" . Chr(0x202F) . "]",
      symbolAlt: Chr(0x202F),
      symbolCustom: "underline"
    },
    "0000 hairspace", {
      unicode: "{U+200A}", html: "&#8202;", entity: "&hairsp;",
      tags: ["hsp", "hairsp", "hair space", "волосяная шпация"],
      group: ["Spaces", "8"],
      symbol: "[" . Chr(0x200A) . "]",
      symbolAlt: Chr(0x200A),
      symbolCustom: "underline"
    },
    "0000 punctuation_space", {
      unicode: "{U+2008}", html: "&#8200;", entity: "&puncsp;",
      tags: ["psp", "puncsp", "punctuation space", "пунктуационный пробел"],
      group: ["Spaces", "9"],
      symbol: "[" . Chr(0x2008) . "]",
      symbolAlt: Chr(0x2008),
      symbolCustom: "underline"
    },
    "0000 zero_width_space", {
      unicode: "{U+200B}", html: "&#8200;", entity: "&NegativeVeryThinSpace;",
      tags: ["zwsp", "zero-width space", "пробел нулевой ширины"],
      group: ["Spaces", "0"],
      symbol: "[" . Chr(0x200B) . "]",
      symbolAlt: Chr(0x200B),
      symbolCustom: "underline"
    },
    "0000 word_joiner", {
      unicode: "{U+2060}", html: "&#8288;", entity: "&NoBreak;",
      tags: ["wj", "word joiner", "соединитель слов"],
      group: ["Spaces", "-"],
      symbol: "[" . Chr(0x2060) . "]",
      symbolAlt: Chr(0x2060),
      symbolCustom: "underline"
    },
    "0000 figure_space", {
      unicode: "{U+2007}", html: "&#8199;", entity: "&numsp;",
      tags: ["nsp", "numsp", "figure space", "цифровой пробел"],
      group: ["Spaces", "="],
      symbol: "[" . Chr(0x2007) . "]",
      symbolAlt: Chr(0x2007),
      symbolCustom: "underline"
    },
    "0000 no_break_space", {
      unicode: "{U+00A0}", html: "&#160;", entity: "&nbsp;",
      altcode: "0160",
      LaTeX: "~",
      tags: ["nbsp", "no-break space", "неразрывный пробел"],
      group: ["Spaces", SpaceKey],
      symbol: "[" . Chr(0x00A0) . "]",
      symbolAlt: Chr(0x00A0),
      symbolCustom: "underline"
    },
    "0000 emquad", {
      unicode: "{U+2001}", html: "&#8193;",
      LaTeX: "\qquad",
      tags: ["em quad", "emquad", "emqd", "em-квадрат"],
      group: ["Spaces", ExclamationMark],
      show_on_fast_keys: True,
      symbol: "[" . Chr(0x2001) . "]",
      symbolAlt: Chr(0x2001),
      symbolCustom: "underline"
    },
    "0000 enquad", {
      unicode: "{U+2000}", html: "&#8192;",
      LaTeX: "\quad",
      tags: ["en quad", "enquad", "enqd", "en-квадрат"],
      group: ["Spaces", [CommercialAt, QuotationDouble]],
      symbol: "[" . Chr(0x2000) . "]",
      symbolAlt: Chr(0x2000),
      symbolCustom: "underline"
    },
    ;
    ;
    ; ? Special Characters
    "0000 low_asterisk", {
      unicode: "{U+204E}", html: "&#8270;",
      tags: ["low asterisk", "нижний астериск"],
      group: ["Special Characters", ["a", "ф"]],
      symbol: Chr(0x204E)
    },
    "0000 two_asterisks", {
      unicode: "{U+2051}", html: "&#8273;",
      tags: ["two asterisks", "два астериска"],
      group: ["Special Characters", ["A", "Ф"]],
      symbol: Chr(0x2051)
    },
    "0000 asterism", {
      unicode: "{U+2042}", html: "&#8258;",
      tags: ["asterism", "астеризм"],
      group: ["Special Characters", CtrlA],
      symbol: Chr(0x2042)
    },
    "0000 colon_triangle", {
      unicode: "{U+02D0}", html: "&#720;",
      tags: ["triangle colon", "знак долготы"],
      group: ["Special Characters", [";", "ж"]],
      symbol: Chr(0x02D0)
    },
    "0000 colon_triangle_half", {
      unicode: "{U+02D1}", html: "&#721;",
      tags: ["half triangle colon", "знак полудолготы"],
      group: ["Special Characters", [":", "Ж"]],
      symbol: Chr(0x02D1)
    },
    "0000 dagger", {
      unicode: "{U+2020}", html: "&dagger;",
      LaTeX: "\dagger",
      tags: ["dagger", "даггер", "крест"],
      group: ["Special Characters", ["t", "е"]],
      symbol: Chr(0x2020)
    },
    "0000 dagger_double", {
      unicode: "{U+2021}", html: "&Dagger;",
      LaTeX: "\ddagger",
      tags: ["double dagger", "двойной даггер", "двойной крест"],
      group: ["Special Characters", ["T", "Е"]],
      symbol: Chr(0x2021)
    },
    "0000 dagger_tripple", {
      unicode: "{U+2E4B}", html: "&#11851;",
      tags: ["tripple dagger", "тройной даггер", "тройной крест"],
      group: ["Special Characters", CtrlT],
      symbol: Chr(0x2E4B)
    },
    "0000 fraction_slash", {
      unicode: "{U+2044}", html: "&#8260;",
      tags: ["fraction slash", "дробная черта"],
      group: ["Special Characters", "/"],
      symbol: Chr(0x2044)
    },
    "0000 grapheme_joiner", {
      unicode: "{U+034F}", html: "&#847;",
      tags: ["grapheme joiner", "соединитель графем"],
      group: ["Special Characters", ["g", "п"]],
      symbol: DottedCircle . Chr(0x034F)
    },
    "0000 prime_single", {
      unicode: "{U+2032}", html: "&#8242;", entity: "&prime;",
      LaTeX: "\prime",
      tags: ["prime", "штрих"],
      group: ["Special Characters", ["p", "з"]],
      symbol: Chr(0x2032)
    },
    "0000 prime_double", {
      unicode: "{U+2033}", html: "&#8243;", entity: "&Prime;",
      LaTeX: "\prime\prime",
      tags: ["double prime", "двойной штрих"],
      group: ["Special Characters", ["P", "З"]],
      symbol: Chr(0x2033)
    },
    "0000 permille", {
      unicode: "{U+2030}", html: "&#8240;", entity: "&permil;",
      altcode: "0137",
      LaTeX: "\permil",
      LaTeXPackage: "wasysym",
      tags: ["per mille", "промилле"],
      group: ["Special Characters", "5"],
      symbol: Chr(0x2030)
    },
    "0000 pertenthousand", {
      unicode: "{U+2031}", html: "&#8241;", entity: "&pertenk;",
      LaTeX: "\textpertenthousand",
      LaTeXPackage: "textcomp",
      tags: ["per ten thousand", "промилле", "базисный пункт", "basis point"],
      group: ["Special Characters", "%"],
      symbol: Chr(0x2031)
    },
    "0000 dotted_circle", {
      unicode: "{U+25CC}", html: "&#9676;",
      tags: ["пунктирный круг", "dottet circle"],
      group: ["Fast Keys Only", "Num0"],
      symbol: DottedCircle
    },
    ;
    ;
)

CharCodes := {}
CharCodes.acute := ["{U+0301}", "&#769;"]
CharCodes.dacute := ["{U+030B}", "&#779;"]
CharCodes.acutebelow := ["{U+0317}", "&#791;"]

CharCodes.asteriskabove := ["{U+20F0}", "&#8432;"]
CharCodes.asteriskbelow := ["{U+0359}", "&#857;"]

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
CharCodes.dgrave := ["{U+030F}", "&#783;"]
CharCodes.gravebelow := ["{U+0316}", "&#790;"]

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
CharCodes.fractionslash := ["{U+2044}", "&#8260;"]
CharCodes.dagger := ["{U+2020}", "&#8224;"]
CharCodes.ddagger := ["{U+2021}", "&#8225;"]
CharCodes.asterism := ["{U+2042}", "&#8258;"]
CharCodes.twoasterisks := ["{U+2051}", "&#8273;"]
CharCodes.lowasterisk := ["{U+204E}", "&#8270;"]
CharCodes.dash := ["{U+2010}", "&dash;"]
CharCodes.softhyphen := ["{U+00AD}", "&shy;"]
CharCodes.emdash := ["{U+2014}", "&mdash;"]
CharCodes.endash := ["{U+2013}", "&ndash;"]
CharCodes.numdash := ["{U+2012}", "&#8210;"]
CharCodes.twoemdash := ["{U+2E3A}", "&#11834;"]
CharCodes.threemdash := ["{U+2E3B}", "&#11835;"]
CharCodes.nbdash := ["{U+2011}", "&#8209;"]

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

CharCodes.plusminus := ["{U+00B1}", "&#177;"]
CharCodes.multiplication := ["{U+00D7}", "&#215;"]
CharCodes.twodotleader := ["{U+2025}", "&nldr;"]
CharCodes.ellipsis := ["{U+2026}", "&mldr;"]

CharCodes.smelter := {}
CharCodes.smelter.latin_Capital_AA := ["{U+A732}", "&#42802;"]
CharCodes.smelter.latin_Small_AA := ["{U+A733}", "&#42803;"]
CharCodes.smelter.latin_Capital_AE := ["{U+00C6}", "&#198;"]
CharCodes.smelter.latin_Small_AE := ["{U+00E6}", "U+00E6"]
CharCodes.smelter.latin_Capital_AU := ["{U+A736}", "&#42806;"]
CharCodes.smelter.latin_Small_AU := ["{U+A737}", "&#42807;"]
CharCodes.smelter.latin_Capital_OE := ["{U+0152}", "&#338;"]
CharCodes.smelter.latin_Small_OE := ["{U+0153}", "&#339;"]
CharCodes.smelter.ff := ["{U+FB00}", "&#64256;"]
CharCodes.smelter.fl := ["{U+FB02}", "&#64258;"]
CharCodes.smelter.fi := ["{U+FB01}", "&#64257;"]
CharCodes.smelter.ft := ["{U+FB05}", "&#64261;"]
CharCodes.smelter.ffi := ["{U+FB03}", "&#64259;"]
CharCodes.smelter.ffl := ["{U+FB04}", "&#64260;"]
CharCodes.smelter.st := ["{U+FB06}", "&#64262;"]
CharCodes.smelter.ts := ["{U+02A6}", "&#678;"]

CharCodes.smelter.latin_Capital_ij := ["{U+0132}", "&#306;"]
CharCodes.smelter.latin_Small_ij := ["{U+0133}", "&#307;"]
CharCodes.smelter.latin_Capital_LJ := ["{U+01C7}", "&#455;"]
CharCodes.smelter.latin_Capital_L_Small_j := ["{U+01C8}", "&#456;"]
CharCodes.smelter.latin_Small_LJ := ["{U+01C9}", "&#457;"]
CharCodes.smelter.latin_Capital_Fs := ["{U+1E9E}", "&#7838;"]
CharCodes.smelter.latin_Small_Fs := ["{U+00DF}", "&#223;"]
CharCodes.smelter.latin_Small_UE := ["{U+1D6B}", "&#7531;"]
CharCodes.smelter.latin_Capital_OO := ["{U+A74E}", "&#42830;"]
CharCodes.smelter.latin_Small_OO := ["{U+A74F}", "&#42831;"]
CharCodes.smelter.latin_Small_ie := ["{U+AB61}", "&#43873;"]


CharCodes.smelter.cyrillic_Capital_ie := ["{U+0464}", "&#1124;"]
CharCodes.smelter.cyrillic_Small_ie := ["{U+0465}", "&#1125;"]
CharCodes.smelter.cyrillic_Capital_Ukraine_E := ["{U+0404}", "&#1028;"]
CharCodes.smelter.cyrillic_Small_Ukraine_E := ["{U+0454}", "&#1108;"]
CharCodes.smelter.cyrillic_Captial_Yat := ["{U+0462}", "&#1122;"]
CharCodes.smelter.cyrillic_Small_Yar := ["{U+0463}", "&#1123;"]
CharCodes.smelter.cyrillic_Capital_Big_Yus := ["{U+046A}", "&#1130;"]
CharCodes.smelter.cyrillic_Small_Big_Yus := ["{U+046B}", "&#1131;"]
CharCodes.smelter.cyrillic_Capital_Little_Yus := ["{U+0466}", "&#1126;"]
CharCodes.smelter.cyrillic_Small_Little_Yus := ["{U+0467}", "&#1127;"]
CharCodes.smelter.cyrillic_Captial_Yat_Iotified := ["{U+A652}", "&#42578;"]
CharCodes.smelter.cyrillic_Small_Yat_Iotified := ["{U+A653}", "&#42579;"]
CharCodes.smelter.cyrillic_Captial_A_Iotified := ["{U+A656}", "&#42582;"]
CharCodes.smelter.cyrillic_Small_A_Iotified := ["{U+A657}", "&#42583;"]
CharCodes.smelter.cyrillic_Captial_Big_Yus_Iotified := ["{U+046C}", "&#1132;"]
CharCodes.smelter.cyrillic_Small_Big_Yus_Iotified := ["{U+046D}", "&#1133;"]
CharCodes.smelter.cyrillic_Captial_Little_Yus_Iotified := ["{U+0468}", "&#1128;"]
CharCodes.smelter.cyrillic_Small_Little_Yus_Iotified := ["{U+0469}", "&#1129;"]


UniTrim(str) {
  return SubStr(str, 4, StrLen(str) - 4)
}
/*
BindDiacriticF1 := [
  [["a", "ф"], [Characters["acute"].unicode, Characters["acute"].html], Characters["acute"].tags],
  [["A", "Ф"], [Characters["acute_double"].unicode, Characters["acute_double"].html], Characters["acute_double"].tags],
  [["b", "и"], [Characters["breve"].unicode, Characters["breve"].html], Characters["breve"].tags],
  [["B", "И"], [Characters["breve_inverted"].unicode, Characters["breve_inverted"].html], Characters["breve_inverted"].tags],
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
*/

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
  [["a", "ф"], CharCodes.asteriskabove, ["Астериск сверху", "Asterisk Above"]],
  [["A", "Ф"], CharCodes.asteriskbelow, ["Астериск снизу", "Asterisk Below"]],
  [["b", "и"], CharCodes.bridgeabove, ["Мостик сверху", "Bridge Above"]],
  [["B", "И"], CharCodes.bridgebelow, ["Мостик снизу", "Bridge Below"]],
  [CtrlB, CharCodes.ibridgebelow, ["Перевёрнутый мостик снизу", "Inverted Bridge Below"]],
]

BindSpaces := [
  ["1", CharCodes.emsp, ["Em Space", "EmSP", "EM_SPACE", "Круглая Шпация"]],
  ["2", CharCodes.ensp, ["En Space", "EnSP", "EN_SPACE", "Полукруглая Шпация"]],
  ["3", CharCodes.emsp13, ["1/3 Em Space", "1/3EmSP", "13 Em Space", "EmSP13", "1/3_SPACE", "1/3 Круглой Шпация"]],
  ["4", CharCodes.emsp14, ["1/4 Em Space", "1/4EmSP", "14 Em Space", "EmSP14", "1/4_SPACE", "1/4 Круглой Шпация"]],
  ["5", CharCodes.thinsp, ["Thin Space", "ThinSP", "Тонкий Пробел", "Узкий Пробел"]],
  ["6", CharCodes.emsp16, ["1/6 Em Space", "1/6EmSP", "16 Em Space", "EmSP16", "1/6_SPACE", "1/6 Круглой Шпация"]],
  ["7", CharCodes.nnbsp, ["Thin No-Break Space", "ThinNoBreakSP", "Тонкий Неразрывный Пробел", "Узкий Неразрывный Пробел"]],
  ["8", CharCodes.hairsp, ["Hair Space", "HairSP", "Волосяная Шпация"]],
  ["9", CharCodes.puncsp, ["Punctuation Space", "PunctuationSP", "Пунктуационный Пробел"]],
  ["0", CharCodes.zwsp, ["Zero-Width Space", "ZeroWidthSP", "Пробел Нулевой Ширины"]],
  ["-", CharCodes.wj, ["Zero-Width No-Break Space", "ZeroWidthSP", "Word Joiner", "WJoiner", "Неразрывный Пробел Нулевой Ширины", "Соединитель слов"]],
  ["=", CharCodes.numsp, ["Number Space", "NumSP", "Figure Space", "FigureSP", "Цифровой пробел"]],
  [SpaceKey, CharCodes.nbsp, ["No-Break Space", "NBSP", "Неразрывный Пробел"]],
]

BindSpecialF6 := [
  [["a", "ф"], CharCodes.lowasterisk, ["Низкий астериск", "Low Asterisk"]],
  [["A", "Ф"], CharCodes.twoasterisks, ["Два астериска", "Two Asterisks"]],
  [CtrlA, CharCodes.asterism, ["Астеризм", "Asterism"]],
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
  ["AA", CharCodes.smelter.latin_Capital_AA[1]],
  ["aa", CharCodes.smelter.latin_Small_AA[1]],
  ["AE", CharCodes.smelter.latin_Capital_AE[1]],
  ["ae", CharCodes.smelter.latin_Small_AE[1]],
  ["AU", CharCodes.smelter.latin_Capital_AU[1]],
  ["au", CharCodes.smelter.latin_Small_AU[1]],
  ["OE", CharCodes.smelter.latin_Capital_OE[1]],
  ["oe", CharCodes.smelter.latin_Small_OE[1]],
  ["ff", CharCodes.smelter.ff[1]],
  ["fl", CharCodes.smelter.fl[1]],
  ["fi", CharCodes.smelter.fi[1]],
  ["ft", CharCodes.smelter.ft[1]],
  ["ffi", CharCodes.smelter.ffi[1]],
  ["ffl", CharCodes.smelter.ffl[1]],
  ["st", CharCodes.smelter.st[1]],
  ["ts", CharCodes.smelter.ts[1]],
  ["IJ", CharCodes.smelter.latin_Capital_ij[1]],
  ["ij", CharCodes.smelter.latin_Small_ij[1]],
  ["LJ", CharCodes.smelter.latin_Capital_LJ[1]],
  ["Lj", CharCodes.smelter.latin_Capital_L_Small_j[1]],
  ["lj", CharCodes.smelter.latin_Small_LJ[1]],
  ["FS", CharCodes.smelter.latin_Capital_Fs[1]],
  ["fs", CharCodes.smelter.latin_Small_Fs[1]],
  ["ue", CharCodes.smelter.latin_Small_UE[1]],
  ["OO", CharCodes.smelter.latin_Capital_OO[1]],
  ["oo", CharCodes.smelter.latin_Small_OO[1]],
  ["ie", CharCodes.smelter.latin_Small_ie[1]],
  ; Cyrillic
  ["Э", CharCodes.smelter.cyrillic_Capital_Ukraine_E[1]],
  ["э", CharCodes.smelter.cyrillic_Small_Ukraine_E[1]],
  [["ІЄ", "ІЭ"], CharCodes.smelter.cyrillic_Capital_ie[1]],
  [["іє", "іэ"], CharCodes.smelter.cyrillic_Small_ie[1]],
  ["ТЬ", CharCodes.smelter.cyrillic_Captial_Yat[1]],
  ["ть", CharCodes.smelter.cyrillic_Small_Yar[1]],
  ["УЖ", CharCodes.smelter.cyrillic_Capital_Big_Yus[1]],
  ["уж", CharCodes.smelter.cyrillic_Small_Big_Yus[1]],
  ["АТ", CharCodes.smelter.cyrillic_Capital_Little_Yus[1]],
  ["ат", CharCodes.smelter.cyrillic_Small_Little_Yus[1]],
  [["ІѢ", "ІТЬ"], CharCodes.smelter.cyrillic_Captial_Yat_Iotified[1]],
  [["іѣ", "іть"], CharCodes.smelter.cyrillic_Small_Yat_Iotified[1]],
  ["ІА", CharCodes.smelter.cyrillic_Captial_A_Iotified[1]],
  ["іа", CharCodes.smelter.cyrillic_Small_A_Iotified[1]],
  [["ІѪ", "ІУЖ"], CharCodes.smelter.cyrillic_Captial_Big_Yus_Iotified[1]],
  [["іѫ", "іуж"], CharCodes.smelter.cyrillic_Small_Big_Yus_Iotified[1]],
  [["ІѦ", "ІАТ"], CharCodes.smelter.cyrillic_Captial_Little_Yus_Iotified[1]],
  [["іѧ", "іат"], CharCodes.smelter.cyrillic_Small_Little_Yus_Iotified[1]],
  ; Other
  [["-----", "3-"], CharCodes.threemdash[1]],
  [["----", "2-"], CharCodes.twoemdash[1]],
  ["---", CharCodes.emdash[1]],
  ["--", CharCodes.endash[1]],
  ["-+", CharCodes.plusminus[1]],
  ["-*", CharCodes.multiplication[1]],
  ["***", CharCodes.asterism[1]],
  ["**", CharCodes.twoasterisks[1]],
  ["*", CharCodes.lowasterisk[1]],
  ["...", CharCodes.ellipsis[1]],
  ["..", CharCodes.twodotleader[1]],
  ["-", CharCodes.softhyphen[1]],
  [".-", CharCodes.dash[1]],
  ["n-", CharCodes.numdash[1]],
  ["0-", CharCodes.nbdash[1]],
]

InputBridgeOld(BindsArray) {
  ih := InputHook("L1 C M", "L")
  ih.Start()
  ih.Wait()
  keyPressed := ih.Input
  for index, pair in BindsArray {
    if IsObject(pair[1]) {
      for _, key in pair[1] {
        if (keyPressed == key) {
          if IsObject(pair[2]) {

            Send(pair[2][1])

          } else {
            Send(pair[2])
          }
          return
        }
      }
    } else {
      if (keyPressed == pair[1]) {
        if IsObject(pair[2]) {

          Send(pair[2][1])

        } else {
          Send(pair[2])
        }
        return
      }
    }
  }
  ih.Stop()
}


InputBridge(GroupKey) {
  ih := InputHook("L1 C M", "L")
  ih.Start()
  ih.Wait()
  keyPressed := ih.Input
  ; InputMode


  for characterEntry, value in Characters {
    if (HasProp(value, "group") && value.group[1] == GroupKey) {
      characterKeys := value.group[2]
      characterEntity := (HasProp(value, "entity")) ? value.entity : value.html
      characterLaTeX := (HasProp(value, "LaTeX")) ? value.LaTeX : ""

      if IsObject(characterKeys) {
        for _, key in characterKeys {
          if (keyPressed == key) {
            if InputMode = "HTML" {
              SendText(characterEntity)
            } else if InputMode = "LaTeX" && HasProp(value, "LaTeX") {
              if IsObject(characterLaTeX) {
                if LaTeXMode = "common"
                  SendText(characterLaTeX[1])
                else if LaTeXMode = "math"
                  SendText(characterLaTeX[2])
              } else {
                SendText(characterLaTeX)
              }
            }
            else
              Send(value.unicode)
            break
          }
        }
      } else {
        if (keyPressed == characterKeys) {
          if InputMode = "HTML" {
            SendText(characterEntity)
          } else if InputMode = "LaTeX" && HasProp(value, "LaTeX") {
            if IsObject(characterLaTeX) {
              if LaTeXMode = "common"
                SendText(characterLaTeX[1])
              else if LaTeXMode = "math"
                SendText(characterLaTeX[2])
            } else {
              SendText(characterLaTeX)
            }
          }
          else
            Send(value.unicode)
          break
        }
      }
    }
  }

  ih.Stop()
  return
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

  PromptValue := IniRead(ConfigFile, "LatestPrompts", "Search", "")
  IB := InputBox(ReadLocale("symbol_search_prompt"), ReadLocale("symbol_search"), "w256 h92", PromptValue)

  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value

  if (PromptValue = "\") {
    Reload
    return
  }

  Found := False
  for characterEntry, value in Characters {
    characterEntity := (HasProp(value, "entity")) ? value.entity : value.html
    characterLaTeX := (HasProp(value, "LaTeX")) ? value.LaTeX : ""

    for _, tag in value.tags {
      if (StrLower(PromptValue) = StrLower(tag)) {
        if InputMode = "HTML" {
          SendText(characterEntity)
        } else if InputMode = "LaTeX" && HasProp(value, "LaTeX") {
          if IsObject(characterLaTeX) {
            if LaTeXMode = "common"
              SendText(characterLaTeX[1])
            else if LaTeXMode = "math"
              SendText(characterLaTeX[2])
          } else {
            SendText(characterLaTeX)
          }
        }
        else
          Send(value.unicode)
        IniWrite PromptValue, ConfigFile, "LatestPrompts", "Search"
        Found := True
        break 2
      }
    }
  }

  if !Found {
    MsgBox "Знак не найден."
  }
}


InsertUnicodeKey() {
  PromptValue := IniRead(ConfigFile, "LatestPrompts", "Unicode", "")
  IB := InputBox(ReadLocale("symbol_code_prompt"), ReadLocale("symbol_unicode"), "w256 h92", PromptValue)

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

ToRomanNumeral(IntValue, CapitalLetters := True) {
  IntValue := Integer(IntValue)
  if (IntValue < 1 || IntValue > 2000000) {
    return
  }

  RomanNumerals := []

  for key, value in RoNum {
    entryName := RegExReplace(key, "^\S+-")
    if CapitalLetters == True && !RegExMatch(entryName, "^s") || CapitalLetters == False && RegExMatch(entryName, "^s")
      RomanNumerals.Push(value)
  }

  Values := [100000, 50000, 10000, 5000, 1000, 500, 100, 50, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  RomanStr := ""

  for i, v in Values {
    while (IntValue >= v) {
      RomanStr .= RomanNumerals[i]
      IntValue -= v
    }
  }
  return RomanStr
}

SwitchToRoman() {
  LanguageCode := GetLanguageCode()

  PromptValue := IniRead(ConfigFile, "LatestPrompts", "RomanNumeral", "")

  IB := InputBox(ReadLocale("symbol_roman_numeral_prompt"), ReadLocale("symbol_roman_numeral"), "w256 h92", PromptValue)
  if IB.Result = "Cancel"
    return
  else {
    if (Integer(IB.Value) < 1 || Integer(IB.Value) > 2000000) {
      MsgBox(ReadLocale("warning_roman_2m"), DSLPadTitle, "Icon!")
      return
    }
    PromptValue := ToRomanNumeral(Integer(IB.Value))

    IniWrite IB.Value, ConfigFile, "LatestPrompts", "RomanNumeral"
  }
  SendText(PromptValue)
}


InsertAltCodeKey() {
  PromptValue := IniRead(ConfigFile, "LatestPrompts", "Altcode", "")
  IB := InputBox(ReadLocale("symbol_code_prompt"), ReadLocale("symbol_altcode"), "w256 h92", PromptValue)
  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value

  AltCodes := StrSplit(PromptValue, " ")

  for code in AltCodes {
    if (code ~= "^\d+$") {
      SendAltNumpad(code)
    } else {
      MsgBox(ReadLocale("warning_only_nums"), ReadLocale("symbol_altcode"), 0x30)
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


Ligaturise(SmeltingMode := "InputBox") {
  LanguageCode := GetLanguageCode()
  BackupClipboard := ""

  if (SmeltingMode = "InputBox") {
    PromptValue := IniRead(ConfigFile, "LatestPrompts", "Ligature", "")
    IB := InputBox(ReadLocale("symbol_smelting_prompt"), ReadLocale("symbol_smelting"), "w256 h92", PromptValue)
    if IB.Result = "Cancel"
      return
    else
      PromptValue := IB.Value
  } else if (SmeltingMode = "Clipboard" || SmeltingMode = "Backspace") {
    BackupClipboard := A_Clipboard
    A_Clipboard := ""

    if (SmeltingMode = "Backspace") {
      Send("^+{Left}")
      Sleep 120
    }
    Send("^c")
    Sleep 120
    PromptValue := A_Clipboard
    Sleep 50
  }

  Found := False
  OriginalValue := PromptValue
  NewValue := ""
  for index, pair in LigaturesDictionary {
    if IsObject(pair[1]) {
      for _, key in pair[1] {
        if (PromptValue == key) {
          Send(pair[2])
          IniWrite PromptValue, ConfigFile, "LatestPrompts", "Ligature"
          Found := True
        }
      }
    }
    else if (PromptValue == pair[1]) {
      Send(pair[2])
      IniWrite PromptValue, ConfigFile, "LatestPrompts", "Ligature"
      Found := True
    }
  }


  if (!Found && (SmeltingMode = "Clipboard" || SmeltingMode = "Backspace")) {
    SplitWords := StrSplit(OriginalValue, " ")

    for i, word in SplitWords {
      TempValue := word
      for index, pair in LigaturesDictionary {
        if IsObject(pair[1]) {
          for _, key in pair[1] {
            if InStr(TempValue, key, true) {
              TempValue := StrReplace(TempValue, key, pair[2])
            }
          }
        } else {
          if InStr(TempValue, pair[1], true) {
            TempValue := StrReplace(TempValue, pair[1], pair[2])
          }
        }
      }
      NewValue .= TempValue . " "
    }

    NewValue := RTrim(NewValue)

    if (NewValue != OriginalValue) {
      Send(NewValue)
      Found := True
    }
  }

  if (!Found) {
    MsgBox(ReadLocale("warning_recipe_absent"), ReadLocale("symbol_smelting"), 0x30)
  }

  if (SmeltingMode = "Clipboard" || SmeltingMode = "Backspace") {
    A_Clipboard := BackupClipboard
  }
  return
}

<#<!F1:: {
  ShowInfoMessage(["Активна первая группа диакритики", "Primary diacritics group has been activated"], "[F1] " . DSLPadTitle, , SkipGroupMessage)
  InputBridge("Diacritics Primary")
}
<#<!F2:: {
  ShowInfoMessage(["Активна вторая группа диакритики", "Secondary diacritics group has been activated"], "[F2] " . DSLPadTitle, , SkipGroupMessage)
  InputBridge("Diacritics Secondary")
}
<#<!F3:: {
  ShowInfoMessage(["Активна третья группа диакритики", "Tertiary diacritics group has been activated"], "[F3] " . DSLPadTitle, , SkipGroupMessage)
  InputBridge("Diacritics Tertiary")
}
<#<!F6:: {
  ShowInfoMessage(["Активна группа специальных символов", "Special characters group has been activated"], "[F6] " . DSLPadTitle, , SkipGroupMessage)
  InputBridge("Special Characters")
}
<#<!Space:: {
  ShowInfoMessage(["Активна группа шпаций", "Space group has been activated"], "[Space] " . DSLPadTitle, , SkipGroupMessage)
  InputBridge("Spaces")
}
<#<!f:: SearchKey()
<#<!u:: InsertUnicodeKey()
<#<!a:: InsertAltCodeKey()
<#<!l:: Ligaturise()
>+l:: Ligaturise("Clipboard")
>+Backspace:: Ligaturise("Backspace")
<#<!1:: SwitchToScript("sup")
<#<^>!1:: SwitchToScript("sub")
<#<^>!2:: SwitchToRoman()

<#<!m:: ToggleGroupMessage()

<#<!PgUp:: FindCharacterPage()


GetCharacterUnicode(symbol) {
  return format("{:x}", ord(symbol))
}

FindCharacterPage() {
  BackupClipboard := A_Clipboard
  PromptValue := ""
  A_Clipboard := ""

  Send("^c")
  Sleep 120
  PromptValue := A_Clipboard
  Sleep 50
  PromptValue := GetCharacterUnicode(PromptValue)

  if (PromptValue != "") {
    Run("https://symbl.cc/" . GetLanguageCode() . "/" . PromptValue)
  }

  A_Clipboard := BackupClipboard
}


ToggleGroupMessage()
{
  LanguageCode := GetLanguageCode()
  global SkipGroupMessage, ConfigFile
  SkipGroupMessage := !SkipGroupMessage
  IniWrite (SkipGroupMessage ? "True" : "False"), ConfigFile, "Settings", "SkipGroupMessage"

  ActivationMessage := {}
  ActivationMessage[] := Map()
  ActivationMessage["ru"] := {}
  ActivationMessage["en"] := {}
  ActivationMessage["ru"].Active := "Сообщения активации групп включены"
  ActivationMessage["ru"].Deactive := "Сообщения активации групп отключены"
  ActivationMessage["en"].Active := "Activation messages for groups enabled"
  ActivationMessage["en"].Deactive := "Activation messages for groups disabled"
  MsgBox(SkipGroupMessage ? ActivationMessage[LanguageCode].Deactive : ActivationMessage[LanguageCode].Active, DSLPadTitle, 0x40)

  return
}

; Setting up of Diacritics-Spaces-Letters KeyPad

LocaliseArrayKeys(ObjectPath) {
  for index, item in ObjectPath {
    if IsObject(item[1]) {
      item[1] := item[1][GetLanguageCode()]
    }
  }
}

<#<!Home:: OpenPanel()

OpenPanel(*)
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


CommonInfoFonts := {
  preview: "Cambria",
  previewSize: "s72",
  previewSmaller: "s40",
  titleSize: "s14",
}

SwitchLanguage(LanguageCode) {
  IniWrite LanguageCode, ConfigFile, "Settings", "UserLanguage"

  if (IsGuiOpen(DSLPadTitle))
  {
    WinClose(DSLPadTitle)
  }

  DSLPadGUI := Constructor()
  DSLPadGUI.Show()

  ManageTrayItems()
}

Constructor()
{
  CheckUpdate()
  ManageTrayItems()

  screenWidth := A_ScreenWidth
  screenHeight := A_ScreenHeight

  windowWidth := 850
  windowHeight := 550
  xPos := screenWidth - windowWidth - 45
  yPos := screenHeight - windowHeight - 90

  DSLTabs := []
  DSLCols := { default: [], smelting: [] }

  for _, localeKey in ["diacritics", "letters", "spaces", "commands", "smelting", "fastkeys", "about", "useful", "changelog"] {
    DSLTabs.Push(ReadLocale("tab_" . localeKey))
  }

  for _, localeKey in ["name", "key", "view", "unicode"] {
    DSLCols.default.Push(ReadLocale("col_" . localeKey))
  }

  for _, localeKey in ["name", "recipe", "result", "unicode"] {
    DSLCols.smelting.Push(ReadLocale("col_" . localeKey))
  }

  DSLContent := {}
  DSLContent[] := Map()
  DSLContent["BindList"] := {}
  DSLContent["ru"] := {}
  DSLContent["en"] := {}

  CommonInfoBox := {
    body: "x650 y35 w200 h510",
    bodyText: ReadLocale("character"),
    previewFrame: "x685 y80 w128 h128 Center",
    preview: "x685 y80 w128 h128 readonly Center -VScroll -HScroll",
    previewText: "◌͏",
    title: "x655 y215 w190 h150 Center BackgroundTrans",
    titleText: "N/A",
    LaTeXTitleA: "x689 y371 w128 h24 BackgroundTrans",
    LaTeXTitleAText: "A",
    LaTeXTitleE: "x703 y375 w128 h24 BackgroundTrans",
    LaTeXTitleEText: "E",
    LaTeXTitleLTX: "x685 y373 w128 h24 BackgroundTrans",
    LaTeXTitleLTXText: "L T  X",
    LaTeXPackage: "x685 y373 w128 h24 BackgroundTrans Right",
    LaTeXPackageText: "",
    LaTeX: "x685 y390 w128 h24 readonly Center -VScroll -HScroll",
    LaTeXText: "N/A",
    alt: "x685 y430 w128 h24 readonly Center -VScroll -HScroll",
    altTitle: "x685 y415 w128 h24 BackgroundTrans",
    altTitleText: Map("ru", "Альт-код", "en", "Alt-code"),
    altText: "N/A",
    unicode: "x685 y470 w128 h24 readonly Center -VScroll -HScroll",
    unicodeTitle: "x685 y455 w128 h24 BackgroundTrans",
    unicodeTitleText: Map("ru", "Юникод", "en", "Unicode"),
    unicodeText: "U+0000",
    html: "x685 y510 w128 h24 readonly Center -VScroll -HScroll",
    htmlText: "&#x0000;",
    htmlTitle: "x685 y495 w128 h24 BackgroundTrans",
    htmlTitleText: Map("ru", "HTML-Код/Мнемоника", "en", "HTML/Entity"),
  }

  LanguageCode := GetLanguageCode()

  DSLPadGUI := Gui()

  ColumnWidths := [300, 140, 60, 85]
  ThreeColumnWidths := [300, 150, 160]
  ColumnAreaWidth := "w620"
  ColumnAreaHeight := "h510"
  ColumnAreaRules := "+NoSort -Multi"
  ColumnListStyle := ColumnAreaWidth . " " . ColumnAreaHeight . " " . ColumnAreaRules

  Tab := DSLPadGUI.Add("Tab3", "w" windowWidth " h" windowHeight, DSLTabs)
  DSLPadGUI.SetFont("s11")
  Tab.UseTab(1)

  DiacriticLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLCols.default)
  DiacriticLV.ModifyCol(1, ColumnWidths[1])
  DiacriticLV.ModifyCol(2, ColumnWidths[2])
  DiacriticLV.ModifyCol(3, ColumnWidths[3])
  DiacriticLV.ModifyCol(4, ColumnWidths[4])


  DSLContent["BindList"].TabDiacritics := []

  InsertCharactersGroups(DSLContent["BindList"].TabDiacritics, "Diacritics Primary", "Win Alt F1", False)
  InsertCharactersGroups(DSLContent["BindList"].TabDiacritics, "Diacritics Secondary", "Win Alt F2")
  InsertCharactersGroups(DSLContent["BindList"].TabDiacritics, "Diacritics Tertiary", "Win Alt F3")

  for item in DSLContent["BindList"].TabDiacritics
  {
    DiacriticLV.Add(, item[1], item[2], item[3], item[4])
  }

  GrouBoxDiacritic := {
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.body, CommonInfoBox.bodyText),
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.previewFrame),
    preview: DSLPadGUI.Add("Edit", "vDiacriticSymbol " . commonInfoBox.preview, CommonInfoBox.previewText),
    title: DSLPadGUI.Add("Text", "vDiacriticTitle " . commonInfoBox.title, CommonInfoBox.titleText),
    ;
    LaTeXTitleLTX: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleLTX, CommonInfoBox.LaTeXTitleLTXText).SetFont("s10", "Cambria"),
    LaTeXTitleA: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleA, CommonInfoBox.LaTeXTitleAText).SetFont("s9", "Cambria"),
    LaTeXTitleE: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleE, CommonInfoBox.LaTeXTitleEText).SetFont("s10", "Cambria"),
    LaTeXPackage: DSLPadGUI.Add("Text", "vDiacriticLaTeXPackage " . CommonInfoBox.LaTeXPackage, CommonInfoBox.LaTeXPackageText).SetFont("s9"),
    LaTeX: DSLPadGUI.Add("Edit", "vDiacriticLaTeX " . commonInfoBox.LaTeX, CommonInfoBox.LaTeXText),
    ;
    altTitle: DSLPadGUI.Add("Text", CommonInfoBox.altTitle, CommonInfoBox.altTitleText[LanguageCode]).SetFont("s9"),
    alt: DSLPadGUI.Add("Edit", "vDiacriticAlt " . commonInfoBox.alt, CommonInfoBox.altText),
    ;
    unicodeTitle: DSLPadGUI.Add("Text", CommonInfoBox.unicodeTitle, CommonInfoBox.unicodeTitleText[LanguageCode]).SetFont("s9"),
    unicode: DSLPadGUI.Add("Edit", "vDiacriticUnicode " . commonInfoBox.unicode, CommonInfoBox.unicodeText),
    ;
    htmlTitle: DSLPadGUI.Add("Text", CommonInfoBox.htmlTitle, CommonInfoBox.htmlTitleText[LanguageCode]).SetFont("s9"),
    html: DSLPadGUI.Add("Edit", "vDiacriticHTML " . commonInfoBox.html, CommonInfoBox.htmlText),
  }

  GrouBoxDiacritic.preview.SetFont(CommonInfoFonts.previewSize, CommonInfoFonts.preview)
  GrouBoxDiacritic.title.SetFont(CommonInfoFonts.titleSize, CommonInfoFonts.preview)
  GrouBoxDiacritic.LaTeX.SetFont("s12")
  GrouBoxDiacritic.alt.SetFont("s12")
  GrouBoxDiacritic.unicode.SetFont("s12")
  GrouBoxDiacritic.html.SetFont("s12")


  Tab.UseTab(2)

  LettersLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLCols.default)
  LettersLV.ModifyCol(1, ColumnWidths[1])
  LettersLV.ModifyCol(2, ColumnWidths[2])
  LettersLV.ModifyCol(3, ColumnWidths[3])
  LettersLV.ModifyCol(4, ColumnWidths[4])

  DSLContent["BindList"].TabLetters := []

  for item in DSLContent["BindList"].TabLetters
  {
    LettersLV.Add(, item[1], item[2], item[3], item[4])
  }

  GrouBoxLetters := {
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.body, CommonInfoBox.bodyText),
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.previewFrame),
    preview: DSLPadGUI.Add("Edit", "vLettersSymbol " . commonInfoBox.preview, CommonInfoBox.previewText),
    title: DSLPadGUI.Add("Text", "vLettersTitle " . commonInfoBox.title, CommonInfoBox.titleText),
    ;
    LaTeXTitleLTX: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleLTX, CommonInfoBox.LaTeXTitleLTXText).SetFont("s10", "Cambria"),
    LaTeXTitleA: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleA, CommonInfoBox.LaTeXTitleAText).SetFont("s9", "Cambria"),
    LaTeXTitleE: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleE, CommonInfoBox.LaTeXTitleEText).SetFont("s10", "Cambria"),
    LaTeXPackage: DSLPadGUI.Add("Text", "vLettersLaTeXPackage " . CommonInfoBox.LaTeXPackage, CommonInfoBox.LaTeXPackageText).SetFont("s9"),
    LaTeX: DSLPadGUI.Add("Edit", "vLettersLaTeX " . commonInfoBox.LaTeX, CommonInfoBox.LaTeXText),
    ;
    altTitle: DSLPadGUI.Add("Text", CommonInfoBox.altTitle, CommonInfoBox.altTitleText[LanguageCode]).SetFont("s9"),
    alt: DSLPadGUI.Add("Edit", "vLettersAlt " . commonInfoBox.alt, CommonInfoBox.altText),
    ;
    unicodeTitle: DSLPadGUI.Add("Text", CommonInfoBox.unicodeTitle, CommonInfoBox.unicodeTitleText[LanguageCode]).SetFont("s9"),
    unicode: DSLPadGUI.Add("Edit", "vLettersUnicode " . commonInfoBox.unicode, CommonInfoBox.unicodeText),
    ;
    htmlTitle: DSLPadGUI.Add("Text", CommonInfoBox.htmlTitle, CommonInfoBox.htmlTitleText[LanguageCode]).SetFont("s9"),
    html: DSLPadGUI.Add("Edit", "vLettersHTML " . commonInfoBox.html, CommonInfoBox.htmlText),
  }

  GrouBoxLetters.preview.SetFont(CommonInfoFonts.previewSize, CommonInfoFonts.preview)
  GrouBoxLetters.title.SetFont(CommonInfoFonts.titleSize, CommonInfoFonts.preview)
  GrouBoxLetters.LaTeX.SetFont("s12")
  GrouBoxLetters.alt.SetFont("s12")
  GrouBoxLetters.unicode.SetFont("s12")
  GrouBoxLetters.html.SetFont("s12")


  Tab.UseTab(3)
  DSLContent["BindList"].Spaces := [
    ["", "Win Alt Space", "", ""],
    [Map("ru", "Круглая шпация", "en", "Em Space"), "[1]", "[ ]", UniTrim(CharCodes.emsp[1])],
    [Map("ru", "Полукруглая шпация", "en", "En Space"), "[2]", "[ ]", UniTrim(CharCodes.ensp[1])],
    [Map("ru", "⅓ Круглой шпации", "en", "⅓ Em Space"), "[3]", "[ ]", UniTrim(CharCodes.emsp13[1])],
    [Map("ru", "¼ Круглой шпации", "en", "¼ Em Space"), "[4]", "[ ]", UniTrim(CharCodes.emsp14[1])],
    [Map("ru", "Узкий пробел", "en", "Thin Space"), "[5]", "[ ]", UniTrim(CharCodes.thinsp[1])],
    [Map("ru", "⅙ Круглой шпации", "en", "⅙ Em Space"), "[6]", "[ ]", UniTrim(CharCodes.emsp16[1])],
    [Map("ru", "Узкий неразрывный пробел", "en", "Narrow No-Break Space"), "[7]", "[ ]", UniTrim(CharCodes.nnbsp[1])],
    [Map("ru", "Волосяная шпация", "en", "Hair Space"), "[8]", "[ ]", UniTrim(CharCodes.hairsp[1])],
    [Map("ru", "Пунктуационный пробел", "en", "Punctuation Space"), "[9]", "[ ]", UniTrim(CharCodes.puncsp[1])],
    [Map("ru", "Пробел нулевой ширины", "en", "Zero-Width Space"), "[0]", "[​]", UniTrim(CharCodes.zwsp[1])],
    [Map("ru", "Соединитель слов", "en", "Word Joiner"), "[-]", "[⁠]", UniTrim(CharCodes.wj[1])],
    [Map("ru", "Цифровой пробел", "en", "Figure Space"), "[=]", "[ ]", UniTrim(CharCodes.numsp[1])],
    [Map("ru", "Неразрывный пробел", "en", "No-Break Space"), "[Space]", "[ ]", UniTrim(CharCodes.nbsp[1])],
    ["", "", "", ""],
    ["", "Win Alt F6", "", ""],
    [Map("ru", "Низкий астериск", "en", "Low Asterisk"), "[a][ф]", "⁎", UniTrim(CharCodes.lowasterisk[1])],
    [Map("ru", "Два астериска", "en", "Two Asterisk"), "[A][Ф]", "⁑", UniTrim(CharCodes.twoasterisks[1])],
    [Map("ru", "Астеризм", "en", "Asterism"), "LCtrl [a][ф]", "⁂", UniTrim(CharCodes.asterism[1])],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].Spaces)

  DSLContent["BindList"].TabSpaces := []
  InsertCharactersGroups(DSLContent["BindList"].TabSpaces, "Spaces", "Win Alt Space", False)
  InsertCharactersGroups(DSLContent["BindList"].TabSpaces, "Special Characters", "Win Alt F6")

  SpacesLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLCols.default)
  SpacesLV.ModifyCol(1, ColumnWidths[1])
  SpacesLV.ModifyCol(2, ColumnWidths[2])
  SpacesLV.ModifyCol(3, ColumnWidths[3])
  SpacesLV.ModifyCol(4, ColumnWidths[4])

  for item in DSLContent["BindList"].TabSpaces
  {
    SpacesLV.Add(, item[1], item[2], item[3], item[4])
  }

  GrouBoxSpaces := {
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.body, CommonInfoBox.bodyText),
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.previewFrame),
    preview: DSLPadGUI.Add("Edit", "vSpacesSymbol " . commonInfoBox.preview, CommonInfoBox.previewText),
    title: DSLPadGUI.Add("Text", "vSpacesTitle " . commonInfoBox.title, CommonInfoBox.titleText),
    ;
    LaTeXTitleLTX: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleLTX, CommonInfoBox.LaTeXTitleLTXText).SetFont("s10", "Cambria"),
    LaTeXTitleA: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleA, CommonInfoBox.LaTeXTitleAText).SetFont("s9", "Cambria"),
    LaTeXTitleE: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleE, CommonInfoBox.LaTeXTitleEText).SetFont("s10", "Cambria"),
    LaTeXPackage: DSLPadGUI.Add("Text", "vSpacesLaTeXPackage " . CommonInfoBox.LaTeXPackage, CommonInfoBox.LaTeXPackageText).SetFont("s9"),
    LaTeX: DSLPadGUI.Add("Edit", "vSpacesLaTeX " . commonInfoBox.LaTeX, CommonInfoBox.LaTeXText),
    ;
    altTitle: DSLPadGUI.Add("Text", CommonInfoBox.altTitle, CommonInfoBox.altTitleText[LanguageCode]).SetFont("s9"),
    alt: DSLPadGUI.Add("Edit", "vSpacesAlt " . commonInfoBox.alt, CommonInfoBox.altText),
    ;
    unicodeTitle: DSLPadGUI.Add("Text", CommonInfoBox.unicodeTitle, CommonInfoBox.unicodeTitleText[LanguageCode]).SetFont("s9"),
    unicode: DSLPadGUI.Add("Edit", "vSpacesUnicode " . commonInfoBox.unicode, CommonInfoBox.unicodeText),
    ;
    htmlTitle: DSLPadGUI.Add("Text", CommonInfoBox.htmlTitle, CommonInfoBox.htmlTitleText[LanguageCode]).SetFont("s9"),
    html: DSLPadGUI.Add("Edit", "vSpacesHTML " . commonInfoBox.html, CommonInfoBox.htmlText),
  }

  GrouBoxSpaces.preview.SetFont(CommonInfoFonts.previewSize, CommonInfoFonts.preview)
  GrouBoxSpaces.title.SetFont(CommonInfoFonts.titleSize, CommonInfoFonts.preview)
  GrouBoxSpaces.LaTeX.SetFont("s12")
  GrouBoxSpaces.alt.SetFont("s12")
  GrouBoxSpaces.unicode.SetFont("s12")
  GrouBoxSpaces.html.SetFont("s12")

  Tab.UseTab(4)
  DSLContent["ru"].EntrydblClick := "2×ЛКМ"
  DSLContent["en"].EntrydblClick := "2×LMB"
  DSLContent["ru"].CommandsNote := "Unicode/Alt-code поддерживает ввод множества кодов через пробел, например «44F2 5607 9503» → «䓲嘇锃».`nРежим ввода HTML-кодов не влияет на «Быстрые ключи».`n«Плавильня» может создавать не только лигатуры, например «-+» → «±», «-*» → «×», «***» → «⁂»."
  DSLContent["en"].CommandsNote := "Unicode/Alt-code supports input of multiple codes separated by spaces, for example “44F2 5607 9503” → “䓲嘇锃.”`nHTML entities mode does not affect “Fast keys.”`n“Smelter” can to smelt no only ligatures, for example “-+” → “±”, “-*” → “×”, “***” → “⁂”."

  DSLContent["BindList"].Commands := [
    [Map("ru", "Перейти на страницу символа", "en", "Go to symbol page"), DSLContent[LanguageCode].EntrydblClick, ""],
    [Map("ru", "Копировать символ из списка", "en", "Copy from list"), "Ctrl " . DSLContent[LanguageCode].EntrydblClick, ""],
    [Map("ru", "Поиск по названию", "en", "Find by name"), "Win Alt F", ""],
    [Map("ru", "Открыть страницу выделенного символа", "en", "Open selected symbol Web"), "Win Alt PgUp", "風 → symbl.cc/" . LanguageCode . "/98A8"],
    [Map("ru", "Вставить по Unicode", "en", "Unicode insertion"), "Win Alt U", "8F2A → 輪"],
    [Map("ru", "Вставить по Альт-коду", "en", "Alt-code insertion"), "Win Alt A", "0171 0187 → «»"],
    [Map("ru", "Выплавка символа", "en", "Symbol Smelter"), "Win Alt L", "AE → Æ, OE → Œ"],
    [Map("ru", "Выплавка символа в тексте", "en", "Melt symbol in text"), "", ""],
    [Map("ru", " (выделить)", "en", " (select)"), "RShift L", "ІУЖ → Ѭ, ІЭ → Ѥ"],
    [Map("ru", " (установить курсор справа от символов)", "en", " (set cursor to the right of the symbols)"), "RShift Backspace", "st → ﬆ, іат → ѩ"],
    [Map("ru", "Конвертировать в верхний индекс", "en", "Convert into superscript"), "Win LAlt 1", "‌¹‌²‌³‌⁴‌⁵‌⁶‌⁷‌⁸‌⁹‌⁰‌⁽‌⁻‌⁼‌⁾"],
    [Map("ru", "Конвертировать в нижний индекс", "en", "Convert into subscript"), "Win RAlt 1", "‌₁‌₂‌₃‌₄‌₅‌₆‌₇‌₈‌₉‌₀‌₍‌₋‌₌‌₎"],
    [Map("ru", "Конвертировать в Римские цифры", "en", "Convert into Roman Numerals"), "Win RAlt 2", "15128 → ↂↁⅭⅩⅩⅧ"],
    [Map("ru", "Активация «Быстрых ключей»", "en", "Toggle FastKeys"), "RAlt Home", ""],
    [Map("ru", "Переключение ввода HTML/LaTeX/Символ", "en", "Toggle of HTML/LaTeX/Symbol input"), "RAlt RShift Home", "a&#769; | \'{a} | á"],
    [Map("ru", "Оповещения активации групп", "en", "Groups activation notification toggle"), "Win Alt M", ""],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].Commands)

  CommandsLV := DSLPadGUI.Add("ListView", ColumnAreaWidth . " h450 " . ColumnAreaRules, TrimArray(DSLCols.default, 3))


  CommandsLV.ModifyCol(1, ThreeColumnWidths[1])
  CommandsLV.ModifyCol(2, ThreeColumnWidths[2])
  CommandsLV.ModifyCol(3, ThreeColumnWidths[3])

  for item in DSLContent["BindList"].Commands
  {
    CommandsLV.Add(, item[1], item[2], item[3])
  }


  DSLContent["ru"].AutoLoadAdd := "Добавить в автозагрузку"
  DSLContent["en"].AutoLoadAdd := "Add to Autoload"
  DSLContent["ru"].GetUpdate := "Обновить"
  DSLContent["en"].GetUpdate := "Get Update"
  DSLContent["ru"].UpdateAvailable := "Доступно обновление: версия " . UpdateVersionString
  DSLContent["en"].UpdateAvailable := "Update available: version " . UpdateVersionString

  DSLPadGUI.SetFont("s9")
  ;DSLPadGUI.Add("Text", "w600", DSLContent[LanguageCode].CommandsNote)

  BtnAutoLoad := DSLPadGUI.Add("Button", "x379 y519 w200 h32", DSLContent[LanguageCode].AutoLoadAdd)
  BtnAutoLoad.OnEvent("Click", AddScriptToAutoload)

  BtnSwitchRU := DSLPadGUI.Add("Button", "x21 y519 w32 h32", "РУ")
  BtnSwitchRU.OnEvent("Click", (*) => SwitchLanguage("ru"))

  BtnSwitchEN := DSLPadGUI.Add("Button", "x53 y519 w32 h32", "EN")
  BtnSwitchEN.OnEvent("Click", (*) => SwitchLanguage("en"))

  UpdateBtn := DSLPadGUI.Add("Button", "x611 y487 w32 h32")
  UpdateBtn.OnEvent("Click", (*) => GetUpdate())
  GuiButtonIcon(UpdateBtn, Shell32, 047, "w24 h24 l3")

  RepairBtn := DSLPadGUI.Add("Button", "x579 y487 w32 h32", "🛠️")
  RepairBtn.SetFont("s16")
  RepairBtn.OnEvent("Click", (*) => GetUpdate(0, True))

  ConfigFileBtn := DSLPadGUI.Add("Button", "x611 y519 w32 h32")
  ConfigFileBtn.OnEvent("Click", (*) => OpenConfigFile())
  GuiButtonIcon(ConfigFileBtn, ImageRes, 065)

  LocalesFileBtn := DSLPadGUI.Add("Button", "x579 y519 w32 h32")
  LocalesFileBtn.OnEvent("Click", (*) => OpenLocalesFile())
  GuiButtonIcon(LocalesFileBtn, ImageRes, 015)


  UpdateNewIcon := DSLPadGUI.Add("Text", "vNewVersionIcon x22 y484 w40 h40 BackgroundTrans", "")
  UpdateNewIcon.SetFont("s16")
  UpdateNewVersion := DSLPadGUI.Add("Link", "vNewVersionAlert x38 y492 w300", "")
  UpdateNewVersion.SetFont("s9")

  if UpdateAvailable
  {
    DSLPadGUI["NewVersionAlert"].Text :=
      DSLContent[LanguageCode].UpdateAvailable . ' (<a href="' . RepoSource . '">GitHub</a>)'
    DSLPadGUI["NewVersionIcon"].Text := InformationSymbol
  }

  DSLPadGUI.SetFont("s11")

  CommandsInfoBox := {
    bodyText: Map("ru", "Команда", "en", "Command"),
  }

  GrouBoxCommands := {
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.body, CommandsInfoBox.bodyText[LanguageCode]),
  }


  Tab.UseTab(5)
  DSLContent["BindList"].LigaturesInput := [
    [Map("ru", "Латинская заглавная буква AA", "en", "Latin Capital Letter Aa"), "AA", "Ꜳ", UniTrim(CharCodes.smelter.latin_Capital_AA[1])],
    [Map("ru", "Латинская строчная буква aa", "en", "Latin Small Letter Aa"), "aa", "ꜳ", UniTrim(CharCodes.smelter.latin_Small_AA[1])],
    [Map("ru", "Латинская заглавная буква AE", "en", "Latin Capital Letter Ae"), "AE", "Æ", UniTrim(CharCodes.smelter.latin_Capital_AE[1])],
    [Map("ru", "Латинская строчная буква ae", "en", "Latin Small Letter Ae"), "ae", "æ", UniTrim(CharCodes.smelter.latin_Small_AE[1])],
    [Map("ru", "Латинская заглавная буква AU", "en", "Latin Capital Letter Au"), "AU", "Ꜷ", UniTrim(CharCodes.smelter.latin_Capital_AU[1])],
    [Map("ru", "Латинская строчная буква au", "en", "Latin Small Letter Au"), "au", "ꜷ", UniTrim(CharCodes.smelter.latin_Small_AU[1])],
    [Map("ru", "Латинская заглавная буква OE", "en", "Latin Capital Letter Oe"), "OE", "Œ", UniTrim(CharCodes.smelter.latin_Capital_OE[1])],
    [Map("ru", "Латинская строчная буква oe", "en", "Latin Small Letter Oe"), "oe", "œ", UniTrim(CharCodes.smelter.latin_Small_OE[1])],
    [Map("ru", "Латинская строчная буква ff", "en", "Latin Small Letter Ff"), "ff", "ﬀ", UniTrim(CharCodes.smelter.ff[1])],
    [Map("ru", "Латинская строчная буква fl", "en", "Latin Small Letter Fl"), "fl", "ﬂ", UniTrim(CharCodes.smelter.fl[1])],
    [Map("ru", "Латинская строчная буква fi", "en", "Latin Small Letter Fi"), "fi", "ﬁ", UniTrim(CharCodes.smelter.fi[1])],
    [Map("ru", "Латинская строчная буква ft", "en", "Latin Small Letter Ft"), "ft", "ﬅ", UniTrim(CharCodes.smelter.ft[1])],
    [Map("ru", "Латинская строчная буква ffi", "en", "Latin Small Letter Ffi"), "ffi", "ﬃ", UniTrim(CharCodes.smelter.ffi[1])],
    [Map("ru", "Латинская строчная буква ffl", "en", "Latin Small Letter Ffl"), "ffl", "ﬄ", UniTrim(CharCodes.smelter.ffl[1])],
    [Map("ru", "Латинская строчная буква st", "en", "Latin Small Letter St"), "st", "ﬆ", UniTrim(CharCodes.smelter.st[1])],
    [Map("ru", "Латинская строчная буква ts", "en", "Latin Small Letter Ts"), "ts", "ʦ", UniTrim(CharCodes.smelter.ts[1])],
    [Map("ru", "Латинская заглавная буква IJ", "en", "Latin Capital Letter Ij"), "IJ", "Ĳ", UniTrim(CharCodes.smelter.latin_Capital_ij[1])],
    [Map("ru", "Латинская строчная буква ij", "en", "Latin Small Letter Ij"), "ij", "ĳ", UniTrim(CharCodes.smelter.latin_Small_ij[1])],
    [Map("ru", "Латинская заглавная буква LJ", "en", "Latin Capital Letter LJ"), "LJ", "Ǉ", UniTrim(CharCodes.smelter.latin_Capital_LJ[1])],
    [Map("ru", "Латинская заглавная буква L со строчной буквой j", "en", "Latin Capital Letter L with Small Letter J"), "Lj", "ǈ", UniTrim(CharCodes.smelter.latin_Capital_L_Small_j[1])],
    [Map("ru", "Латинская заглавная буква lj", "en", "Latin Capital Letter Lj"), "lj", "ǉ", UniTrim(CharCodes.smelter.latin_Small_LJ[1])],
    [Map("ru", "Латинская заглавная буква эсцет (S острое)", "en", "Latin Capital Letter Sharp S"), "FS", "ẞ", UniTrim(CharCodes.smelter.latin_Capital_Fs[1])],
    [Map("ru", "Латинская строчная буква эсцет (S острое)", "en", "Latin Small Letter Sharp S"), "fs", "ß", UniTrim(CharCodes.smelter.latin_Small_Fs[1])],
    [Map("ru", "Латинская строчная буква ue", "en", "Latin Small Letter Ue"), "ue", "ᵫ", UniTrim(CharCodes.smelter.latin_Small_UE[1])],
    [Map("ru", "Латинская заглавная буква OO", "en", "Latin Capital Letter Oo"), "OO", "Ꝏ", UniTrim(CharCodes.smelter.latin_Capital_OO[1])],
    [Map("ru", "Латинская строчная буква oo", "en", "Latin Small Letter Oo"), "oo", "ꝏ", UniTrim(CharCodes.smelter.latin_Small_OO[1])],
    [Map("ru", "Латинская строчная буква e йотированное", "en", "Latin Small Letter Iotified E"), "ie", "ꭡ", UniTrim(CharCodes.smelter.latin_Small_ie[1])],
    ["", "", "", ""],
    [Map("ru", "Кириллическая заглавная буква якорное Е", "en", "Cyrillic Capital Letter Ukrainian Ie"), "Э", "Є", UniTrim(CharCodes.smelter.cyrillic_Capital_Ukraine_E[1])],
    [Map("ru", "Кириллическая строчная буква якорное е", "en", "Cyrillic Small Letter Ukrainian Ie"), "э", "є", UniTrim(CharCodes.smelter.cyrillic_Small_Ukraine_E[1])],
    [Map("ru", "Кириллическая заглавная буква Ять", "en", "Cyrillic Capital Letter Yat"), "ТЬ", "Ѣ", UniTrim(CharCodes.smelter.cyrillic_Captial_Yat[1])],
    [Map("ru", "Кириллическая строчная буква ять", "en", "Cyrillic Small Letter Yat"), "ть", "ѣ", UniTrim(CharCodes.smelter.cyrillic_Small_Yar[1])],
    [Map("ru", "Кириллическая заглавная буква большой Юс", "en", "Cyrillic Capital Letter Big Yus"), "УЖ", "Ѫ", UniTrim(CharCodes.smelter.cyrillic_Capital_Big_Yus[1])],
    [Map("ru", "Кириллическая строчная буква большой юс", "en", "Cyrillic Small Letter Big Yus"), "уж", "ѫ", UniTrim(CharCodes.smelter.cyrillic_Small_Big_Yus[1])],
    [Map("ru", "Кириллическая заглавная буква малый Юс", "en", "Cyrillic Capital Letter Little Yus"), "АТ", "Ѧ", UniTrim(CharCodes.smelter.cyrillic_Capital_Little_Yus[1])],
    [Map("ru", "Кириллическая строчная буква малый юс", "en", "Cyrillic Small Letter Little Yus"), "ат", "ѧ", UniTrim(CharCodes.smelter.cyrillic_Small_Little_Yus[1])],
    [Map("ru", "Кириллическая заглавная буква Е йотированное", "en", "Cyrillic Capital Letter Iotified E"), "ІЄ, ІЭ", "Ѥ", UniTrim(CharCodes.smelter.cyrillic_Capital_ie[1])],
    [Map("ru", "Кириллическая строчная буква е йотированное", "en", "Cyrillic Small Letter Iotified E"), "іє, іэ", "ѥ", UniTrim(CharCodes.smelter.cyrillic_Small_ie[1])],
    [Map("ru", "Кириллическая заглавная буква Ять йотированный", "en", "Cyrillic Capital Letter Iotified Yat"), "Іѣ, ІТЬ", "Ꙓ", UniTrim(CharCodes.smelter.cyrillic_Captial_Yat_Iotified[1])],
    [Map("ru", "Кириллическая строчная буква ять йотированный", "en", "Cyrillic Small Letter Iotified Yat"), "іѣ, іть", "ꙓ", UniTrim(CharCodes.smelter.cyrillic_Small_Yat_Iotified[1])],
    [Map("ru", "Кириллическая заглавная буква А йотированное", "en", "Cyrillic Capital Letter Iotified A"), "ІА", "Ꙗ", UniTrim(CharCodes.smelter.cyrillic_Captial_A_Iotified[1])],
    [Map("ru", "Кириллическая строчная буква а йотированное", "en", "Cyrillic Small Letter Iotified A"), "іа", "ꙗ", UniTrim(CharCodes.smelter.cyrillic_Small_A_Iotified[1])],
    [Map("ru", "Кириллическая заглавная буква йотированный большой Юс", "en", "Cyrillic Capital Letter Iotified Big Yus"), "ІѪ, ІУЖ", "Ѭ", UniTrim(CharCodes.smelter.cyrillic_Captial_Big_Yus_Iotified[1])],
    [Map("ru", "Кириллическая строчная буква йотированный большой юс", "en", "Cyrillic Small Letter Iotified Big Yus"), "іѫ, іуж", "ѭ", UniTrim(CharCodes.smelter.cyrillic_Small_Big_Yus_Iotified[1])],
    [Map("ru", "Кириллическая заглавная буква йотированный малый Юс", "en", "Cyrillic Capital Letter Iotified Little Yus"), "ІѦ, ІАТ", "Ѩ", UniTrim(CharCodes.smelter.cyrillic_Captial_Little_Yus_Iotified[1])],
    [Map("ru", "Кириллическая строчная буква йотированный малый юс", "en", "Cyrillic Small Letter Iotified Little Yus"), "іѧ, іат", "ѩ", UniTrim(CharCodes.smelter.cyrillic_Small_Little_Yus_Iotified[1])],
    ["", "", "", ""],
    [Map("ru", "Плюс-минус", "en", "Plus minus"), "-+", "±", UniTrim(CharCodes.plusminus[1])],
    [Map("ru", "Умножение", "en", "Multiplication"), "-*", "×", UniTrim(CharCodes.multiplication[1])],
    [Map("ru", "Нижний астериск", "en", "Low Asterisk"), "*", "⁎", UniTrim(CharCodes.lowasterisk[1])],
    [Map("ru", "Два астериска", "en", "Two Asterisks"), "**", "⁑", UniTrim(CharCodes.twoasterisks[1])],
    [Map("ru", "Астеризм", "en", "Asterism"), "***", "⁂", UniTrim(CharCodes.asterism[1])],
    [Map("ru", "Двухточечный пунктир", "en", "Two Dot Leader"), "..", "‥", UniTrim(CharCodes.twodotleader[1])],
    [Map("ru", "Многоточие", "en", "Horizontal Ellipsis"), "...", "…", UniTrim(CharCodes.ellipsis[1])],
    [Map("ru", "Мягкий перенос", "en", "Soft Hyphen"), "-", "", UniTrim(CharCodes.softhyphen[1])],
    [Map("ru", "Дефис", "en", "Hyphen"), ".-", "‐", UniTrim(CharCodes.dash[1])],
    [Map("ru", "Цифровое тире", "en", "Figure Dash"), "n-", "‒", UniTrim(CharCodes.numdash[1])],
    [Map("ru", "Короткое тире", "en", "En Dash"), "--", "–", UniTrim(CharCodes.endash[1])],
    [Map("ru", "Длинное тире", "en", "Em Dash"), "---", "—", UniTrim(CharCodes.emdash[1])],
    [Map("ru", "Двойное тире", "en", "Two-Em Dash"), "----, 2-", "⸺", UniTrim(CharCodes.twoemdash[1])],
    [Map("ru", "Тройное тире", "en", "Three-Em Dash"), "-----, 3-", "⸻", UniTrim(CharCodes.threemdash[1])],
    [Map("ru", "Неразрывный дефис", "en", "Non-Breaking Hyphen"), "0-", "‑", UniTrim(CharCodes.nbdash[1])],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].LigaturesInput)

  LigaturesLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLCols.smelting)
  LigaturesLV.ModifyCol(1, ColumnWidths[1])
  LigaturesLV.ModifyCol(2, 110)
  LigaturesLV.ModifyCol(3, 100)
  LigaturesLV.ModifyCol(4, ColumnWidths[4])

  for item in DSLContent["BindList"].LigaturesInput
  {
    LigaturesLV.Add(, item[1], item[2], item[3], item[4])
  }

  GrouBoxLigatures := {
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.body, CommonInfoBox.bodyText),
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.previewFrame),
    preview: DSLPadGUI.Add("Edit", "vLigaturesSymbol " . commonInfoBox.preview, CommonInfoBox.previewText),
    title: DSLPadGUI.Add("Text", "vLigaturesTitle " . commonInfoBox.title, CommonInfoBox.titleText),
    ;
    LaTeXTitleLTX: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleLTX, CommonInfoBox.LaTeXTitleLTXText).SetFont("s10", "Cambria"),
    LaTeXTitleA: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleA, CommonInfoBox.LaTeXTitleAText).SetFont("s9", "Cambria"),
    LaTeXTitleE: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleE, CommonInfoBox.LaTeXTitleEText).SetFont("s10", "Cambria"),
    LaTeXPackage: DSLPadGUI.Add("Text", "vLigaturesLaTeXPackage " . CommonInfoBox.LaTeXPackage, CommonInfoBox.LaTeXPackageText).SetFont("s9"),
    LaTeX: DSLPadGUI.Add("Edit", "vLigaturesLaTeX " . commonInfoBox.LaTeX, CommonInfoBox.LaTeXText),
    ;
    altTitle: DSLPadGUI.Add("Text", CommonInfoBox.altTitle, CommonInfoBox.altTitleText[LanguageCode]).SetFont("s9"),
    alt: DSLPadGUI.Add("Edit", "vLigaturesAlt " . commonInfoBox.alt, CommonInfoBox.altText),
    ;
    unicodeTitle: DSLPadGUI.Add("Text", CommonInfoBox.unicodeTitle, CommonInfoBox.unicodeTitleText[LanguageCode]).SetFont("s9"),
    unicode: DSLPadGUI.Add("Edit", "vLigaturesUnicode " . commonInfoBox.unicode, CommonInfoBox.unicodeText),
    ;
    htmlTitle: DSLPadGUI.Add("Text", CommonInfoBox.htmlTitle, CommonInfoBox.htmlTitleText[LanguageCode]).SetFont("s9"),
    html: DSLPadGUI.Add("Edit", "vLigaturesHTML " . commonInfoBox.html, CommonInfoBox.htmlText),
  }

  GrouBoxLigatures.preview.SetFont(CommonInfoFonts.previewSize, CommonInfoFonts.preview)
  GrouBoxLigatures.title.SetFont(CommonInfoFonts.titleSize, CommonInfoFonts.preview)
  GrouBoxLigatures.LaTeX.SetFont("s12")
  GrouBoxLigatures.alt.SetFont("s12")
  GrouBoxLigatures.unicode.SetFont("s12")
  GrouBoxLigatures.html.SetFont("s12")


  Tab.UseTab(6)
  DSLContent["BindList"].FastKeysLV := [
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
    [Map("ru", "Узкий пробел", "en", "Thin Space"), "[5]", "[ ]", UniTrim(CharCodes.thinsp[1])],
    [Map("ru", "⅙ Круглой шпации", "en", "⅙ Em Space"), "[6]", "[ ]", UniTrim(CharCodes.emsp16[1])],
    [Map("ru", "Узкий неразрывный пробел", "en", "Narrow No-Break Space"), "[7]", "[ ]", UniTrim(CharCodes.nnbsp[1])],
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
    [Map("ru", "Дробная черта ✅", "en", "Fraction Slash ✅"), "LCtrl LAlt [Num/]", "⁄", UniTrim(CharCodes.fractionslash[1])],
    [Map("ru", "Даггер ✅", "en", "Dagger ✅"), "RAlt [Num/]", "†", UniTrim(CharCodes.dagger[1])],
    [Map("ru", "Двойной даггер ✅", "en", "Double Dagger ✅"), "RAlt RShift [Num/]", "‡", UniTrim(CharCodes.ddagger[1])],
    [Map("ru", "Соединитель графем ✅", "en", "Grapheme Joiner ✅"), "LShift RShift [g]", "◌͏", UniTrim(CharCodes.grapjoiner[1])],
  ]

  LocaliseArrayKeys(DSLContent["BindList"].FastKeysLV)

  FastKeysLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLCols.default)
  FastKeysLV.ModifyCol(1, ColumnWidths[1])
  FastKeysLV.ModifyCol(2, ColumnWidths[2])
  FastKeysLV.ModifyCol(3, ColumnWidths[3])
  FastKeysLV.ModifyCol(4, ColumnWidths[4])

  for item in DSLContent["BindList"].FastKeysLV
  {
    FastKeysLV.Add(, item[1], item[2], item[3], item[4])
  }

  GrouBoxFastKeys := {
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.body, CommonInfoBox.bodyText),
    group: DSLPadGUI.Add("GroupBox", CommonInfoBox.previewFrame),
    preview: DSLPadGUI.Add("Edit", "vFastKeysSymbol " . commonInfoBox.preview, CommonInfoBox.previewText),
    title: DSLPadGUI.Add("Text", "vFastKeysTitle " . commonInfoBox.title, CommonInfoBox.titleText),
    ;
    LaTeXTitleLTX: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleLTX, CommonInfoBox.LaTeXTitleLTXText).SetFont("s10", "Cambria"),
    LaTeXTitleA: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleA, CommonInfoBox.LaTeXTitleAText).SetFont("s9", "Cambria"),
    LaTeXTitleE: DSLPadGUI.Add("Text", CommonInfoBox.LaTeXTitleE, CommonInfoBox.LaTeXTitleEText).SetFont("s10", "Cambria"),
    LaTeXPackage: DSLPadGUI.Add("Text", "vFastKeysLaTeXPackage " . CommonInfoBox.LaTeXPackage, CommonInfoBox.LaTeXPackageText).SetFont("s9"),
    LaTeX: DSLPadGUI.Add("Edit", "vFastKeysLaTeX " . commonInfoBox.LaTeX, CommonInfoBox.LaTeXText),
    ;
    altTitle: DSLPadGUI.Add("Text", CommonInfoBox.altTitle, CommonInfoBox.altTitleText[LanguageCode]).SetFont("s9"),
    alt: DSLPadGUI.Add("Edit", "vFastKeysAlt " . commonInfoBox.alt, CommonInfoBox.altText),
    ;
    unicodeTitle: DSLPadGUI.Add("Text", CommonInfoBox.unicodeTitle, CommonInfoBox.unicodeTitleText[LanguageCode]).SetFont("s9"),
    unicode: DSLPadGUI.Add("Edit", "vFastKeysUnicode " . commonInfoBox.unicode, CommonInfoBox.unicodeText),
    ;
    htmlTitle: DSLPadGUI.Add("Text", CommonInfoBox.htmlTitle, CommonInfoBox.htmlTitleText[LanguageCode]).SetFont("s9"),
    html: DSLPadGUI.Add("Edit", "vFastKeysHTML " . commonInfoBox.html, CommonInfoBox.htmlText),
  }

  GrouBoxFastKeys.preview.SetFont(CommonInfoFonts.previewSize, CommonInfoFonts.preview)
  GrouBoxFastKeys.title.SetFont(CommonInfoFonts.titleSize, CommonInfoFonts.preview)
  GrouBoxFastKeys.LaTeX.SetFont("s12")
  GrouBoxFastKeys.alt.SetFont("s12")
  GrouBoxFastKeys.unicode.SetFont("s12")
  GrouBoxFastKeys.html.SetFont("s12")


  Tab.UseTab(7)
  DSLPadGUI.Add("GroupBox", "x23 y34 w280 h512")
  DSLPadGUI.Add("GroupBox", "x75 y65 w170 h170")
  DSLPadGUI.Add("Picture", "x98 y89 w128 h128", AppIcoFile)

  AboutTitle := DSLPadGUI.Add("Text", "x75 y245 w170 h32 Center BackgroundTrans", DSLPadTitleDefault)
  AboutTitle.SetFont("s20 c333333", "Cambria")

  AboutVersion := DSLPadGUI.Add("Text", "x75 y285 w170 h32 Center BackgroundTrans", CurrentVersionString)
  AboutVersion.SetFont("s12 c333333", "Cambria")

  AboutRepoLinkX := LanguageCode == "ru" ? "x114" : "x123"
  AboutRepoLink := DSLPadGUI.Add("Link", AboutRepoLinkX " y320 w150 h20 Center",
    '<a href="https://github.com/DemerNkardaz/Misc-Scripts/tree/main/AutoHotkey2.0/">' ReadLocale("about_repository") '</a>'
  )
  AboutRepoLink.SetFont("s12", "Cambria")

  AboutAuthor := DSLPadGUI.Add("Text", "x75 y490 w170 h16 Center BackgroundTrans", ReadLocale("about_author"))
  AboutAuthor.SetFont("s11 c333333", "Cambria")

  AboutAuthorLinks := DSLPadGUI.Add("Link", "x90 y520 w150 h16 Center",
    '<a href="https://github.com/DemerNkardaz/">GitHub</a> '
    '<a href="http://steamcommunity.com/profiles/76561198177249942">STEAM</a> '
    '<a href="https://ficbook.net/authors/4241255">Фикбук</a>'
  )
  AboutAuthorLinks.SetFont("s9", "Cambria")

  AboutDescBox := DSLPadGUI.Add("GroupBox", "x315 y34 w530 h512", DSLPadTitleFull)
  AboutDescBox.SetFont("s11", "Cambria")

  AboutDescription := DSLPadGUI.Add("Text", "x330 y70 w505 h485 Wrap BackgroundTrans", ReadLocale("about_description"))
  AboutDescription.SetFont("s12 c333333", "Cambria")


  Tab.UseTab(8)
  DSLContent["ru"].Useful := {}
  DSLContent["ru"].Useful.Typography := "Типографика"
  DSLContent["ru"].Useful.TypographyLayout := '<a href="https://ilyabirman.ru/typography-layout/">«Типографская раскладка»</a>'
  DSLContent["ru"].Useful.Unicode := "Unicode-ресурсы"
  DSLContent["ru"].Useful.Dictionaries := "Словари"
  DSLContent["ru"].Useful.JPnese := "Японский: "
  DSLContent["ru"].Useful.CHnese := "Китайский: "
  DSLContent["ru"].Useful.VTnese := "Вьетнамский: "


  DSLContent["en"].Useful := {}
  DSLContent["en"].Useful.Typography := "Typography"
  DSLContent["en"].Useful.TypographyLayout := '<a href="https://ilyabirman.net/typography-layout/">“Typography Layout”</a>'
  DSLContent["en"].Useful.Unicode := "Unicode-Resources"
  DSLContent["en"].Useful.Dictionaries := "Dictionaries"
  DSLContent["en"].Useful.JPnese := "Japanese: "
  DSLContent["en"].Useful.CHnese := "Chinese: "
  DSLContent["en"].Useful.VTnese := "Vietnamese: "

  DSLPadGUI.SetFont("s13")
  DSLPadGUI.Add("Text", , DSLContent[LanguageCode].Useful.Typography)
  DSLPadGUI.SetFont("s11")
  DSLPadGUI.Add("Link", "w600", DSLContent[LanguageCode].Useful.TypographyLayout)
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

  Tab.UseTab(9)
  DSLPadGUI.Add("GroupBox", "w825 h512", "🌐 " . ReadLocale("tab_changelog"))
  InsertChangesList(DSLPadGUI)


  DiacriticLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  LettersLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  SpacesLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  FastKeysLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  LigaturesLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  CommandsLV.OnEvent("DoubleClick", LV_RunCommand)

  DiacriticLV.OnEvent("ItemFocus", (LV, RowNumber) =>
    LV_CharacterDetails(LV, RowNumber, [DSLPadGUI,
      "DiacriticSymbol",
      "DiacriticTitle",
      "DiacriticLaTeX",
      "DiacriticLaTeXPackage",
      "DiacriticAlt",
      "DiacriticUnicode",
      "DiacriticHTML",
      GrouBoxDiacritic]
    ))
  LettersLV.OnEvent("ItemFocus", (LV, RowNumber) =>
    LV_CharacterDetails(LV, RowNumber, [DSLPadGUI,
      "LettersSymbol",
      "LettersTitle",
      "LettersLaTeX",
      "LettersLaTeXPackage",
      "LettersAlt",
      "LettersUnicode",
      "LettersHTML",
      GrouBoxLetters]
    ))
  SpacesLV.OnEvent("ItemFocus", (LV, RowNumber) =>
    LV_CharacterDetails(LV, RowNumber, [DSLPadGUI,
      "SpacesSymbol",
      "SpacesTitle",
      "SpacesLaTeX",
      "SpacesLaTeXPackage",
      "SpacesAlt",
      "SpacesUnicode",
      "SpacesHTML",
      GrouBoxSpaces]
    ))
  FastKeysLV.OnEvent("ItemFocus", (LV, RowNumber) =>
    LV_CharacterDetails(LV, RowNumber, [DSLPadGUI,
      "FastKeysSymbol",
      "FastKeysTitle",
      "FastKeysLaTeX",
      "FastKeysLaTeXPackage",
      "FastKeysAlt",
      "FastKeysUnicode",
      "FastKeysHTML",
      GrouBoxFastKeys]
    ))
  LigaturesLV.OnEvent("ItemFocus", (LV, RowNumber) =>
    LV_CharacterDetails(LV, RowNumber, [DSLPadGUI,
      "LigaturesSymbol",
      "LigaturesTitle",
      "LigaturesLaTeX",
      "LigaturesLaTeXPackage",
      "LigaturesAlt",
      "LigaturesUnicode",
      "LigaturesHTML",
      GrouBoxLigatures]
    ))


  CharacterPreviewRandomCode := ""

  uniStore := []
  for characterEntry, value in Characters {
    uniStore.Push(value.unicode)
  }
  CharacterPreviewRandomCode := uniStore[Random(uniStore.Length)]

  CharacterPreviewRandomCodes := []

  CharacterPreviewRandomCodes.Push(GetRandomByGroups(["Diacritics Primary", "Diacritics Secondary", "Diacritics Tertiary"]))
  CharacterPreviewRandomCodes.Push("")
  CharacterPreviewRandomCodes.Push(GetRandomByGroups(["Spaces", "Special Characters"]))
  CharacterPreviewRandomCodes.Push("")
  CharacterPreviewRandomCodes.Push(GetRandomByGroups(["Diacritics Primary", "Spaces", "Special Characters"]))


  SetCharacterInfoPanel(CharacterPreviewRandomCodes[1], DSLPadGUI, "DiacriticSymbol", "DiacriticTitle", "DiacriticLaTeX", "DiacriticLaTeXPackage", "DiacriticAlt", "DiacriticUnicode", "DiacriticHTML", GrouBoxDiacritic)
  SetCharacterInfoPanel(CharacterPreviewRandomCode, DSLPadGUI, "LettersSymbol", "LettersTitle", "LettersLaTeX", "LettersLaTeXPackage", "LettersAlt", "LettersUnicode", "LettersHTML", GrouBoxLetters)
  SetCharacterInfoPanel(CharacterPreviewRandomCodes[3], DSLPadGUI, "SpacesSymbol", "SpacesTitle", "SpacesLaTeX", "SpacesLaTeXPackage", "SpacesAlt", "SpacesUnicode", "SpacesHTML", GrouBoxSpaces)
  SetCharacterInfoPanel(CharacterPreviewRandomCodes[5], DSLPadGUI, "FastKeysSymbol", "FastKeysTitle", "FastKeysLaTeX", "FastKeysLaTeXPackage", "FastKeysAlt", "FastKeysUnicode", "FastKeysHTML", GrouBoxFastKeys)
  SetCharacterInfoPanel(CharacterPreviewRandomCode, DSLPadGUI, "LigaturesSymbol", "LigaturesTitle", "LigaturesLaTeX", "LigaturesLaTeXPackage", "LigaturesAlt", "LigaturesUnicode", "LigaturesHTML", GrouBoxLigatures)


  DSLPadGUI.Title := DSLPadTitle

  DSLPadGUI.Show("x" xPos " y" yPos)

  return DSLPadGUI
}

GetRandomByGroups(GroupNames) {
  TemporaryStorage := []
  for characterEntry, value in Characters {
    if (HasProp(value, "group")) {
      for group in GroupNames {
        if (value.group[1] == group) {
          TemporaryStorage.Push(value.unicode)
          break
        }
      }
    }
  }

  if (TemporaryStorage.Length > 0) {
    randomIndex := Random(1, TemporaryStorage.Length)
    return TemporaryStorage[randomIndex]
  }
}


SetCharacterInfoPanel(UnicodeKey, TargetGroup, PreviewObject, PreviewTitle, PreviewLaTeX, PreviewLaTeXPackage, PreviewAlt, PreviewUnicode, PreviewHTML, PreviewGroup) {
  LanguageCode := GetLanguageCode()

  if (UnicodeKey != "") {
    for characterEntry, value in Characters {
      entryName := RegExReplace(characterEntry, "^\S+\s+")
      characterTitle := ""
      if (HasProp(value, "titles") &&
        (!HasProp(value, "titlesAlt") || HasProp(value, "titlesAlt") && value.titlesAlt == True)) {
        characterTitle := value.titles[LanguageCode]
      } else if (HasProp(value, "titlesAlt") && value.titlesAlt == True) {
        characterTitle := ReadLocale(entryName . "_alt", "chars")
      } else {
        characterTitle := ReadLocale(entryName, "chars")
      }

      if (
        (UnicodeKey == UniTrim(value.unicode)) ||
        (UnicodeKey == value.unicode)) {
        if (HasProp(value, "symbol")) {
          if (HasProp(value, "symbolAlt")) {
            TargetGroup[PreviewObject].Text := value.symbolAlt
          } else if (StrLen(value.symbol) > 3) {
            TargetGroup[PreviewObject].Text := SubStr(value.symbol, 1, 1)
          } else {
            TargetGroup[PreviewObject].Text := value.symbol
          }
        }


        if HasProp(value, "symbolCustom") {
          PreviewGroup.preview.SetFont(
            CommonInfoFonts.previewSize . " norm cDefault"
          )
          TargetGroup[PreviewObject].SetFont(
            CommonInfoFonts.previewSize . " " . value.symbolCustom
          )
        } else if (StrLen(TargetGroup[PreviewObject].Text) > 2) {
          PreviewGroup.preview.SetFont(
            CommonInfoFonts.previewSmaller . " norm cDefault"
          )
        } else {
          PreviewGroup.preview.SetFont(
            CommonInfoFonts.previewSize . " norm cDefault"
          )
        }

        TargetGroup[PreviewTitle].Text := characterTitle

        TargetGroup[PreviewUnicode].Text := SubStr(value.unicode, 2, StrLen(value.unicode) - 2)

        if (HasProp(value, "entity")) {
          TargetGroup[PreviewHTML].Text := value.html . " " . value.entity
        } else {
          TargetGroup[PreviewHTML].Text := value.html
        }

        if (StrLen(TargetGroup[PreviewHTML].Text) > 9
          && StrLen(TargetGroup[PreviewHTML].Text) < 15) {
          PreviewGroup.html.SetFont("s10")
        } else if (StrLen(TargetGroup[PreviewHTML].Text) > 14) {
          PreviewGroup.html.SetFont("s9")
        } else {
          PreviewGroup.html.SetFont("s12")
        }

        if (HasProp(value, "altcode")) {
          TargetGroup[PreviewAlt].Text := value.altcode
        } else {
          TargetGroup[PreviewAlt].Text := "N/A"
        }

        if (HasProp(value, "LaTeXPackage")) {
          TargetGroup[PreviewLaTeXPackage].Text := "📦 " . value.LaTeXPackage
        } else {
          TargetGroup[PreviewLaTeXPackage].Text := ""
        }

        if (HasProp(value, "LaTeX")) {
          if IsObject(value.LaTeX) {
            LaTeXString := ""
            totalCount := 0
            for index in value.LaTeX {
              totalCount++
            }
            currentIndex := 0
            for index, latex in value.LaTeX {
              LaTeXString .= latex
              currentIndex++
              if (currentIndex < totalCount) {
                LaTeXString .= " "
              }
            }
            TargetGroup[PreviewLaTeX].Text := LaTeXString

          } else {
            TargetGroup[PreviewLaTeX].Text := value.LaTeX
          }

        } else {
          TargetGroup[PreviewLaTeX].Text := "N/A"
        }

        if (StrLen(TargetGroup[PreviewLaTeX].Text) > 9
          && StrLen(TargetGroup[PreviewLaTeX].Text) < 15) {
          PreviewGroup.latex.SetFont("s10")
        } else if (StrLen(TargetGroup[PreviewLaTeX].Text) > 14) {
          PreviewGroup.latex.SetFont("s9")
        } else {
          PreviewGroup.latex.SetFont("s12")
        }
      }
    }
  }
}

LV_CharacterDetails(LV, RowNumber, SetupArray) {
  UnicodeKey := LV.GetText(RowNumber, 4)
  SetCharacterInfoPanel(UnicodeKey,
    SetupArray[1], SetupArray[2], SetupArray[3],
    SetupArray[4], SetupArray[5], SetupArray[6],
    SetupArray[7], SetupArray[8], SetupArray[9])
}


LV_OpenUnicodeWebsite(LV, RowNumber)
{
  LanguageCode := GetLanguageCode()
  SelectedRow := LV.GetText(RowNumber, 4)
  URIComponent := "https://symbl.cc/" . LanguageCode . "/" . SelectedRow
  if (SelectedRow != "") {
    IsCtrlDown := GetKeyState("LControl")
    if (IsCtrlDown) {
      if (InputMode = "HTML" || InputMode = "LaTeX") {
        for characterEntry, value in Characters {
          if (SelectedRow = UniTrim(value.unicode)) {
            if InputMode = "HTML" {
              A_Clipboard := HasProp(value, "entity") ? value.entity : value.html
            } else if InputMode = "LaTeX" && HasProp(value, "LaTeX") {
              if IsObject(value.LaTeX) {
                if LaTeXMode = "common"
                  A_Clipboard := value.LaTeX[1]
                else if LaTeXMode = "math"
                  A_Clipboard := value.LaTeX[2]
              } else {
                A_Clipboard := value.LaTeX
              }
            }
          }
        }
      } else {
        UnicodeCodePoint := "0x" . SelectedRow
        A_Clipboard := Chr(UnicodeCodePoint)
      }


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

  if (Shortcut = "Win Alt M")
    ToggleGroupMessage()

  if (Shortcut = "Win LAlt 1")
    SwitchToScript("sup")

  if (Shortcut = "Win RAlt 1")
    SwitchToScript("sub")

  if (Shortcut = "Win RAlt 2")
    SwitchToRoman()

  if (Shortcut = "RAlt Home")
    ToggleFastKeys()

  if (Shortcut = "RAlt RShift Home")
    ToggleInputMode()
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
  global DSLPadTitleDefault, AppIcoFile
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

  Command := "powershell -command " "$shell = New-Object -ComObject WScript.Shell; $shortcut = $shell.CreateShortcut('" ShortcutPath "'); $shortcut.TargetPath = '" CurrentScriptPath "'; $shortcut.WorkingDirectory = '" A_ScriptDir "'; $shortcut.IconLocation = '" AppIcoFile "'; $shortcut.Description = 'DSLKeyPad AutoHotkey Script'; $shortcut.Save()" ""
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

<^>!>+Home:: ToggleInputMode()

ToggleInputMode()
{
  LanguageCode := GetLanguageCode()

  ActivationMessage := {}
  ActivationMessage[] := Map()
  ActivationMessage["ru"] := {}
  ActivationMessage["en"] := {}

  InputModeLabel := Map(
    "Default", Map("ru", "символов юникода", "en", "unicode symbols"),
    "HTML", Map("ru", "HTML-кодов", "en", "HTML codes"),
    "LaTeX", Map("ru", "LaTeX-кодов", "en", "LaTeX codes")
  )

  global InputMode, ConfigFile

  if (InputMode = "Default") {
    InputMode := "HTML"
  } else if (InputMode = "HTML") {
    InputMode := "LaTeX"
  } else if (InputMode = "LaTeX") {
    InputMode := "Default"
  }

  IniWrite InputMode, ConfigFile, "Settings", "InputMode"


  ActivationMessage["ru"].Active := "Ввод " . InputModeLabel[InputMode][LanguageCode] . " активирован"
  ActivationMessage["en"].Active := "Input " . InputModeLabel[InputMode][LanguageCode] . " activated"

  MsgBox(ActivationMessage[LanguageCode].Active, DSLPadTitle, 0x40)

  return
}


HandleFastKey(Character, CheckOff := False)
{
  global FastKeysIsActive
  if (FastKeysIsActive || CheckOff == True) {
    characterEntity := (HasProp(Character, "entity")) ? Character.entity : Character.html
    characterLaTeX := (HasProp(Character, "LaTeX")) ? Character.LaTeX : ""

    if InputMode = "HTML" {
      SendText(characterEntity)
    } else if InputMode = "LaTeX" && HasProp(Character, "LaTeX") {
      if IsObject(characterLaTeX) {
        if LaTeXMode = "common"
          SendText(characterLaTeX[1])
        else if LaTeXMode = "math"
          SendText(characterLaTeX[2])
      } else {
        SendText(characterLaTeX)
      }
    }
    else
      Send(Character.unicode)
  }
}

<^<!a:: HandleFastKey(Characters["0000 acute"])
<^<+<!a:: HandleFastKey(Characters["0001 acute_double"])
<^<!b:: HandleFastKey(Characters["0006 breve"])
<^<+<!b:: HandleFastKey(Characters["0007 breve_inverted"])
;<^<!c:: HandleFastKey(CharCodes.circumflex[1])
;<^<+<!c:: HandleFastKey(CharCodes.caron[1])
;<^<!d:: HandleFastKey(CharCodes.dotabove[1])
;<^<+<!d:: HandleFastKey(CharCodes.diaeresis[1])
;<^<!g:: HandleFastKey(CharCodes.grave[1])
;<^<+<!g:: HandleFastKey(CharCodes.dgrave[1])
;<^<!m:: HandleFastKey(CharCodes.macron[1])
;<^<+<!m:: HandleFastKey(CharCodes.macronbelow[1])


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

;<^<!1:: HandleFastKey("{U+00B9}") ; Superscript 1
;<^<!2:: HandleFastKey("{U+00B2}") ; Superscript 2
;<^<!3:: HandleFastKey("{U+00B3}") ; Superscript 3
;<^<!4:: HandleFastKey("{U+2074}") ; Superscript 4
;<^<!5:: HandleFastKey("{U+2075}") ; Superscript 5
;<^<!6:: HandleFastKey("{U+2076}") ; Superscript 6
;<^<!7:: HandleFastKey("{U+2077}") ; Superscript 7
;<^<!8:: HandleFastKey("{U+2078}") ; Superscript 8
;<^<!9:: HandleFastKey("{U+2079}") ; Superscript 9
;<^<!0:: HandleFastKey("{U+2070}") ; Superscript 0
;<^<+<!1:: HandleFastKey("{U+2081}") ; Subscript 1
;<^<+<!2:: HandleFastKey("{U+2082}") ; Subscript 2
;<^<+<!3:: HandleFastKey("{U+2083}") ; Subscript 3
;<^<+<!4:: HandleFastKey("{U+2084}") ; Subscript 4
;<^<+<!5:: HandleFastKey("{U+2085}") ; Subscript 5
;<^<+<!6:: HandleFastKey("{U+2086}") ; Subscript 6
;<^<+<!7:: HandleFastKey("{U+2087}") ; Subscript 7
;<^<+<!8:: HandleFastKey("{U+2088}") ; Subscript 8
;<^<+<!9:: HandleFastKey("{U+2089}") ; Subscript 9
;<^<+<!0:: HandleFastKey("{U+2080}") ; Subscript 0

;<^>!>+1:: HandleFastKey(CharCodes.emsp[1])
;<^>!>+2:: HandleFastKey(CharCodes.ensp[1])
;<^>!>+3:: HandleFastKey(CharCodes.emsp13[1])
;<^>!>+4:: HandleFastKey(CharCodes.emsp14[1])
;<^>!>+5:: HandleFastKey(CharCodes.thinsp[1])
;<^>!>+6:: HandleFastKey(CharCodes.emsp16[1])
;<^>!>+7:: HandleFastKey(CharCodes.nnbsp[1])
;<^>!>+8:: HandleFastKey(CharCodes.hairsp[1])
;<^>!>+9:: HandleFastKey(CharCodes.puncsp[1])
;<^>!>+0:: HandleFastKey(CharCodes.zwsp[1])
;<^>!>+-:: HandleFastKey(CharCodes.wj[1])
;<^>!>+=:: HandleFastKey(CharCodes.numsp[1])
;<^>!<+Space:: HandleFastKey(CharCodes.nbsp[1])

<^>!m:: Send("{U+2212}") ; Minus


<^<!Numpad0:: HandleFastKey(Characters["0000 dotted_circle"])

<^>!NumpadMult:: Send("{U+2051}") ; Double Asterisk
<^>!>+NumpadMult:: Send("{U+2042}") ; Asterism
<^>!<+NumpadMult:: Send("{U+204E}") ; Asterisk Below
;<^>!NumpadDiv:: HandleFastKey(CharCodes.dagger[1], True)
;<^>!>+NumpadDiv:: HandleFastKey(CharCodes.ddagger[1], True)

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


;>+<+g:: HandleFastKey(CharCodes.grapjoiner[1], True)
;<^<!NumpadDiv:: HandleFastKey(CharCodes.fractionslash[1], True)


ShowInfoMessage(MessagePost, MessageIcon := "Info", MessageTitle := DSLPadTitle, SkipMessage := False) {
  if SkipMessage == True
    return
  LanguageCode := GetLanguageCode()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].RunMessage := MessagePost[1]
  Labels["en"].RunMessage := MessagePost[2]
  Ico := MessageIcon == "Info" ? "Iconi" :
    MessageIcon == "Warning" ? "Icon!" :
      MessageIcon == "Error" ? "Iconx" : 0x0
  TrayTip Labels[LanguageCode].RunMessage, MessageTitle, "Iconi"

}

TraySetIcon(AppIcoFile)
A_IconTip := DSLPadTitle

DSLTray := A_TrayMenu

ReloadApplication(*) {
  Reload
}
ExitApplication(*) {
  ExitApp
}

OpenScriptFolder(*) {
  Run A_ScriptDir
}

ManageTrayItems() {
  LanguageCode := GetLanguageCode()
  Labels := Map()
  Labels["ru"] := {}
  Labels["en"] := {}

  Labels["ru"].Reload := "Перезапустить"
  Labels["ru"].Config := "Файл конфига"
  Labels["ru"].Locale := "Файл локализации"
  Labels["ru"].Exit := "Закрыть"
  Labels["ru"].Panel := "Открыть панель"
  Labels["ru"].Install := "Установить"
  Labels["ru"].Search := "Поиск знака…"
  Labels["ru"].Folder := "Открыть папку"
  Labels["ru"].Smelter := "Сплавить знаки"
  Labels["ru"].Unicode := "Вставить по Юникоду"
  Labels["ru"].Altcode := "Вставить по Альт-коду"
  Labels["ru"].Notifications := "Вкл/выкл Уведомления групп"


  Labels["en"].Reload := "Reload"
  Labels["en"].Config := "Config file"
  Labels["en"].Locale := "Locale file"
  Labels["en"].Exit := "Exit"
  Labels["en"].Panel := "Open panel"
  Labels["en"].Install := "Install"
  Labels["en"].Search := "Search symbol…"
  Labels["en"].Folder := "Open folder"
  Labels["en"].Smelter := "Symbols melt"
  Labels["en"].Unicode := "Insert by Unicode"
  Labels["en"].Altcode := "Insert by Alt-code"
  Labels["en"].Notifications := "On/Off Group Notifications"

  CurrentApp := "DSL KeyPad " . CurrentVersionString
  UpdateEntry := Labels[LanguageCode].Install . " " . UpdateVersionString

  DSLTray.Delete()
  DSLTray.Add(CurrentApp, (*) => {})
  if UpdateAvailable {
    DSLTray.Add(UpdateEntry, (*) => GetUpdate())
    DSLTray.SetIcon(UpdateEntry, ImageRes, 176)
  }
  DSLTray.Add()
  DSLTray.Add(Labels[LanguageCode].Panel, OpenPanel)
  DSLTray.Add()
  DSLTray.Add(Labels[LanguageCode].Search, (*) => SearchKey())
  DSLTray.Add(Labels[LanguageCode].Unicode, (*) => InsertUnicodeKey())
  DSLTray.Add(Labels[LanguageCode].Altcode, (*) => InsertAltCodeKey())
  DSLTray.Add(Labels[LanguageCode].Smelter, (*) => Ligaturise())
  DSLTray.Add(Labels[LanguageCode].Folder, OpenScriptFolder)
  DSLTray.Add()
  DSLTray.Add(Labels[LanguageCode].Notifications, (*) => ToggleGroupMessage())
  DSLTray.Add()
  DSLTray.Add(Labels[LanguageCode].Reload, ReloadApplication)
  DSLTray.Add(Labels[LanguageCode].Config, OpenConfigFile)
  DSLTray.Add(Labels[LanguageCode].Locale, OpenLocalesFile)
  DSLTray.Add()
  DSLTray.Add(Labels[LanguageCode].Exit, ExitApplication)
  DSLTray.Add()

  DSLTray.SetIcon(Labels[LanguageCode].Panel, AppIcoFile)
  DSLTray.SetIcon(Labels[LanguageCode].Search, ImageRes, 169)
  DSLTray.SetIcon(Labels[LanguageCode].Unicode, Shell32, 225)
  DSLTray.SetIcon(Labels[LanguageCode].Altcode, Shell32, 313)
  DSLTray.SetIcon(Labels[LanguageCode].Smelter, ImageRes, 151)
  DSLTray.SetIcon(Labels[LanguageCode].Folder, ImageRes, 180)
  DSLTray.SetIcon(Labels[LanguageCode].Notifications, ImageRes, 016)
  DSLTray.SetIcon(Labels[LanguageCode].Reload, ImageRes, 229)
  DSLTray.SetIcon(Labels[LanguageCode].Config, ImageRes, 065)
  DSLTray.SetIcon(Labels[LanguageCode].Locale, ImageRes, 015)
  DSLTray.SetIcon(Labels[LanguageCode].Exit, ImageRes, 085)
}
ManageTrayItems()

ShowInfoMessage(["Приложение запущено`nНажмите Win Alt Home для расширенных сведений.", "Application started`nPress Win Alt Home for extended information."])


;! Third Party Functions

;{ [Function] GuiButtonIcon
;{
; Fanatic Guru
; Version 2023 04 08
;
; #Requires AutoHotkey v2.0.2+
;
; FUNCTION to Assign an Icon to a Gui Button
;
;------------------------------------------------
;
; Method:
;   GuiButtonIcon(Handle, File, Index, Options)
;
;   Parameters:
;   1) {Handle} 	HWND handle of Gui button or the Gui button object
;   2) {File} 		File containing icon image
;   3) {Index} 		Index of icon in file
;						Optional: Default = 1
;   4) {Options}	Single letter flag followed by a number with multiple options delimited by a space
;						W = Width of Icon (default = 16)
;						H = Height of Icon (default = 16)
;						S = Size of Icon, Makes Width and Height both equal to Size
;						L = Left Margin
;						T = Top Margin
;						R = Right Margin
;						B = Botton Margin
;						A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)
;
; Return:
;   1 = icon found, 0 = icon not found
;
; Example:
; MyGui := Gui()
; MyButton := MyGui.Add('Button', 'w70 h38', 'Save')
; GuiButtonIcon(MyButton, 'shell32.dll', 259, 's32 a1 r2')
; MyGui.Show
;}
GuiButtonIcon(Handle, File, Index := 1, Options := '')
{
  RegExMatch(Options, 'i)w\K\d+', &W) ? W := W.0 : W := 16
  RegExMatch(Options, 'i)h\K\d+', &H) ? H := H.0 : H := 16
  RegExMatch(Options, 'i)s\K\d+', &S) ? W := H := S.0 : ''
  RegExMatch(Options, 'i)l\K\d+', &L) ? L := L.0 : L := 0
  RegExMatch(Options, 'i)t\K\d+', &T) ? T := T.0 : T := 0
  RegExMatch(Options, 'i)r\K\d+', &R) ? R := R.0 : R := 0
  RegExMatch(Options, 'i)b\K\d+', &B) ? B := B.0 : B := 0
  RegExMatch(Options, 'i)a\K\d+', &A) ? A := A.0 : A := 4
  W *= A_ScreenDPI / 96, H *= A_ScreenDPI / 96
  button_il := Buffer(20 + A_PtrSize)
  normal_il := DllCall('ImageList_Create', 'Int', W, 'Int', H, 'UInt', 0x21, 'Int', 1, 'Int', 1)
  NumPut('Ptr', normal_il, button_il, 0)			; Width & Height
  NumPut('UInt', L, button_il, 0 + A_PtrSize)		; Left Margin
  NumPut('UInt', T, button_il, 4 + A_PtrSize)		; Top Margin
  NumPut('UInt', R, button_il, 8 + A_PtrSize)		; Right Margin
  NumPut('UInt', B, button_il, 12 + A_PtrSize)	; Bottom Margin
  NumPut('UInt', A, button_il, 16 + A_PtrSize)	; Alignment
  SendMessage(BCM_SETIMAGELIST := 5634, 0, button_il, Handle)
  Return IL_Add(normal_il, File, Index)
}
;}


;Don’t remove ↓ or update duplication repair will not work
;This is marker for trim update file to avoid receiving multiple update code at once
;ApplicationEnd
