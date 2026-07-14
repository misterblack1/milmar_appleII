; --- Apple II soft switches ---
TXTSET  = $C051         ; 1100000001010001 display text
MIXCLR  = $C052         ; 1100000001010010 full screen (no mix)
LOWSCR  = $C054         ; 1100000001010100 page 1
LORES   = $C056         ; 1100000001010110 lo-res (hi-res off)
SPKR    = $C030         ; 1100000000110000 works toggle speaker

* = $F800

reset
		SEI
		CLD
		LDX #$FF
		TXS				; set the stack-pointer REGISTER only -- writes no RAM

		; force text page 1, full screen, hi-res off (I/O strobes only)
		STA TXTSET
		STA MIXCLR
		STA LOWSCR
		STA LORES

		; audible "I'm alive" -- register-only, no stack/zero-page use
		LDX #$20
beep_o	LDY #$C0
beep_i	DEY
		NOP
		NOP
		BNE beep_i
		STA SPKR
		DEX
		BNE beep_o

		; fill $0400-$07FF: value = address low byte = one $00-$FF cycle per page
		LDX #$00
fill	TXA
		STA $0400,X
		STA $0500,X
		STA $0600,X
		STA $0700,X
		INX
		BNE fill

spin	JMP spin			; freeze on the pattern

		!fill $FFFA-*, $FF	; pad the rest of the 2 KB with $FF

* = $FFFA
		!word reset, reset, reset	; NMI, RESET, IRQ vectors
