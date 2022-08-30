@echo off
del /q CHUCKIEPADDED.BIN
copy /B CHUCKIE.BIN + CHUCKIEPAD.BIN CHUCKIEPADDED.BIN
brass keycaptable.asm -l keycaptable.html
brass patch.asm -l patch.html
patcher CHUCKIEPADDED.BIN patch.bin chuckie.patched.bin
brass m5cheg.asm m5cheg.bin -l m5cheg.html
copy /y m5cheg.bin C:\Users\robsonc\gh\mamebuild\roms\m5_cart\cheg\
copy /y m5cheg.bin "C:\Users\robsonc\gh\m5multi\cart-binaries\sirmorris\Chuckie Egg.bin"
del /q CHUCKIEPADDED.BIN
del /q  chuckie.patched.bin
