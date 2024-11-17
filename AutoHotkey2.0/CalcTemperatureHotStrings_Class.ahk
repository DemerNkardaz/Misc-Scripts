Class TemperatureConversion {
	#Requires Autohotkey v2.0+

	static isDedicatedUnicodeChars := False ; False for common symbols, True for dedicated scale symbol if exists
	static isExtendedFormattingEnabled := True ; Enable or disable formatting like “15,000,000.00/15 000 000,00”
	static extendedFormattingFromCount := 5 ; Starting count of integer digits for formatting: 5 means 1000 will be 1000, but 10000 will be 10,000
	static calcRoundValue := 2 ; Number of digits after decimal point: 2 then “-273.15”, 3 then “-273.150”...

	static chars := {
		minus: Chr(0x2212),
		numberSpace: Chr(0x2009), ; Thin Space for “10 000” formats
		degreeSpace: Chr(0x202F), ; Narrow No-Break Space between number and scale symbol
		degree: Chr(0x00B0),
		apostrophe: Chr(0x2019), ; Right Single Quotation Mark
		arrowRight: Chr(0x2192),
	}

	static scales := {
		C: [Chr(0x2103), this.chars.degree "C"],
		F: [Chr(0x2109), this.chars.degree "F"],
		K: [Chr(0x212A), "K"],
		R: this.chars.degree "R",
		N: this.chars.degree "N",
		D: this.chars.degree "D",
	}

	static typographyTypes := Map(
		"Deutsch", [".,", (T) => RegExReplace(T, "\.,", ".")],
		"Albania", ["..", (T) => RegExReplace(T, "\.\.", ".")],
		"Switzerland-Comma", ["''", (T) => RegExReplace(T, "\'\'", ".")],
		"Switzerland-Dot", ["'", (T) => RegExReplace(T, "\'", ".")],
		"Russian", [",", (T) => RegExReplace(T, ",", ".")],
	)

	static __New() {
		this.RegistryHotstrings()
	}

	static RegistryHotstrings() {
		hsKeys := [
			'cd', 'cf', 'ck', 'cn', 'cr', ; Celsius
			'fc', 'fd', 'fk', 'fn', 'fr', ; Fahrenheit
			'kc', 'kd', 'kf', 'kn', 'kr', ; Kelvin
			'nc', 'nd', 'nf', 'nk', 'nr', ; Newton
			'rc', 'rd', 'rf', 'rk', 'rn',  ; Rankine
			'dc', 'df', 'dk', 'dn', 'dr', ; Delisle
		]

		callback := ObjBindMethod(this, 'Converter')

		for hsKey in hsKeys {
			HotString(":C?0:ct" hsKey, callback)
		}
	}

	static Converter(conversionType) {
		hwnd := WinActive('A')
		conversionFromTo := SubStr(conversionType, -2)

		labelFrom := SubStr(conversionFromTo, 1, 1)
		labelTo := SubStr(conversionFromTo, 2, 1)

		conversionLabel := StrUpper("[" (IsObject(this.scales.%labelFrom%) ? this.scales.%labelFrom%[2] : this.scales.%labelFrom%) " " this.chars.arrowRight " " (IsObject(this.scales.%labelTo%) ? this.scales.%labelTo%[2] : this.scales.%labelTo%) "]")

		numberValue := this.GetNumber(conversionLabel)

		try {
			regionalType := "English"
			for region, value in this.typographyTypes {
				if InStr(numberValue, value[1]) {
					numberValue := value[2](numberValue)
					regionalType := region
					break
				}
			}

			numberValue := %conversionFromTo%(StrReplace(numberValue, this.chars.minus, "-"))

			(SubStr(numberValue, 1, 1) = "-") ? (numberValue := SubStr(numberValue, 2), negativePoint := True) : (negativePoint := False)

			temperatureValue := this.PostFormatting(numberValue, labelTo, negativePoint, regionalType)

			if !WinActive('ahk_id ' hwnd) {
				WinActivate('ahk_id ' hwnd)
				WinWaitActive(hwnd)
			}

			SendText(temperatureValue)
		} catch {
			SendText(SubStr(conversionType, -4))
		}
		return

		; Celsius
		CF(G) => (G * 9 / 5) + 32
		CK(G) => G + 273.15
		CR(G) => (G + 273.15) * 1.8
		CN(G) => G * 33 / 100
		CD(G) => (100 - G) * 3 / 2

		; Fahrenheit
		FC(G) => (G - 32) * 5 / 9
		FK(G) => (G - 32) * 5 / 9 + 273.15
		FR(G) => G + 459.67
		FN(G) => (G - 32) * 11 / 60
		FD(G) => (212 - G) * 5 / 6

		; Kelvin
		KC(G) => G - 273.15
		KF(G) => (G - 273.15) * 9 / 5 + 32
		KR(G) => G * 1.8
		KN(G) => (G - 273.15) * 33 / 100
		KD(G) => (373.15 - G) * 3 / 2

		; Rankine
		RC(G) => (G / 1.8) - 273.15
		RF(G) => G - 459.67
		RK(G) => G / 1.8
		RN(G) => (G / 1.8 - 273.15) * 33 / 100
		RD(G) => (671.67 - G) * 5 / 6

		; Newton
		NC(G) => G * 100 / 33
		NF(G) => (G * 60 / 11) + 32
		NK(G) => (G * 100 / 33) + 273.15
		NR(G) => (G * 100 / 33 + 273.15) * 1.8
		ND(G) => (33 - G) * 50 / 11

		; Delisle
		DC(G) => 100 - (G * 2 / 3)
		DF(G) => 212 - (G * 6 / 5)
		DK(G) => 373.15 - (G * 2 / 3)
		DR(G) => 671.67 - (G * 6 / 5)
		DN(G) => 33 - (G * 11 / 50)
	}

	static GetNumber(conversionLabel) {
		static validator := "1234567890,.-'" this.chars.minus

		numberValue := ""

		Loop {
			IH := InputHook("L1", "{Escape}")
			IH.Start(), IH.Wait()

			if (IH.EndKey = "Escape") {
				numberValue := ""
				break
			} else if InStr(validator, IH.Input) {
				numberValue .= IH.Input
				Tooltip(conversionLabel " " numberValue)
			} else break
		}

		ToolTip()

		return numberValue
	}

	static PostFormatting(temperatureValue, scale, negativePoint := False, regionalType := "English") {
		if !(GetKeyState("CapsLock", "T"))
			temperatureValue := Round(temperatureValue, Integer(this.calcRoundValue))

		if (Mod(temperatureValue, 1) = 0)
			temperatureValue := Round(temperatureValue)

		if (regionalType = "Russian" || regionalType = "Deutsch" || regionalType = "Switzerland-Comma")
			temperatureValue := RegExReplace(temperatureValue, "\.", ",")

		integerPart := RegExReplace(temperatureValue, "(\..*)|([,].*)", "")

		if (this.isExtendedFormattingEnabled && StrLen(integerPart) >= this.extendedFormattingFromCount) {
			decimalSeparators := Map(
				"English", ",",
				"Deutsch", ".",
				"Russian", this.chars.numberSpace,
				"Albania", this.chars.numberSpace,
				"Switzerland-Comma", this.chars.apostrophe,
				"Switzerland-Dot", this.chars.apostrophe,
			)

			integerPart := RegExReplace(integerPart, "\B(?=(\d{3})+(?!\d))", decimalSeparators[regionalType])
			temperatureValue := RegExReplace(temperatureValue, "^\d+", integerPart)
		}

		temperatureValue := (negativePoint ? this.chars.minus : "") temperatureValue this.chars.degreeSpace (IsObject(this.scales.%scale%) ? (this.isDedicatedUnicodeChars ? this.scales.%scale%[1] : this.scales.%scale%[2]) : this.scales.%scale%)
		return temperatureValue
	}
}