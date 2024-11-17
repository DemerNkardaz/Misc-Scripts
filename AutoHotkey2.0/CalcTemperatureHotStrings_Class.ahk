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
		R: "R",
		N: "N",
		D: "D",
		H: "H",
		L: "L",
		W: "W",
		RO: "R" Chr(0x00F8),
		RE: "R" Chr(0x00E9),
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
			'cd', 'cf', 'ck', 'cn', 'cr', "cl", "cw", "cro", "cre", 'ch', ; Celsius
			'fc', 'fd', 'fk', 'fn', 'fr', 'fl', 'fw', 'fro', 'fre', ; Fahrenheit
			'kc', 'kd', 'kf', 'kn', 'kr', 'kl', 'kw', 'kro', 'kre', ; Kelvin
			'nc', 'nd', 'nf', 'nk', 'nr', 'nl', 'nw', 'nro', 'nre', ; Newton
			'rc', 'rd', 'rf', 'rk', 'rn', 'rl', 'rw', 'rro', 'rre', ; Rankine
			'dc', 'df', 'dk', 'dn', 'dr', 'dl', 'dw', 'dro', 'dre', ; Delisle
			'lc', 'lf', 'lk', 'ln', 'lr', 'ld', 'lw', 'lro', 'lre', ; Leiden
			'wc', 'wf', 'wk', 'wn', 'wr', 'wd', 'wl', 'wro', 'wre', ; Wedgwood
			'roc', 'rof', 'rok', 'ron', 'ror', 'rod', 'rol', 'row', 'rore', ; Romer
			'rec', 'ref', 'rek', 'ren', 'rer', 'red', 'rel', 'rew', 'rero', ; Reaumur
			'hc', ; Hooke
		]

		callback := ObjBindMethod(this, 'Converter')

		for hsKey in hsKeys {
			HotString(":C?0:ct" hsKey, callback)
		}
	}

	static Converter(conversionType) {
		hwnd := WinActive('A')

		conversionFromTo := RegExReplace(conversionType, "^.*t", "")

		labelFrom := (RegExMatch(conversionFromTo, "^ro|^re")) ? SubStr(conversionFromTo, 1, 2) : SubStr(conversionFromTo, 1, 1)
		labelTo := (RegExMatch(conversionFromTo, "ro$|re$")) ? SubStr(conversionFromTo, -2) : SubStr(conversionFromTo, -1, 1)


		conversionLabel := "[" (IsObject(this.scales.%labelFrom%) ? this.scales.%labelFrom%[2] : this.chars.degree this.scales.%labelFrom%) " " this.chars.arrowRight " " (IsObject(this.scales.%labelTo%) ? this.scales.%labelTo%[2] : this.chars.degree this.scales.%labelTo%) "]"

		Tooltip(conversionLabel)
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
			SendText(RegExReplace(conversionType, "^.*?:.*?:", ""))
		}
		return

		; Celsius
		CF(G) => (G * 9 / 5) + 32
		CK(G) => G + 273.15
		CR(G) => (G + 273.15) * 1.8
		CN(G) => G * 33 / 100
		CD(G) => (100 - G) * 3 / 2
		CH(G) => G * 5 / 12
		CL(G) => G + 253
		CW(G) => (G / 24.857191) - 10.821818
		CRO(G) => (G / 1.904762) + 7.5
		CRE(G) => G / 1.25

		; Fahrenheit
		FC(G) => (G - 32) * 5 / 9
		FK(G) => (G - 32) * 5 / 9 + 273.15
		FR(G) => G + 459.67
		FN(G) => (G - 32) * 11 / 60
		FD(G) => (212 - G) * 5 / 6
		FL(G) => (G / 1.8) + 235.222222
		FW(G) => (G / 44.742943) - 11.537015
		FRO(G) => (G / 3.428571) - 1.833333
		FRE(G) => (G / 2.25) - 14.222222

		; Kelvin
		KC(G) => G - 273.15
		KF(G) => (G - 273.15) * 9 / 5 + 32
		KR(G) => G * 1.8
		KN(G) => (G - 273.15) * 33 / 100
		KD(G) => (373.15 - G) * 3 / 2
		KL(G) => G - 20.15
		KW(G) => (G / 24.857191) - 21.81059
		KRO(G) => (G / 1.904762) - 135.90375
		KRE(G) => (G / 1.25) - 218.52

		; Rankine
		RC(G) => (G / 1.8) - 273.15
		RF(G) => G - 459.67
		RK(G) => G / 1.8
		RN(G) => (G / 1.8 - 273.15) * 33 / 100
		RD(G) => (671.67 - G) * 5 / 6
		RL(G) => (G / 1.8) - 20.15
		RW(G) => (G / 44.742943) - 21.81059
		RRO(G) => (G / 3.428571) - 135.90375
		RRE(G) => (G / 2.25) - 218.52

		; Newton
		NC(G) => G * 100 / 33
		NF(G) => (G * 60 / 11) + 32
		NK(G) => (G * 100 / 33) + 273.15
		NR(G) => (G * 100 / 33 + 273.15) * 1.8
		ND(G) => (33 - G) * 50 / 11
		NL(G) => (3.030303 * G) + 253
		NW(G) => (G / 8.202873) - 10.821818
		NRO(G) => (1.590909 * G) + 7.5
		NRE(G) => 2.424242 * G

		; Delisle
		DC(G) => 100 - (G * 2 / 3)
		DF(G) => 212 - (G * 6 / 5)
		DK(G) => 373.15 - (G * 2 / 3)
		DR(G) => 671.67 - (G * 6 / 5)
		DN(G) => 33 - (G * 11 / 50)
		DL(G) => (-G / 1.5) + 353
		DW(G) => (-G / 37.285786) - 6.798838
		DRO(G) => (-G / 2.857143) + 60
		DRE(G) => (-G / 1.875) + 80

		; Hooke
		HC(G) => (G * 12 / 5)

		; Leiden
		LC(G) => G - 253
		LF(G) => (1.8 * G) - 423.4
		LK(G) => G + 20.15
		LR(G) => (1.8 * G) + 36.27
		LN(G) => (G / 3.030303) - 83.49
		LD(G) => (-1.5 * G) + 529.5
		LW(G) => (G / 24.857191) - 21
		LRO(G) => (G / 1.904762) - 125.325
		LRE(G) => (G / 1.25) - 202.4

		; Wedgwood
		WC(G) => (24.857191 * G) + 269
		WF(G) => (44.742943 * G) + 516.2
		WK(G) => (24.857191 * G) + 542.15
		WR(G) => (44.742943 * G) + 975.87
		WD(G) => (-37.285786 * G) - 253.5
		WN(G) => (8.202873 * G) + 88.77
		WL(G) => (24.857191 * G) + 522
		WRO(G) => (13.050025 * G) + 148.725
		WRE(G) => (19.885753 * G) + 215.2

		; Romer
		ROC(G) => (1.904762 * G) - 14.285714
		ROF(G) => (3.428571 * G) + 6.285714
		ROK(G) => (1.904762 * G) + 258.864286
		ROR(G) => (3.428571 * G) + 465.955714
		RON(G) => (G / 1.590909) - 4.714286
		ROD(G) => (-2.857143 * G) + 171.428571
		ROL(G) => (1.904762 * G) + 238.7142861
		ROW(G) => (G / 13.050025) - 11.39653
		RORE(G) => (1.52381 * G) - 11.428571

		; Reaumur
		REC(G) => 1.25 * G
		REF(G) => (2.25 * G) + 32
		REK(G) => (1.25 * G) + 273.15
		RER(G) => (2.25 * G) + 491.67
		REN(G) => G / 2.424242
		RED(G) => (-1.875 * G) + 150
		REL(G) => (1.25 * G) + 253
		REW(G) => (G / 19.885753) - 10.821818
		RERO(G) => (G / 1.52381) + 7.5
	}

	static GetNumber(conversionLabel) {
		static validator := "v1234567890,.-'" this.chars.minus
		static expression := "^[1234567890,.'\- " this.chars.minus "]+$"

		numberValue := ""

		Loop {
			IH := InputHook("L1", "{Escape}{Backspace}")
			IH.Start(), IH.Wait()

			if (IH.EndKey = "Escape") {
				numberValue := ""
				break
			} else if (IH.EndKey = "Backspace") {
				if StrLen(numberValue) > 0
					numberValue := SubStr(numberValue, 1, -1)
			} else if InStr(validator, IH.Input) {
				if InStr(IH.Input, "v") {
					ClipWait(0.5, 1)
					if RegExMatch(A_Clipboard, expression) {
						numberValue .= A_Clipboard
					}
				} else
					numberValue .= IH.Input
			} else break

			Tooltip(conversionLabel " " numberValue)
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

		temperatureValue := (negativePoint ? this.chars.minus : "") temperatureValue this.chars.degreeSpace (IsObject(this.scales.%scale%) ? (this.isDedicatedUnicodeChars ? this.scales.%scale%[1] : this.scales.%scale%[2]) : this.chars.degree this.scales.%scale%)
		return temperatureValue
	}
}