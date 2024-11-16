#Requires Autohotkey v2
#SingleInstance Force

CharMinus := Chr(0x2212)
CharNumberSpace := Chr(0x2009) ; Thin Space for “10 000” formats
CharDegreeSpace := Chr(0x202F) ; Narrow No-Break Space between number and scale symbol
CharDegree := Chr(0x00B0)
CharApostrophe := Chr(0x2019) ; Right Single Quotation Mark

IsExtendedFormattingEnabled := True ; Enable or disable formatting like “15,000,000.00/15 000 000,00”
ExtendedFormattingFromCount := 5 ; Starting count of integer digits for formatting: 5 means 1000 will be 1000, but 10000 will be 10,000

RegistryTemperaturesHotString() {
	HotStringsEntries := ["cf", "fc", "ck", "kc", "fk", "kf", "kr", "rk", "fr", "rf", "cr", "rc", "cn", "nc", "fn", "nf", "kn", "nk", "rn", "nr", "cd", "dc", "fd", "df", "kd", "dk", "rd", "dr", "nd", "dn"]

	ShortCutConverter(InputString) {
		InputString := StrUpper(InputString)
		return SubStr(InputString, 1, 1) "t" SubStr(InputString, 2, 1)
	}

	RegistryBridge(conversionLabel) {
		HotString(":C?0:ct" conversionLabel, (D) => TemperaturesConversionsInputHook(ShortCutConverter(conversionLabel), D))
	}

	for conversionLabel in HotStringsEntries {
		RegistryBridge(conversionLabel)
	}
} RegistryTemperaturesHotString()


TemperaturesConversionsInputHook(ConversionType, FallBackString := "") {
	FallBackString := RegExReplace(FallBackString, ".*:(.*)", "$1")

	IH := InputHook("C")
	IH.KeyOpt("{Space}{Enter}{Tab}", "E")
	IH.Start()
	IH.Wait()

	TemperatureValue := IH.Input
	TemperatureValue := RegExReplace(TemperatureValue, "[^\d.,'-" CharMinus "]")

	Output := ""

	try {
		Output := TemperaturesConversion(ConversionType, TemperatureValue)
	} catch {
		Output := FallBackString
	}

	SendText(Output)
}

