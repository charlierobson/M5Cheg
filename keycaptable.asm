	.org $87ec

PrintString .equ $9969

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

;   7       6       5       4       3       2       1       0    bit
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
	CALL	PrintString
	.asc	"RETURN"
	.byte	$FF
	RET

knSpace:
	CALL	PrintString
	.asc	"SPACE"
	.byte	$FF
	RET

knLShift:
	CALL	PrintString
	.asc	"L"
	.byte	$FF
	jr		_shift
knRShift:
	CALL	PrintString
	.asc	"R"
	.byte	$FF
_shift:
	CALL	PrintString
	.asc	"-SHIFT"
	.byte	$FF
	ret

knFunc:
	CALL	PrintString
	.asc	"FUNC"
	.byte	$FF
	RET

knCtrl:
	CALL	PrintString
	.asc	"CTRL"
	.byte	$FF
	RET

knUnderscore:
	CALL	PrintString
	.asc	"UNDERSCORE"
	.byte	$FF
	RET

knCaret:
	CALL	PrintString
	.asc	"CARET"
	.byte	$FF
	RET

knRiSquare:
	CALL	PrintString
	.asc	"R SQ. BR."
	.byte	$FF
	RET

knLeSquare:
	CALL	PrintString
	.asc	"L SQ. BR."
	.byte	$FF
	RET

knBackSlash:
	CALL	PrintString
	.asc	"BACK"
	.byte	$FF
	jr		_slash

knFwdSlash:
	CALL	PrintString
	.asc	"FWD"
	.byte	$FF

_slash
	CALL	PrintString
	.asc	" SLASH"
	.byte	$FF
	RET

knPadDown:
	CALL	PrintString
	.asc	"PAD D"
	.byte	$FF
	RET
knPadLeft:
	CALL	PrintString
	.asc	"PAD L"
	.byte	$FF
	RET
knPadUp:
	CALL	PrintString
	.asc	"PAD U"
	.byte	$FF
	RET
knPadRight:
	CALL	PrintString
	.asc	"PAD R"
	.byte	$FF
	RET


patch8d3b:
	push	bc
	ld		a,b
	or		$c0
	ld		b,a
	ld		a,(bc)
	pop		bc
	or		(hl)
	out		($10),a
	ret

.ds		$88cf-$

