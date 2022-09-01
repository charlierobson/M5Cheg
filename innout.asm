	; VDP_DAT

PATCH($9120, 2)
	in		a,($10)
ENDPATCH($9120, 2)

PATCH($82b1, 3)
	ld		bc,$0010
ENDPATCH($82b1, 3)

PATCH($8b21, 2)
	out		($10),a
ENDPATCH($8b21, 2)

PATCH($8d55, 2)
	out		($10),a
ENDPATCH($8d55, 2)

PATCH($8d9b, 2)
	out		($10),a
ENDPATCH($8d9b, 2)

PATCH($8db0, 2)
	out		($10),a
ENDPATCH($8db0, 2)

PATCH($93b0, 2)
	out		($10),a
ENDPATCH($93b0, 2)

PATCH($9786, 2)
	out		($10),a
ENDPATCH($9786, 2)

PATCH($979a, 2)
	out		($10),a
ENDPATCH($979a, 2)

PATCH($993e, 2)
	out		($10),a
ENDPATCH($993e, 2)

PATCH($9952, 2)
	out		($10),a
ENDPATCH($9952, 2)

PATCH($995f, 2)
	out		($10),a
ENDPATCH($995f, 2)

PATCH($99fd, 2)
	out		($10),a
ENDPATCH($99fd, 2)

PATCH($9a1d, 2)
	out		($10),a
ENDPATCH($9a1d, 2)

PATCH($9d43, 2)
	out		($10),a
ENDPATCH($9d43, 2)

	; VDP_REG

PATCH($88d1, 2)
	out		($11),a
ENDPATCH($88d1, 2)

PATCH($88d5, 2)
	out		($11),a
ENDPATCH($88d5, 2)

PATCH($9d28, 2)
	out		($11),a
ENDPATCH($9d28, 2)

PATCH($9d2c, 2)
	out		($11),a
ENDPATCH($9d2c, 2)

PATCH($9d51, 2)
	out		($11),a
ENDPATCH($9d51, 2)

PATCH($9d58, 2)
	out		($11),a
ENDPATCH($9d58, 2)

PATCH($9d99, 2)
	out		($11),a
ENDPATCH($9d99, 2)

PATCH($9d9d, 2)
	out		($11),a
ENDPATCH($9d9d, 2)