TemperaturesConversion(ConversionType := "CtF", TemperatureValue := 0.00) {
	ConversionTo := SubStr(ConversionType, -1)
	ConversionsSymbols := Map(
		"C", CharDegree "C", ; or use Chr(0x2103), dedicated Celsius symbol
		"F", CharDegree "F", ; or use Chr(0x2109), dedicated Fahrenheit symbol
		"K", "K", ; or use Chr(0x212A), dedicated Kelvin symbol
		"R", CharDegree "R", ; Rankine Scale
		"N", CharDegree "N", ; Newton Scale
		"D", CharDegree "D", ; Delisle Scale
	)
	ConversionsValues := Map(
		"CtF", (GetConverted) => (GetConverted * 9 / 5) + 32,
		"FtC", (GetConverted) => (GetConverted - 32) * 5 / 9,
		"CtK", (GetConverted) => GetConverted + 273.15,
		"KtC", (GetConverted) => GetConverted - 273.15,
		"FtK", (GetConverted) => (GetConverted - 32) * 5 / 9 + 273.15,
		"KtF", (GetConverted) => (GetConverted - 273.15) * 9 / 5 + 32,
		"KtR", (GetConverted) => GetConverted * 1.8,
		"RtK", (GetConverted) => GetConverted / 1.8,
		"FtR", (GetConverted) => GetConverted + 459.67,
		"RtF", (GetConverted) => GetConverted - 459.67,
		"CtR", (GetConverted) => (GetConverted + 273.15) * 1.8,
		"RtC", (GetConverted) => (GetConverted / 1.8) - 273.15,
		"CtN", (GetConverted) => GetConverted * 33 / 100,
		"NtC", (GetConverted) => GetConverted * 100 / 33,
		"NtF", (GetConverted) => (GetConverted * 60 / 11) + 32,
		"FtN", (GetConverted) => (GetConverted - 32) * 11 / 60,
		"NtK", (GetConverted) => (GetConverted * 100 / 33) + 273.15,
		"KtN", (GetConverted) => (GetConverted - 273.15) * 33 / 100,
		"NtR", (GetConverted) => (GetConverted * 100 / 33 + 273.15) * 1.8,
		"RtN", (GetConverted) => (GetConverted / 1.8 - 273.15) * 33 / 100,
		"CtD", (GetConverted) => (100 - GetConverted) * 3 / 2,
		"DtC", (GetConverted) => 100 - (GetConverted * 2 / 3),
		"FtD", (GetConverted) => (212 - GetConverted) * 5 / 6,
		"DtF", (GetConverted) => 212 - (GetConverted * 6 / 5),
		"KtD", (GetConverted) => (373.15 - GetConverted) * 3 / 2,
		"DtK", (GetConverted) => 373.15 - (GetConverted * 2 / 3),
		"RtD", (GetConverted) => (671.67 - GetConverted) * 5 / 6,
		"DtR", (GetConverted) => 671.67 - (GetConverted * 6 / 5),
		"NtD", (GetConverted) => (33 - GetConverted) * 50 / 11,
		"DtN", (GetConverted) => 33 - (GetConverted * 11 / 50),
	)

	ConvertedTemperatureValue := 0
	NegativePoint := False

	if (InStr(TemperatureValue, CharMinus)) {
		TemperatureValue := RegExReplace(TemperatureValue, CharMinus, "-")
	}

	TypographyRule := "English"
	TypographyTypes := Map(
		"Deutsch", [".,", (T) => RegExReplace(T, "\.,", ".")],
		"Albania", ["..", (T) => RegExReplace(T, "\.\.", ".")],
		"Switzerland-Comma", ["''", (T) => RegExReplace(T, "\'\'", ".")],
		"Switzerland-Dot", ["'", (T) => RegExReplace(T, "\'", ".")],
		"Russian", [",", (T) => RegExReplace(T, ",", ".")],
	)

	for regionalType, value in TypographyTypes {
		if InStr(TemperatureValue, value[1]) {
			TemperatureValue := value[2](TemperatureValue)
			TypographyRule := regionalType
			break
		}
	}

	if (ConversionsValues.Has(ConversionType)) {
		ConvertedTemperatureValue := ConversionsValues[ConversionType](TemperatureValue)
	} else {
		Throw Error("Wrong conversion type: " ConversionType)
	}

	if !(GetKeyState("CapsLock", "T"))
		ConvertedTemperatureValue := Round(ConvertedTemperatureValue, 2)

	if (Mod(ConvertedTemperatureValue, 1) = 0)
		ConvertedTemperatureValue := Round(ConvertedTemperatureValue)

	if (SubStr(ConvertedTemperatureValue, 1, 1) = "-") {
		ConvertedTemperatureValue := SubStr(ConvertedTemperatureValue, 2)
		NegativePoint := True
	}

	if (TypographyRule = "Russian" || TypographyRule = "Deutsch" || TypographyRule = "Switzerland-Comma")
		ConvertedTemperatureValue := RegExReplace(ConvertedTemperatureValue, "\.", ",")

	if (IsExtendedFormattingEnabled) {
		IntegerPart := RegExReplace(ConvertedTemperatureValue, "(\..*)|([,].*)", "")

		if (StrLen(IntegerPart) >= ExtendedFormattingFromCount) {
			DecimalSeparators := Map(
				"English", ",",
				"Deutsch", ".",
				"Russian", CharNumberSpace,
				"Albania", CharNumberSpace,
				"Switzerland-Comma", CharApostrophe,
				"Switzerland-Dot", CharApostrophe,
			)

			IntegerPart := RegExReplace(IntegerPart, "\B(?=(\d{3})+(?!\d))", DecimalSeparators[TypographyRule])
			ConvertedTemperatureValue := RegExReplace(ConvertedTemperatureValue, "^\d+", IntegerPart)
		}

	}

	ConvertedTemperatureValue := (NegativePoint ? CharMinus : "") ConvertedTemperatureValue CharDegreeSpace ConversionsSymbols[ConversionTo]
	return ConvertedTemperatureValue
}