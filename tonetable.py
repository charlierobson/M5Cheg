# frequencies roughly mapping to the BBC micro's SOUND values, where 52/4 = middle C (261.63hz)
# see BBC user guide

freqs = [123.47, 130.81, 138.59, 146.83, 155.56, 164.81, 174.61,
		185, 196, 207.65, 220, 233.08, 246.94, 261.63, 277.18,
		293.66, 311.13, 329.63, 349.23, 369.99, 392, 415.3, 440,
		466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.25,
		698.46, 739.99, 783.99, 830.61, 880, 932.33, 987.77, 1046.5]

clock_ntsc = 3579545
clock_pal = 3546893

clock=clock_pal

for freq in freqs:
	val = int((clock/32) / freq)
	# tone value is 10 bits, first byte is low 4 bits and second is upper 6.
	print("   .byte $" + hex(val & 15) + ", $" + hex(val >> 4))
