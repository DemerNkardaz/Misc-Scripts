#Requires Autohotkey v2
#SingleInstance Force

; Only EN US & RU RU Keyboard Layout

ConfigFile := "C:\Users\" . A_UserName . "\DSLKeyPadConfig.ini"

OpenConfigFile() {
  global ConfigFile
  Run(ConfigFile)
}

FastKeysIsActive := False
InputHTMLEntities := False
SkipGroupMessage := False

DefaultConfig := [
  ["Settings", "FastKeysIsActive", "False"],
  ["Settings", "InputHTMLEntities", "False"],
  ["Settings", "SkipGroupMessage", "False"],
  ["Settings", "UserLanguage", ""],
  ["LatestPrompts", "Unicode", ""],
  ["LatestPrompts", "Altcode", ""],
  ["LatestPrompts", "Search", ""],
  ["LatestPrompts", "Ligature", ""],
]

if FileExist(ConfigFile) {
  isFastKeysEnabled := IniRead(ConfigFile, "Settings", "FastKeysIsActive", "False")
  isInputHTMLEntities := IniRead(ConfigFile, "Settings", "InputHTMLEntities", "False")
  isSkipGroupMessage := IniRead(ConfigFile, "Settings", "SkipGroupMessage", "False")

  FastKeysIsActive := (isFastKeysEnabled = "True")
  InputHTMLEntities := (isInputHTMLEntities = "True")
  SkipGroupMessage := (isSkipGroupMessage = "True")
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


FormatHotKey(HKey, Modifier := "") {
  MakeString := ""

  SpecialCommandsMap := Map(
    CtrlA, "Ctrl [a][ф]", CtrlB, "Ctrl [b][и]", CtrlC, "Ctrl [c][с]", CtrlD, "Ctrl [d][в]", CtrlE, "Ctrl [e][у]", CtrlF, "Ctrl [f][а]", CtrlG, "Ctrl [g][п]",
    CtrlH, "Ctrl [h][р]", CtrlI, "Ctrl [i][ш]", CtrlJ, "Ctrl [j][о]", CtrlK, "Ctrl [k][л]", CtrlL, "Ctrl [l][д]", CtrlM, "Ctrl [m][ь]", CtrlN, "Ctrl [n][т]",
    CtrlO, "Ctrl [o][щ]", CtrlP, "Ctrl [p][з]", CtrlQ, "Ctrl [q][й]", CtrlR, "Ctrl [r][к]", CtrlS, "Ctrl [s][ы]", CtrlT, "Ctrl [t][е]", CtrlU, "Ctrl [u][г]",
    CtrlV, "Ctrl [v][м]", CtrlW, "Ctrl [w][ц]", CtrlX, "Ctrl [x][ч]", CtrlY, "Ctrl [y][н]", CtrlZ, "Ctrl [z][я]", SpaceKey, "[Space]",
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


InsertCharactersGroups(TargetArray, GroupHotKey, GroupName, AddSeparator := True, ShowModifier := False) {
  LanguageCode := GetLanguageCode()
  TermporaryArray := []

  if AddSeparator
    TermporaryArray.Push(["", "", "", ""])
  TermporaryArray.Push(["", GroupHotKey, "", ""])

  for characterEntry, value in Characters {
    if (HasProp(value, "group") && value.group[1] == GroupName) {
      characterSymbol := HasProp(value, "symbol") ? value.symbol : ""
      modifier := (HasProp(value, "modifier") && ShowModifier) ? value.modifier : ""
      TermporaryArray.Push([value.titles[LanguageCode], FormatHotKey(value.group[2], modifier), characterSymbol, UniTrim(value.unicode)])
    }
  }
  for element in TermporaryArray {
    TargetArray.Push(element)
  }
}

Characters := Map(
  "", { unicode: "", html: "", titles: Map("ru", "", "en", ""), tags: [] },
    "acute", {
      unicode: "{U+0301}", html: "&#769;",
      titles: Map("ru", "Акут", "en", "Acute"),
      tags: ["acute", "акут", "ударение"],
      group: ["Diacritics Primary", ["a", "ф"]],
      symbol: "◌́"
    },
    "acute_double", {
      unicode: "{U+030B}", html: "&#779;",
      titles: Map("ru", "Двойной акут", "en", "Double Acute"),
      tags: ["double acute", "двойной акут", "двойное ударение"],
      group: ["Diacritics Primary", ["A", "Ф"]],
      modifier: "LShift",
      symbol: "◌̋"
    },
    "acute_below", {
      unicode: "{U+0317}", html: "&#791;",
      titles: Map("ru", "Акут снизу", "en", "Acute Below"),
      tags: ["acute below", "акут снизу"]
    },
    ;
    ;
    "asterisk_above", {
      unicode: "{U+20F0}", html: "&#8432;",
      titles: Map("ru", "Астериск сверху", "en", "Asterisk Above"),
      tags: ["asterisk above", "астериск сверху"]
    },
    "asterisk_below", {
      unicode: "{U+0359}", html: "&#857;",
      titles: Map("ru", "Астериск снизу", "en", "Asterisk Below"),
      tags: ["asterisk below", "астериск снизу"]
    },
    ;
    ;
    "breve", {
      unicode: "{U+0306}", html: "&#774;",
      titles: Map("ru", "Кратка", "en", "Breve"),
      tags: ["breve", "бреве", "кратка"]
    },
    "breve_below", {
      unicode: "{U+032E}", html: "&#814;",
      titles: Map("ru", "Кратка снизу", "en", "Breve Below"),
      tags: ["breve below", "бреве снизу", "кратка снизу"]
    },
    "breve_inverted", {
      unicode: "{U+0311}", html: "&#785;",
      titles: Map("ru", "Перевёрнутая кратка", "en", "Inverted Breve"),
      tags: ["inverted breve", "перевёрнутое бреве", "перевёрнутая кратка"]
    },
    "breve_inverted_below", {
      unicode: "{U+032F}", html: "&#815;",
      titles: Map("ru", "Перевёрнутая кратка снизу", "en", "Inverted Breve Below"),
      tags: ["inverted breve below", "перевёрнутое бреве снизу", "перевёрнутая кратка снизу"]
    },
    ;
    ;
    "circumflex", {
      unicode: "{U+0302}", html: "&#770;",
      titles: Map("ru", "Циркумфлекс", "en", "Circumflex"),
      tags: ["circumflex", "циркумфлекс"]
    },
    "circumflex_below", {
      unicode: "{U+032D}", html: "&#813;",
      titles: Map("ru", "Циркумфлекс снизу", "en", "Circumflex Below"),
      tags: ["circumflex below", "циркумфлекс снизу"]
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
InputBridge2(GroupKey) {
  ih := InputHook("L1 C M", "L")
  ih.Start()
  ih.Wait()
  keyPressed := ih.Input


  for characterEntry, value in Characters {
    if (HasProp(value, "group") && value.group[1] == GroupKey) {
      characterKeys := value.group[2]
      characterCodes := [value.unicode, value.html]

      if IsObject(characterKeys) {
        for _, key in characterKeys {
          if (keyPressed == key) {
            InputHTMLEntities ? SendText(characterCodes[2]) : Send(characterCodes[1])
            break
          }
        }
      } else {
        if (keyPressed == characterKeys) {
          InputHTMLEntities ? SendText(characterCodes[2]) : Send(characterCodes[1])
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
  IB := InputBox(Labels[LanguageCode].WindowPrompt, Labels[LanguageCode].SearchTitle, "w256 h92", PromptValue)

  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value

  if (PromptValue = "\") {
    Reload
    return
  }

  Found := False
  for key, values in Characters {
    for _, tag in values.tags {
      if (StrLower(PromptValue) = StrLower(tag)) {
        if InputHTMLEntities {
          SendText(values.html)
        } else {
          Send(values.unicode)
        }
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
  LanguageCode := GetLanguageCode()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "UNICODE"
  Labels["en"].SearchTitle := "UNICODE"
  Labels["ru"].WindowPrompt := "Введите кодовые обозначения"
  Labels["en"].WindowPrompt := "Enter code IDs"

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
  Labels["ru"].WindowPrompt := "Введите кодовые обозначения"
  Labels["en"].WindowPrompt := "Enter code IDs"
  Labels["ru"].Err := "Введите числовые значения"
  Labels["en"].Err := "Enter numeric values separated"

  PromptValue := IniRead(ConfigFile, "LatestPrompts", "Altcode", "")
  IB := InputBox(Labels[LanguageCode].WindowPrompt, Labels[LanguageCode].SearchTitle, "w256 h92", PromptValue)
  if IB.Result = "Cancel"
    return
  else
    PromptValue := IB.Value

  AltCodes := StrSplit(PromptValue, " ")

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

LigaturiserLabels() {
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].SearchTitle := "Сплавить знаки"
  Labels["en"].SearchTitle := "Symbols melt"
  Labels["ru"].WindowPrompt := "Вставьте ингредиенты"
  Labels["en"].WindowPrompt := "Insert ingredients"
  Labels["ru"].Err := "Рецепт не найдено"
  Labels["en"].Err := "Recipe not found"

  return Labels
}

Ligaturise(SmeltingMode := "InputBox") {
  LanguageCode := GetLanguageCode()
  Labels := LigaturiserLabels()
  BackupClipboard := ""

  if (SmeltingMode = "InputBox") {
    PromptValue := IniRead(ConfigFile, "LatestPrompts", "Ligature", "")
    IB := InputBox(Labels[LanguageCode].WindowPrompt, Labels[LanguageCode].SearchTitle, "w256 h92", PromptValue)
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
    MsgBox(Labels[LanguageCode].Err, Labels[LanguageCode].SearchTitle, 0x30)
  }

  if (SmeltingMode = "Clipboard" || SmeltingMode = "Backspace") {
    A_Clipboard := BackupClipboard
  }
  return
}

<#<!F1:: {
  ShowInfoMessage(["Активна первая группа диакритики", "Primary diacritics group has been activated"], "[F1] " . DSLPadTitle, SkipGroupMessage)
  InputBridge2("Diacritics Primary")
}
<#<!F2:: {
  ShowInfoMessage(["Активна вторая группа диакритики", "Secondary diacritics group has been activated"], "[F2] " . DSLPadTitle, SkipGroupMessage)
  InputBridge(BindDiacriticF2)
}
<#<!F3:: {
  ShowInfoMessage(["Активна третья группа диакритики", "Tertiary diacritics group has been activated"], "[F3] " . DSLPadTitle, SkipGroupMessage)
  InputBridge(BindDiacriticF3)
}
<#<!F6:: {
  ShowInfoMessage(["Активна группа специальных символов", "Special characters group has been activated"], "[F6] " . DSLPadTitle, SkipGroupMessage)
  InputBridge(BindSpecialF6)
}
<#<!Space:: {
  ShowInfoMessage(["Активна группа шпаций", "Space group has been activated"], "[Space] " . DSLPadTitle, SkipGroupMessage)
  InputBridge(BindSpaces)
}
<#<!f:: SearchKey()
<#<!u:: InsertUnicodeKey()
<#<!a:: InsertAltCodeKey()
<#<!l:: Ligaturise()
>+l:: Ligaturise("Clipboard")
>+Backspace:: Ligaturise("Backspace")
<#<!1:: SwitchToScript("sup")
<#<^>!1:: SwitchToScript("sub")

<#<!m:: ToggleGroupMessage()

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
      "ru", ["Диакритика", "Буквы", "Пробелы и спец-символы", "Команды", "Плавильня", "Быстрые ключи", "О программе", "Полезное"],
      "en", ["Diacritics", "Letters", "Spaces and spec-chars", "Commands", "Smelting", "Fast Keys", "About", "Useful"]
    )],
    [Map(
      "ru", ["Имя", "Ключ", "Вид", "Unicode"],
      "en", ["Name", "Key", "View", "Unicode"]
    )],
    [Map(
      "ru", ["Имя", "Рецепт", "Результат", "Unicode"],
      "en", ["Name", "Recipe", "Result", "Unicode"]
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
    [Characters["acute"].titles, "[a][ф]", "◌́", UniTrim(Characters["acute"].unicode)],
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
    [Map("ru", "Астериск сверху", "en", "Asterisk Above"), "[a][ф]", "◌⃰", UniTrim(CharCodes.asteriskabove[1])],
    [Map("ru", "Астериск снизу", "en", "Asterisk Below"), "[A][Ф]", "◌͙", UniTrim(CharCodes.asteriskbelow[1])],
    [Map("ru", "Мостик сверху", "en", "Bridge Above"), "[b][и]", "◌͆", UniTrim(CharCodes.bridgeabove[1])],
    [Map("ru", "Мостик снизу", "en", "Bridge Below"), "[B][И]", "◌̪", UniTrim(CharCodes.brevebelow[1])],
    [Map("ru", "Перевёрнутый мостик снизу", "en", "Inverted Bridge Below"), "LCtrl [b][и]", "◌̺", UniTrim(CharCodes.ibridgebelow[1])],
  ]
  LocaliseArrayKeys(DSLContent["BindList"].Diacritics)

  InsertCharactersGroups(DSLContent["BindList"].Diacritics, "GroupHotKey", "Diacritics Primary", True)

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
  DSLContent["ru"].CommandsNote := "Unicode/Alt-code поддерживает ввод множества кодов через пробел, например «44F2 5607 9503» → «䓲嘇锃».`nРежим ввода HTML-энтити не влияет на «Быстрые ключи».`n«Плавильня» может создавать не только лигатуры, например «-+» → «±», «-*» → «×», «***» → «⁂»."
  DSLContent["en"].CommandsNote := "Unicode/Alt-code supports input of multiple codes separated by spaces, for example “44F2 5607 9503” → “䓲嘇锃.”`nHTML entities mode does not affect “Fast keys.”`n“Smelter” can to smelt no only ligatures, for example “-+” → “±”, “-*” → “×”, “***” → “⁂”."

  DSLContent["BindList"].Commands := [
    [Map("ru", "Перейти на страницу символа", "en", "Go to symbol page"), DSLContent[LanguageCode].EntrydblClick, ""],
    [Map("ru", "Копировать символ из списка", "en", "Copy from list"), "Ctrl " . DSLContent[LanguageCode].EntrydblClick, ""],
    [Map("ru", "Поиск по названию", "en", "Find by name"), "Win Alt F", ""],
    [Map("ru", "Вставить по Unicode", "en", "Unicode insertion"), "Win Alt U", ""],
    [Map("ru", "Вставить по Альт-коду", "en", "Alt-code insertion"), "Win Alt A", ""],
    [Map("ru", "Выплавка символа", "en", "Symbol Smelter"), "Win Alt L", "AE → Æ, OE → Œ"],
    [Map("ru", "Выплавка символа в тексте", "en", "Melt symbol in text"), "", ""],
    [Map("ru", " (выделить)", "en", " (select)"), "RShift L", "ІУЖ → Ѭ, ІЭ → Ѥ"],
    [Map("ru", " (установить курсор справа от символов)", "en", " (set cursor to the right of the symbols)"), "RShift Backspace", "st → ﬆ, іат → ѩ"],
    [Map("ru", "Конвертировать в верхний индекс", "en", "Convert into superscript"), "Win LAlt 1", "‌¹‌²‌³‌⁴‌⁵‌⁶‌⁷‌⁸‌⁹‌⁰‌⁽‌⁻‌⁼‌⁾"],
    [Map("ru", "Конвертировать в нижний индекс", "en", "Convert into subscript"), "Win RAlt 1", "‌₁‌₂‌₃‌₄‌₅‌₆‌₇‌₈‌₉‌₀‌₍‌₋‌₌‌₎"],
    [Map("ru", "Активация «Быстрых ключей»", "en", "Toggle FastKeys"), "RAlt Home", ""],
    [Map("ru", "Активация ввода HTML-энтити", "en", "Toggle of HTML entities input"), "RAlt RShift Home", "á → a&#769;"],
    [Map("ru", "Оповещения активации групп", "en", "Groups activation notification toggle"), "Win Alt M", ""],
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

  DSLPadGUI.SetFont("s13")
  ConfigFileBtn := DSLPadGUI.Add("Button", "x622 y519 w32 h32", "⚙️")
  ConfigFileBtn.OnEvent("Click", (*) => OpenConfigFile())


  DSLPadGUI.SetFont("s11")

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

  LigaturesLV := DSLPadGUI.Add("ListView", ColumnListStyle, DSLContent["UI"].TabsNCols[3][1])
  LigaturesLV.ModifyCol(1, ColumnWidths[1])
  LigaturesLV.ModifyCol(2, 110)
  LigaturesLV.ModifyCol(3, 100)
  LigaturesLV.ModifyCol(4, ColumnWidths[4])

  for item in DSLContent["BindList"].LigaturesInput
  {
    LigaturesLV.Add(, item[1], item[2], item[3], item[4])
  }


  Tab.UseTab(6)
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


  Tab.UseTab(7)
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
    "Данная программа предназначена для помощи при вводе специальных символов, таких как диакритические знаки, пробельные символы и видоизменённые буквы. Вы можете использовать горячие клавиши, произвести вставку знака по названию (Win Alt F), если он есть в библиотеке, или ввести «сырое» обозначение Unicode (Win Alt U) любого символа.",
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
    "This program is created to assist in entering special characters, such as diacritics signs, whitespace characters, and modified letters. You can use hotkeys, insert a symbol by name (Win Alt F), if it exists in library, or enter the “raw” Unicode key (Win Alt U) of any symbol.",
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

  DiacriticLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  SpacesLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  FasKeysLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
  LigaturesLV.OnEvent("DoubleClick", LV_OpenUnicodeWebsite)
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

  if (Shortcut = "Win Alt M")
    ToggleGroupMessage()

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


HandleFastKey(Character, CheckOff := False)
{
  global FastKeysIsActive
  if (FastKeysIsActive || CheckOff == True) {
    Send(Character)
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
<^>!>+5:: HandleFastKey(CharCodes.thinsp[1])
<^>!>+6:: HandleFastKey(CharCodes.emsp16[1])
<^>!>+7:: HandleFastKey(CharCodes.nnbsp[1])
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
<^>!NumpadDiv:: HandleFastKey(CharCodes.dagger[1], True)
<^>!>+NumpadDiv:: HandleFastKey(CharCodes.ddagger[1], True)

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


>+<+g:: HandleFastKey(CharCodes.grapjoiner[1], True)
<^<!NumpadDiv:: HandleFastKey(CharCodes.fractionslash[1], True)


ShowInfoMessage(MessagePost, MessageTitle := DSLPadTitle, SkipMessage := False) {
  if SkipMessage == True
    return
  LanguageCode := GetLanguageCode()
  Labels := {}
  Labels[] := Map()
  Labels["ru"] := {}
  Labels["en"] := {}
  Labels["ru"].RunMessage := MessagePost[1]
  Labels["en"].RunMessage := MessagePost[2]
  TrayTip Labels[LanguageCode].RunMessage, MessageTitle, "Iconi"

}

ShowInfoMessage(["Приложение запущено`nНажмите Win Alt Home для расширенных сведений.", "Application started`nPress Win Alt Home for extended information."])