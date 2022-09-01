; bonus dinger
PATCH($91f8, 4)
	call	doDinger
ENDPATCH($91f8, 4)

PATCH($91bb, 55)
	jp		$91f2

doDinger:
	xor		a
	ld		($91f1),a	; envelope index

	ld		a,%10000000	; set pitch
	out		($20),a
	ld		a,8
	out		($20),a

dingerLoop:
	LD		A,($91f1)
	inc		A
	LD		($91f1),A
	cp		$0f
	ret		z

	or		%10010000
	out		($20),a

	ld		b,0
dingerDelay:
	djnz	dingerDelay
	jr		dingerLoop
ENDPATCH($91bb, 55)


; InitPSG
PATCH($813f, 29)
	ld		a,%10011111	; max attenuation
	out		($20),a
	ld		a,%10111111
	out		($20),a
	ld		a,%11011111
	out		($20),a
	ld		a,%11111111
	out		($20),a
	ret
ENDPATCH($813f, 29)


	; Jumping sound
PATCH($967a, 34)
	ld		a,%10000000
	out		($20),a		; set chan a freq   dddd = 0000
	ld		a,($9df9)	; harry y vel
	add		a,4
	out		($20),a		; upper part of freq   DDDDDD
	ld		a,%10010000
	out		($20),a		; set chan a vol
ENDPATCH($967a, 34)


	; pickup thing sound
PATCH($97a0, 45)
	ld		a,%10000000
	out		($20),a
	ld		a,%00111100
	out		($20),a
	ld		a,%10010000
	out		($20),a

	ld		a,%11100101
	out		($20),a
	ld		a,%11110000
	out		($20),a
	jr		$+25

	sla		a
	inc		a
	ld		b,a
	ld		a,$0e
	sub		b
	or		%10010000
	out		($20),a
	or		%11110000
	out		($20),a
	ret
ENDPATCH($97a0, 45)


vCOLLECTENV = $815b

PATCH($97cd, 5)
	ld		a,$7
	ld		(vCOLLECTENV),a
ENDPATCH($97cd, 5)

PATCH($97d5, 3)
	ld		a,(vCOLLECTENV)
ENDPATCH($97d5, 3)

PATCH($97dc, 3)
	ld		(vCOLLECTENV),a
ENDPATCH($97dc, 3)


PATCH($97e6, 8)
	call	$97b6
ENDPATCH($97e6, 8)

PATCH($97fa, 2)
	ld		b,$20		; ladder climb pitch
ENDPATCH($97fa, 2)

PATCH($97ff, 2)
	ld		b,$30		; walkin' pitch
ENDPATCH($97ff, 2)

; imwalkinhere
PATCH($9823, 22)
	ld		a,%10000000
	out		($20),a
	ld		a,b
	out		($20),a
	ld		a,%10010000
	out		($20),a
ENDPATCH($9823, 22)


PATCH($a471, 6)
	; title screen trill
	.byte	$11,$12,$14,$16,$fe,$18
ENDPATCH($a471, 6)

PATCH($a48c,  6)
	; life lost trill
	.byte	$11,$12,$14,$16,$fe,$18
ENDPATCH($a48c,  6)


; tone table
PATCH($a4a4, 74)
   .byte $0x1, $0x38	; 0
   .byte $0xf, $0x34
   .byte $0xf, $0x31
   .byte $0x2, $0x2f
   .byte $0x8, $0x2c
   .byte $0x0, $0x2a
   .byte $0xa, $0x27
   .byte $0x7, $0x25
   .byte $0x5, $0x23	; 8
   .byte $0x5, $0x21
   .byte $0x7, $0x1f
   .byte $0xb, $0x1d
   .byte $0x0, $0x1c
   .byte $0x7, $0x1a
   .byte $0xf, $0x18
   .byte $0x9, $0x17
   .byte $0x4, $0x16	; 16
   .byte $0x0, $0x15
   .byte $0xd, $0x13
   .byte $0xb, $0x12
   .byte $0xa, $0x11
   .byte $0xa, $0x10
   .byte $0xb, $0xf
   .byte $0xd, $0xe
   .byte $0x0, $0xe		; 24
   .byte $0x3, $0xd
   .byte $0x7, $0xc
   .byte $0xc, $0xb
   .byte $0x2, $0xb
   .byte $0x8, $0xa
   .byte $0xe, $0x9
   .byte $0x5, $0x9
   .byte $0xd, $0x8		; 32
   .byte $0x5, $0x8
   .byte $0xd, $0x7
   .byte $0x6, $0x7
   .byte $0x1, $0x0		; 36 ($24)
ENDPATCH($a4a4, 74)


; PlayNote
PATCH($a4ee, 25)
	SLA		a
	LD 		HL,$a4a4
	ADD		A,L
	LD 		L,A
	LD 		A,H
	ADC		A,0
	LD 		H,A
	ld		a,(hl)
	or		%10000000
	out		($20),a
	inc		hl
	ld		a,(hl)
	out		($20),a
ENDPATCH($a4ee, 25)


; playSample / envelope
PATCH($a50c, 7)
	ld		a,(de)
	or		%10010000
	out		($20),a
ENDPATCH($a50c, 7)


; Silence channel A
PATCH($a52b, 7)
	ld		a,%10011111
	out		($20),a
ENDPATCH($a52b, 7)


; sound setup
PATCH($a532, 55)
	ret

instructionVandalism:
	call	fPRINTSTRING
	.byte	16h, 13h,  1h
	.asc	"SORD M5 PORT BY CHARLIE ROBSON" ; 30 chars
	.byte	$ff
	jp		$827a
ENDPATCH($a532, 55)


; envelope data
PATCH($a569, 16)
	.byte	$08,$00,$00,$00
	.byte	$00,$00,$00,$00
	.byte	$01,$01,$01,$02
	.byte	$03,$06,$0a,$0f
ENDPATCH($a569, 16)
