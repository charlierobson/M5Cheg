	.word	$8000

	.include innout.asm
	.include hstable.asm
	.include sounds.asm

	; .word	$801a	; kill title tune
	; .word	3
	; nop
	; nop
	; nop


	.word	$8021	; don't alter stack, instead clear 'music aborted' flag
	.word	3
	ld		($815a),a

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


	; instruction screen

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
