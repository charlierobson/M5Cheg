	.word	$8000

; patch macros.
; any unspecified bytes at the end of the block will be filled with 0/NOP
;
.define PATCH(x, n)		.relocate x - 4 \ .word x \ .byte n \ .byte (n ^ $ff) \ .endrelocate \ .relocate x
.define ENDPATCH(x, n)	.ds n - ($-x) \ .if ($-x) > n \ .fail "invalid patch, too big: ",($-x)," > ",n \ .endif \ .endrelocate

fPRINTSTRING = $9969

.include innout.asm
.include sounds.asm
.include keycaptable.asm


; don't alter stack. inserts 3 NOPs
PATCH($8021, 3)
ENDPATCH($8021, 3)

; change modifier key for in-game abort/pause
PATCH($805A, 4)
	.asc	"FUNC"
ENDPATCH($805A, 4)

PATCH($806D, 4)
	.asc	"FUNC"
ENDPATCH($806D, 4)

; relocate offscreen map from $0000 -> $c000
PATCH($911d, 3)
	ld		hl,$bfff
ENDPATCH($911d, 3)

PATCH($8d53, 4)
	call	$2100
ENDPATCH($8d53, 4)

PATCH($8d9b, 3)
	call	$2110
ENDPATCH($8d9b, 3)

PATCH($8db0, 3)
	call	$2110
ENDPATCH($8db0, 3)

PATCH($9785, 3)
	call	$2120
ENDPATCH($9785, 3)


PATCH($9304, 9)
	.asc	"  PLAYER "
ENDPATCH($9304, 9)


; hiscore entry, del key
PATCH($873a, 2)
	CP		$8a
ENDPATCH($873a, 2)

; hiscore entry, enter key
PATCH($873e, 2)
	CP		$80
ENDPATCH($873e, 2)

PATCH($9a52, 24)
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
ENDPATCH($9a52, 24)


; instruction screen, move text up a line
PATCH($8176, 1)
	.byte	3
ENDPATCH($8176, 1)

PATCH($819a, 1)
	.byte	5
ENDPATCH($819a, 1)

PATCH($81bc, 1)
	.byte	7
ENDPATCH($81bc, 1)

PATCH($81dd, 1)
	.byte	9
ENDPATCH($81dd, 1)

PATCH($81ff, 1)
	.byte	11
ENDPATCH($81ff, 1)

PATCH($8220, 1)
	.byte	13
ENDPATCH($8220, 1)

PATCH($8241, 1)
	.byte	15
ENDPATCH($8241, 1)

PATCH($8262, 1)
	.byte	22
ENDPATCH($8262, 1)

; add my instruction screen tag
PATCH($8274, 3)
	call	instructionVandalism
ENDPATCH($8274, 3)

; and my hiscore
PATCH($89dc, 16)
	.asc	"CHARLIE   "
	.byte	0,0
	.byte	2,0,2,2
ENDPATCH($89dc, 16)

; version number
PATCH($89f6, 6)
	.byte	0,0
	.byte	1,2,0,0
ENDPATCH($89f6, 6)


vBONUSPAUSE = $8158
fTITLEMUSIC = $8159
fMUSICABORT = $815a ; last address, add new vars before this

fGETKEY = $876f
fPLAYTITLEMUSIC = $a3a9


; patch _playSeg to check abort status
PATCH($a413,3)
	call	testSkipMusic
ENDPATCH($a413,3)

PATCH($bd80, 21)
testSkipMusic:
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
ENDPATCH($bd80, 21)


; setup abort flags and play title music
PATCH($801a, 3)
	call	doPlayTitleMusic
ENDPATCH($801a, 3)

PATCH($bd98, 19)
doPlayTitleMusic:
	xor		a
	ld		(fMUSICABORT),a
	cpl
	ld		(fTITLEMUSIC),a
	call	fPLAYTITLEMUSIC
	xor		a
	ld		(fMUSICABORT),a
	ld		(fTITLEMUSIC),a
	ret
ENDPATCH($bd98, 19)


; pause bonus countdown when seed picked up
PATCH($8e98, 9)
	call	checkBonusPause
ENDPATCH($8e98, 9)

PATCH($bdb0, 23)
checkBonusPause:
	ld		a,($9f06)			; check for bonus countdown when timer unit 0 or 5
	or		a
	jr		z,{+}
	cp		5
	jr		z,{+}
	pop		hl
	ret
+:	ld		a,(vBONUSPAUSE)		; return to count down if flag not set
	or		a
	ret		z
	dec		a
	ld		(vBONUSPAUSE),a
	pop		hl					; otherwise don't return to decrement
	ret
ENDPATCH($bdb0, 23)


; prevent music skip while in game
PATCH($812c, 6)
	call	preGameSetup
	jp		$9105	; start game
ENDPATCH($812c, 6)

PATCH($bdc8, 5)
preGameSetup:
	xor		a
	ld		(vBONUSPAUSE),a
	ret
ENDPATCH($bdc8, 5)


; pause bonus countdown when seed picked up
PATCH($9727, 4)
	call	bonusPauseIfSeedCollected
ENDPATCH($9727, 4)

PATCH($bdd0, 13)
bonusPauseIfSeedCollected:
	ld		(ix+$21),0
	cp		$0d
	ret		c
	ld		hl,vBONUSPAUSE
	ld		(hl),3
	ret
ENDPATCH($bdd0, 13)
