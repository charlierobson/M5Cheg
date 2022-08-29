	.word	$91bb
	.word	_91bbe-_91bbs
_91bbs:
	jp		$91f2

_91be:
	xor		a
	ld		($91f1),a	; envelope index

	ld		a,%10000000	; set pitch
	out		($20),a
	ld		a,8
	out		($20),a

-:
	LD		A,($91f1)
	inc		A
	LD		($91f1),A
	cp		$0f
	ret		z

	or		%10010000
	out		($20),a

	ld		b,0
	.db		$10,$fe		; djnz $
	jr		{-}
_91bbb:
	.ds		55-(_91bbb-_91bbs)
_91bbe:


	.word	$91f8
	.word	4
	call	$91be ; routine above
	nop

	.word	$813f
	.word	29
	; InitPSG
_813fs:
	ld		a,%10011111	; max attenuation
	out		($20),a
	ld		a,%10111111
	out		($20),a
	ld		a,%11011111
	out		($20),a
	ld		a,%11111111
	out		($20),a
	ret
_813fm:
	.ds		29-(_813fm-_813fs)
_813fe:


	.word	$967a
	.word	34
	; Jumping sound / B   DDDDDDdddd
	ld		a,%10000000
	out		($20),a		; set chan a freq   dddd = 0000
	ld		a,($9df9)	; harry y vel
	add		a,4
	sla		a
	sla		a
	out		($20),a		; upper part of freq   DDDDDD
	ld		a,%10010000
	out		($20),a		; set chan a vol
	.ds		34-19


	.word	$97a0
	.word	45
	; pickup thing sound
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

	ld		a,$0e
	sub		b
	or		%10010000
	out		($20),a
	or		%11110000
	out		($20),a
	ret

	.ds		11,0


	.word	$97cf
	.word	3
	ld		($815b),a	; collect sound envelope index

	.word	$97d5
	.word	3
	ld		a,($815b)

	.word	$97dc
	.word	3
	ld		($815b),a


	.word	$97e7
	.word	7
	call	$97b6
	nop
	nop
	nop
	nop


	.word	$9823
	.word	22
	; imwalkinhere
	.ds		22


	.word	$a471
	.word	6
	; title screen trill
	.byte	$11,$12,$14,$16,$fe,$18

	.word	$a48c
	.word	6
	.byte	$11,$12,$14,$16,$fe,$18


	.word	$a4a4
	.word	_a4a4e-_a4a4s
_a4a4s:
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
_a4a4e:


	.word	$a4ee
	.word	_a4eee-_a4ees
	;PlayNote
_a4ees:
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
	nop
	nop
	nop
	nop
	nop
_a4eee:


	.word	$a50c
	.word	7
	; playSample / envelope
	ld		a,(de)
	or		%10010000
	out		($20),a
	nop
	nop


	.word	$a52b
	; Silence channel A
	.word	7
	ld		a,%10011111
	out		($20),a
	nop
	nop
	nop


	.word	$a532
	.word	55
	; sound setup
	ret
	.ds		54


	.word	$a569
	.word	16
	; envelope data
	.byte	$08,$00,$00,$00
	.byte	$00,$00,$00,$00
	.byte	$01,$01,$01,$02
	.byte	$03,$06,$0a,$0f
