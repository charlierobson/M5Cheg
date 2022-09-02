; sord key matrix
;   7       6       5       4       3       2       1       0  bit/port
;-------+-------+-------+-------+-------+-------+-------+-------.
; RETRN | SPACE |  ---  |  ---  |R.SHIFT|L.SHIFT| FUNC  | CTRL  | 30
;-------+-------+-------+-------+-------+-------+-------+-------+
;   8   |   7   |   6   |   5   |   4   |   3   |   2   |   1   | 31
;-------+-------+-------+-------+-------+-------+-------+-------+
;   I   |   U   |   Y   |   T   |   R   |   E   |   W   |   Q   | 32
;-------+-------+-------+-------+-------+-------+-------+-------+
;   K   |   J   |   H   |   G   |   F   |   D   |   S   |   A   | 33
;-------+-------+-------+-------+-------+-------+-------+-------+
;   ,   |   M   |   N   |   B   |   V   |   C   |   X   |   Z   | 34
;-------+-------+-------+-------+-------+-------+-------+-------+
;   \   |   _   |   /   |   .   |   ^   |   -   |   0   |   9   | 35
;-------+-------+-------+-------+-------+-------+-------+-------+
;   ]   |   :   |   ;   |   L   |   [   |   @   |   P   |   O   | 36
;-------+-------+-------+-------+-------+-------+-------+-------+
; R.JOY | R.JOY | R.JOY | R.JOY | L.JOY | L.JOY | L.JOY | L.JOY | 37
;   |   |  <--  |   ^   |  -->  |   |   |  <--  |   ^   |  -->  |
;   v   |       |   |   |       |   v   |       |   |   |       |
;-------+-------+-------+-------+-------+-------+-------+-------'


; original special keys

; 0x80 escape
; 0x81 space
; 0x82 enter
; 0x83 alphalock
; 0x84 f7
; 0x85 f0
; 0x86 break
; 0x87 cursorud
; 0x88 quarter
; 0x89 divide
; 0x8a f5
; 0x8b cursorlr
; 0x8c threequarter
; 0x8d f4
; 0x8e dilins
; 0x8f f3
; 0x90 f2
; 0x91 f1
; 0x92 f6

; key cap map
PATCH($8797, 64)
	.byte	$80,$81,$00,$00,$82,$83,$84,$85
	.byte	'8','7','6','5','4','3','2','1'
	.byte	'I','U','Y','T','R','E','W','Q'
	.byte	'K','J','H','G','F','D','S','A'
	.byte	',','M','N','B','V','C','X','Z'
	.byte	$8a,$86,'/','.',$87,'-','0','9'
	.byte	$88,':',';','L',$89,'@','P','O'
	.byte	$8c,$8d,$8e,$8f,$8c,$8d,$8e,$8f
ENDPATCH($8797, 64)


PATCH($87ec, 227)
specialKeyNames:
	.word	knReturn		;	0x80
	.word	knSpace			;	0x81
	.word	knRShift		;	0x82
	.word	knLShift		;	0x83
    .word	knFunc			;	0x84
    .word	knCtrl			;	0x85
    .word	knUnderscore	;	0x86
    .word	knCaret			;	0x87
    .word	knRiSquare		;	0x88
    .word	knLeSquare		;	0x89
    .word	knBackSlash		;	0x8a
    .word	knFwdSlash		;	0x8b

    .word	knPadDown		;	0x8c
    .word	knPadLeft		;	0x8d
    .word	knPadUp			;	0x8e
    .word	knPadRight		;	0x8f

knReturn:
	CALL	fPRINTSTRING
	.asc	"RETURN"
	.byte	$FF
	RET

knSpace:
	CALL	fPRINTSTRING
	.asc	"SPACE"
	.byte	$FF
	RET

knLShift:
	CALL	fPRINTSTRING
	.asc	"L"
	.byte	$FF
	jr		_shift
knRShift:
	CALL	fPRINTSTRING
	.asc	"R"
	.byte	$FF
_shift:
	CALL	fPRINTSTRING
	.asc	"-SHIFT"
	.byte	$FF
	ret

knFunc:
	CALL	fPRINTSTRING
	.asc	"FUNC"
	.byte	$FF
	RET

knCtrl:
	CALL	fPRINTSTRING
	.asc	"CTRL"
	.byte	$FF
	RET

knUnderscore:
	CALL	fPRINTSTRING
	.asc	"UNDERSCORE"
	.byte	$FF
	RET

knCaret:
	CALL	fPRINTSTRING
	.asc	"CARET"
	.byte	$FF
	RET

knRiSquare:
	CALL	fPRINTSTRING
	.asc	"R SQ. BR."
	.byte	$FF
	RET

knLeSquare:
	CALL	fPRINTSTRING
	.asc	"L SQ. BR."
	.byte	$FF
	RET

knBackSlash:
	CALL	fPRINTSTRING
	.asc	"BACK"
	.byte	$FF
	jr		_slash

knFwdSlash:
	CALL	fPRINTSTRING
	.asc	"FWD"
	.byte	$FF

_slash
	CALL	fPRINTSTRING
	.asc	" SLASH"
	.byte	$FF
	RET

knPadDown:
	CALL	fPRINTSTRING
	.asc	"PAD D"
	.byte	$FF
	RET
knPadLeft:
	CALL	fPRINTSTRING
	.asc	"PAD L"
	.byte	$FF
	RET
knPadUp:
	CALL	fPRINTSTRING
	.asc	"PAD U"
	.byte	$FF
	RET
knPadRight:
	CALL	fPRINTSTRING
	.asc	"PAD R"
	.byte	$FF
	RET
ENDPATCH($87ec, 227)


; GetKey
PATCH($8777, 18)
	LD		E,$30
nextkey:
	CALL	fREADKBROW
	JR		NZ,$878c
	ADD		HL,BC
	INC		E
	BIT		3,E
	JR		Z,nextkey
	xor		a
+:
ENDPATCH($8777, 18)


; SelectKeyboardRow
PATCH($9a40, 1)
	ret
ENDPATCH($9a40, 1)


; ReadKBRow
PATCH($9a49, 7)
fREADKBROW:
	push	bc
	ld		c,e
	in		a,(c)
	pop		bc
ENDPATCH($9a49, 7)


PATCH($9a72, 20)
_nextKey:
	LD  	E,(HL)
	CALL	fREADKBROW
	INC 	HL
	AND 	(HL)
	JR  	Z,{+}
	CCF
+:	RL		C
	INC		HL
	INC		HL
	DJNZ	_nextKey
	call	getJSBits
	ld		a,c
	or		d
ENDPATCH($9a72, 20)


; R.JOY | R.JOY | R.JOY | R.JOY | L.JOY | L.JOY | L.JOY | L.JOY | 37
;   v   |  <--  |   ^   |  -->  |   v   |  <--  |   ^   |  -->  |

PATCH($bde0, 40)
getJSBits:
	ld		d,0
	in		a,($37)
	ld		b,a
	and		%00100010	; ups
	jr		z,{+}

	set		4,d

+:	ld		a,b
	and		%10001000	; downs
	jr		z,{+}

	set		3,d

+:	ld		a,b
	and		%01000100	; lefts
	jr		z,{+}

	set		2,d

+:	ld		a,b
	and		%00010001	; rights
	jr		z,{+}

	set		1,d

+:	in		a,($31)
	and		%00110011
	ret		z

	set		0,d
	ret
ENDPATCH($bde0, 40)

PATCH($802d, 5)
	jp		checkStart
ENDPATCH($802d, 5)

PATCH($be10, 24)
checkStart:
	CP		'S'
	jp		z,$8032
	ld		b,a

	in		a,($31)
	and		%00110011
	jr		z,{+}

-:	call	fGETKEY
	jr		nz,{-}
	jp		$8032

+:	ld		a,b
	JP		$8132
ENDPATCH($be10, 24)
