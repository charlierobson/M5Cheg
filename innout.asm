
	.word	$9120
	.word	2
	in		a,($10)

	; VDP_DAT

	.word	$82b1
	.word	3
	ld		bc,$0010

	.word	$8b21
	.word	2
	out		($10),a

	.word	$8d55
	.word	2
	out		($10),a

	.word	$8d9b
	.word	2
	out		($10),a

	.word	$8db0
	.word	2
	out		($10),a

	.word	$93b0
	.word	2
	out		($10),a

	.word	$9786
	.word	2
	out		($10),a

	.word	$979a
	.word	2
	out		($10),a

	.word	$993e
	.word	2
	out		($10),a

	.word	$9952
	.word	2
	out		($10),a

	.word	$995f
	.word	2
	out		($10),a

	.word	$99fd
	.word	2
	out		($10),a

	.word	$9a1d
	.word	2
	out		($10),a

	.word	$9d43
	.word	2
	out		($10),a

	; VDP_REG

	.word	$88d1
	.word	2
	out		($11),a

	.word	$88d5
	.word	2
	out		($11),a

	.word	$9d28
	.word	2
	out		($11),a

	.word	$9d2c
	.word	2
	out		($11),a

	.word	$9d51
	.word	2
	out		($11),a

	.word	$9d58
	.word	2
	out		($11),a

	.word	$9d99
	.word	2
	out		($11),a

	.word	$9d9d
	.word	2
	out		($11),a
