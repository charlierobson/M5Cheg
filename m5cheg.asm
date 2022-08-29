    .org $2000

    .asciimap ' ',' ',0

    .db     0           ; identifier
    .dw     start       ; start execution address
    .dw     ipl         ; IPL address
    .db     0,0,0       ; RST 4 jump
    .db     0,0,0       ; RST 5 jump

start:
    di                          ; DO NOT CHANGE THIS
    .ds     $2030-$200c         ;

    ld      a,$01               ; disable timer interrupts
    out     ($01),a

    ld      a,$9f               ; silence the SN
    out     ($20),a
    ld      a,$bf
    out     ($20),a
    ld      a,$df
    out     ($20),a
    ld      a,$ff
    out     ($20),a

    ld      sp,$7fff

    ld      hl,vbl
    ld      ($7006),hl

	ld		hl,chuk
	ld		de,$8000
	ld		bc,15800
	ldir

	ld		hl,regs
	ld		de,$7f00
	push	de
	ld		bc,16
	ldir

    ld      a,($1518)       ; use a difference in ROM to determine if JAP or EUR machine
    and     1         		; PAL has E1 here, ntsc E0

	pop		hl				; set bit 1 of reg 0 if PAL machine
	or		(hl)
	ld		(hl),a

	ld		bc,$1011
	otir

	ld		hl,$8000
	push	hl
	reti

ipl:
    ret

regs:
	.byte	$02,$80
	.byte	$c1,$81
	.byte	$0e,$82
	.byte	$ff,$83
	.byte	$03,$84
	.byte	$76,$85
	.byte	$03,$86
	.byte	$f4,$87

VDP_STAT    .equ $11    ; read

vbl:
    exx
    push    af
    in      a,(VDP_STAT)
    pop     af
    exx
    ei
    reti

	.align	128
patch8d53:
	push	bc
	ld		a,b
	or		$c0
	ld		b,a
	ld		a,(bc)
	pop		bc
	or		(hl)
	out		($10),a
	ret

	.align	16
patch8d9b:
	out		($10),a
	set		7,b
	set		6,b
	ld		(bc),a
	res		7,b
	res		6,b
	ret

	.align	16
patch9785:
	out		($10),a
	set		7,h
	set		6,h
	ld		(hl),a
	res		7,h
	res		6,h
	ret


chuk:
	.incbin	chuckie.patched.bin

	.ds 16384 - ($-$2000)
