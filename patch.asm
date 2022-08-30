	.word	$8000

	.include innout.asm
	.include hstable.asm
	.include sounds.asm

fPRINTSTRING = $9969

	.word	$8021	; don't alter stack
	.word	3
	.ds		3

	.word	$805A
	.word	4
	.asc	"FUNC"

	.word	$806D
	.word	4
	.asc	"FUNC"

	.word	$911d		; stash screen higher up in ram
	.word	3
	ld		hl,$bfff

	; patch access code to move vram/map shadow -> c000

	.word	$8d53
	.word	4
	call	$2100
	nop

	.word	$8d9b
	.word	3
	call	$2110

	.word	$8db0
	.word	3
	call	$2110

	.word	$9785
	.word	3
	call	$2120

	; readkbrow
	.word	$8777
	.word	L8777e-L8777s
L8777s:
	LD		E,$30
nextkeyx:
	CALL	$9a49
	JR		NZ,$+2+$0e
	ADD		HL,BC
	INC		E
	BIT		3,E
	JR		Z,$-9 ; nextkeyx
	LD		A,0
	nop
	nop
L8777e:


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

	; key cap map - see keycaptable.asm
	.word	$8797
	.word	_8797e-_8797s
_8797s:
	.byte	$80,$81,$00,$00,$82,$83,$84,$85
	.byte	'8','7','6','5','4','3','2','1'
	.byte	'I','U','Y','T','R','E','W','Q'
	.byte	'K','J','H','G','F','D','S','A'
	.byte	',','M','N','B','V','C','X','Z'
	.byte	$8a,$86,'/','.',$87,'-','0','9'
	.byte	$88,':',';','L',$89,'@','P','O'
	.byte	$8c,$8d,$8e,$8f,$8c,$8d,$8e,$8f
_8797e:

	.word $87ec
	.word _87ece-_87ecs
_87ecs:
	.incbin keycaptable.bin
_87ece:

	.word $9a40
	.word _9a40e-_9a40s
_9a40s:
	ret
_9a40e:

	.word $9a49
	.word _9a49e-_9a49s
_9a49s:
	push	bc
	ld		c,e
	in		a,(c)
	pop		bc
	nop
	nop
_9a49e:


	.word	$9304
	.word	9
	.asc	"  PLAYER "


	.word	$873a	; hiscore entry, del key
	.word	2
	CP		$8a

	.word	$873e	; hiscore entry, enter key
	.word	2
	CP		$80

	.word	$9a52	; inital key setup
	.word	_9a52e-_9a52s
_9a52s:
;'_esc', ctrl in m5chuk
	.byte	$30,$02,$84 ; can't use func as game key
;_abortMask 'A'
	.byte	$33,$01,$ff	; can't be changed and won't ever be printed (hopefully) so set to something that won't match when redefining
;_helpMask 'H'
	.byte	$33,$20,$ff	; can't be changed and won't ever be printed (hopefully) so set to something that won't match when redefining
;_upMask
	.byte	$32,$01,'Q'
;_downMask
	.byte	$33,$01,'A'
;_leftMask
	.byte	$36,$01,'O'
;_rightMask
	.byte	$36,$02,'P'
;_jumpMask
	.byte	$30,$40,$81
_9a52e:


	; instruction screen, move text up a line
	;
	.word	$8176
	.word	1
	.byte	3

	.word	$819a
	.word	1
	.byte	5

	.word	$81bc
	.word	1
	.byte	7

	.word	$81dd
	.word	1
	.byte	9

	.word	$81ff
	.word	1
	.byte	11

	.word	$8220
	.word	1
	.byte	13

	.word	$8241
	.word	1
	.byte	15

	.word	$8262
	.word	1
	.byte	22

	.word	$8274
	.word	3
	call	$a533 ; add my vandalism


vBONUSPAUSE = $8158
fTITLEMUSIC = $8159
fMUSICABORT = $815a ; last address, add new vars before this

fGETKEY = $876f
fPLAYTITLEMUSIC = $a3a9


	.word	$a413	; patch _playSeg
	.word	3
	call	$bd80

	.word	$bd80
	.word	21
	; skip music patch, CALL from a413
	pop		hl				; ditch return value, returns to PlayIrritatingTune
	ld		a,(fTITLEMUSIC)	; ff if title music, else 0
	ld		b,a
	ld		a,(fMUSICABORT)	; nz if music should be skipped
	and		b
	ret		nz
	push	hl				; return to playseg
	call	fGETKEY
	ld		(fMUSICABORT),a
	ld		a,(ix+0)
	ret
	; 21 bytes


	.word	$801a	; patch playtitlemusic
	.word	3
	call	$bd98

	.word	$bd98
	.word	19
	; setup abort flags and play title music
	xor		a
	ld		(fMUSICABORT),a
	cpl
	ld		(fTITLEMUSIC),a
	call	fPLAYTITLEMUSIC
	xor		a
	ld		(fMUSICABORT),a
	ld		(fTITLEMUSIC),a
	ret


	.word	$8e98	; updateBonus
	.word	9
	call	$bdb0
	.ds		6

	.word	$bdb0
	.word	23
	ld		a,($9f06)
	or		a
	jr		z,{+}
	cp		5
	jr		z,{+}
	pop		hl
	ret
+:	ld		a,(vBONUSPAUSE)		; anything to count down?
	or		a
	ret		z
	dec		a
	ld		(vBONUSPAUSE),a
	pop		hl
	ret


	.word	$812c
	.word	6
	call	$bdc8	; setup
	jp		$9105	; start game

	.word	$bdc8
	.word	5
	xor		a
	ld		(vBONUSPAUSE),a
	ret


	.word	$9727	; check seed pickup
	.word	4
	call	$bdd0
	nop

	.word	$bdd0
	.word	13
	ld		(ix+$21),0
	cp		$0d
	ret		c
	ld		hl,vBONUSPAUSE
	ld		(hl),3
	ret
