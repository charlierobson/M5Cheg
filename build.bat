@echo off
del /q CHUCKIEPADDED.BIN
copy /B CHUCKIE.BIN + CHUCKIEPAD.BIN CHUCKIEPADDED.BIN

brass keycaptable.asm -l keycaptable.html
del /q patch.bin
brass patch.asm -e -l patch.html

patcher CHUCKIEPADDED.BIN patch.bin chuckie.patched.bin
if ERRORLEVEL 1 exit /b

del /q m5cheg.bin
brass m5cheg.asm m5cheg.bin -e -l m5cheg.html

copy /y m5cheg.bin C:\Users\robsonc\gh\mamebuild\roms\m5_cart\cheg\
copy /y m5cheg.bin "C:\Users\robsonc\gh\m5multi\cart-binaries\sirmorris\Chuckie Egg.bin"
del /q CHUCKIEPADDED.BIN
rem del /q  chuckie.patched.bin
