; ***********************************************************************
; **                                                                   **
; **                     C H U C K I E     E G G                       **
; **                       (BBC Micro version)                         **
; **                                                                   **
; **                 by Doug Anderson for A&F Software                 **
; **                                                                   **
; **                       BeebAsm source file                         **
; **                     by  Rich Talbot-Watkins                       **
; **                                                                   **
; ***********************************************************************


;---------------------------------------------------------------------------------------------------
; Define zero page locations

ORG 0

.intervaltimerblock		SKIP 5

SKIP &16	; *** wasted

.savesp					SKIP 1		; used by title page to preserve stack pointer
.stalltime				SKIP 1		; counter which stalls time countdown when seed is collected
.time					SKIP 3		; time remaining
.lives					SKIP 4		; lives per-player
.playerlevel			SKIP 4		; level per-player
.score					SKIP 8		; score of current player

.bigbirdxpos			SKIP 1		; x position of big bird
.bigbirdypos			SKIP 1		; y position of big bird
.bigbirdxspeed			SKIP 1		; x velocity of big bird
.bigbirdyspeed			SKIP 1		; y velocity of big bird
.bigbirdanim			SKIP 1		; animation frame of big bird
.bigbirdflag			SKIP 1		; indicates whether big bird is active or not
.currentbirdindex		SKIP 1		; which walking bird is being processed
.birdwalkingspeed		SKIP 1		; update rate of walking birds
.updatetimer			SKIP 1		; timer which counts frames between successive updates
.numeggsleft			SKIP 1		; number of eggs left for current player
.bonus					SKIP 3		; bonus for current player
.bonusexpiredflag		SKIP 1		; whether bonus has reached zero
.extralifeflag			SKIP 1		; whether an extra life should be awarded
.currentscorexpos		SKIP 1		; xpos of score digits for current player

.playerx				SKIP 1		; current player x pixel position
.playery				SKIP 1		; current player y pixel position
.playercharx			SKIP 1		; current player x character block position
.playerchary			SKIP 1		; current player y character block position
.playerfracx			SKIP 1		; current player x fractional position within character block
.playerfracy			SKIP 1		; current player y fractional position within character block
.movementx				SKIP 1		; player requested movement x
.movementy				SKIP 1		; player requested movement y
.playerspritenum		SKIP 1		; current player anim frame
.movementtype			SKIP 1		; current player movement type
.jumpfalldist			SKIP 1		; counter used for jumping / falling
.jumpdir				SKIP 1		; player jump direction
.playerfacingdir		SKIP 1		; player facing direction
.difficulty				SKIP 1		; level difficulty
.playerdataoffset		SKIP 1		; offset to current player's stored data
.playerdieflag			SKIP 1		; whether the player should die

.level					SKIP 1		; level number (not the same as screen number; this can be greater than 8)
.mapdataptr				SKIP 2		; pointer to the current screen data
.numplatforms			SKIP 1		; number of platforms on the current screen
.numladders				SKIP 1		; number of ladders on the current screen
.liftflag				SKIP 1		; whether there is a lift on the current screen
.numseeds				SKIP 1		; number of seeds on the current screen
.numbirds				SKIP 1		; number of birds on the current screen
.liftx					SKIP 1		; lift x position
.lift1y					SKIP 1		; lift 1 y position
.lift2y					SKIP 1		; lift 2 y position
.whichlift				SKIP 1		; which lift we are processing (0 or 1)
.screen					SKIP 1		; screen number (strictly between 0-7)
.playernum				SKIP 1		; which player is active
.numplayers				SKIP 1		; number of players
.numaliveplayers		SKIP 1		; number of players still alive

.keys					SKIP 1		; bitfield of all control keys pressed
.keynum_right			SKIP 1		; key code for right key
.keynum_left			SKIP 1		; key code for left key
.keynum_down			SKIP 1		; key code for down key
.keynum_up				SKIP 1		; key code for up key
.keynum_jump			SKIP 1		; key code for jump key

.rndseed				SKIP 4		; random number generator seed

SKIP 6		; *** wasted

.write					SKIP 2		; sprite screen address
string = write						; (also used as string read pointer)
.spriteline				SKIP 1		; screen line of sprite
.spritecolumn			SKIP 1		; which column to plot sprite at within a MODE 2 byte (0 or 1)
.spritetemp				SKIP 1		; temp sprite workspace
.stringlength			SKIP 1		; length of string to be printed
.read					SKIP 2		; sprite data read address
.spriteheight			SKIP 1		; height of sprite in pixels
.spritewidthpixels		SKIP 1		; width of sprite in pixels
.spritewidth			SKIP 1		; width of sprite in 8 pixel chunks

SKIP 4		; *** wasted

.spritecolour			SKIP 1		; colour of sprite

.keybit					SKIP 1		; value which will be added to keys bitfield for the next key checked
.columncounter			SKIP 1		; counter for pixel columns within a screen byte in the sprite routine
.pixelvalue				SKIP 1		; next value which will be EORed to screen to light a pixel in the sprite routine
.pixelbitcounter		SKIP 1		; counts 8 pixels in the sprite data
.spritebyte				SKIP 1		; current byte of sprite data being processed

SKIP 2		; *** wasted

.widthcounter			SKIP 1		; counter for the sprite width in the sprite routine

.temp1					SKIP 1		; all temporary miscellaneous workspace used throughout the game
.temp2					SKIP 1
.temp3					SKIP 1
.temp4					SKIP 1
.temp5					SKIP 1
.temp6					SKIP 1
.temp7					SKIP 1


;---------------------------------------------------------------------------------------------------
; These are used by the key defining code

keycounter = keys
disallowedkeytab = score
keytranstab = read
internalkeynum = temp1
inkeynum = temp2
keyrownum = temp4
keycolumnnum = temp5
numrowclashes = temp6
numcolumnclashes = temp7


;---------------------------------------------------------------------------------------------------
; Walking bird variables

birddata = &400
ORG birddata

.birdpixelx				SKIP 5		; pixel position x of bird
.birdpixely				SKIP 5		; pixel position y of bird
.birdcharx				SKIP 5		; corresponding character block x position
.birdchary				SKIP 5		; corresponding character block y position
.birdstatus				SKIP 5		; status of bird (walking, climbing, eating seed...)
.birdanim				SKIP 5		; animation frame of bird
.birddir				SKIP 5		; facing direction of bird


;---------------------------------------------------------------------------------------------------
; Used by the high score code

hiscoreaddr = read
hiscoretemp = bigbirdxpos	; 16 bytes
hiscoretab = &430


;---------------------------------------------------------------------------------------------------
; Player variables
; These repeat at offsets of 0, 64, 128 and 192 for each player

playerdata = &500
ORG playerdata

; data for one player
.playerscore			SKIP 8
.playerbonus			SKIP 3
.playerbonusexpiredflag	SKIP 1
SKIP 4		; *** wasted
.collectedeggsflags		SKIP 12
SKIP 4		; *** wasted
.collectedseedflags		SKIP 16
SKIP 16		; *** wasted

playerdatalength = P% - playerdata


;---------------------------------------------------------------------------------------------------
; Map data

mapdata = &600

MapId_Platform = 1
MapId_Ladder = 2
MapId_Egg = 4
MapId_Seed = 8

IF LO(mapdata)<>0
	ERROR "mapdata must be page aligned"
ENDIF


;---------------------------------------------------------------------------------------------------
; Colour values

Colour0 = 0						; Black
Colour1 = 2						; Yellow
Colour2 = 8						; Magenta
Colour3 = Colour1 + Colour2		; Green
Colour4 = 32					; Yellow
Colour5 = Colour4 + Colour1		; Yellow
Colour6 = Colour4 + Colour2		; Yellow
Colour7 = Colour4 + Colour3		; Yellow
Colour8 = 128					; Cyan
Colour9 = Colour8 + Colour1		; Cyan
Colour10 = Colour8 + Colour2	; Cyan
Colour11 = Colour8 + Colour3	; Cyan
Colour12 = Colour8 + Colour4	; Cyan
Colour13 = Colour8 + Colour5	; Cyan
Colour14 = Colour8 + Colour6	; Cyan
Colour15 = Colour8 + Colour7	; Cyan

EggColour = Colour1
LiftColour = Colour1
LadderColour = Colour2
SeedColour = Colour2
PlatformColour = Colour3
CageColour = Colour4
PlayerColour = Colour4
BigBirdColour = Colour4
BirdColour = Colour8

LogoColour = Colour1
DigitsColour = Colour2
StatusColour = Colour2
LivesColour = Colour4



;---------------------------------------------------------------------------------------------------
; OS entry points

oswrch = &FFEE
osword = &FFF1
osbyte = &FFF4



;---------------------------------------------------------------------------------------------------
; The part of the code which lives in low memory

ORG &900
.codelow_start

;----------------------------------------------------------------------------------
;	Show the currently defined keys on screen
;----------------------------------------------------------------------------------

.showkeys

	JMP showkeys_core   	; show the user defined keys....

	
;----------------------------------------------------------------------------------
;	Let the player select their preferred keys
;----------------------------------------------------------------------------------

.choosekeys

	; Print "KEY SELECTION" string
	LDX #LO(string_keyselection)
	LDY #HI(string_keyselection)
	JSR printstring

	; Read address of keyboard translation table and store in (&76)
	LDA #&AC
	LDX #0
	LDY #255
	JSR osbyte
	STX keytranstab
	STY keytranstab+1
	
	; Make note of how many keys have so far been defined
	LDA #0:STA keycounter
	
	LDA #&54:STA disallowedkeytab		; Internal code for 'H'; disallow 'H' as a control key
	
	; Handle up key
	LDX #LO(string_up)
	LDY #HI(string_up)
	JSR printstring
	JSR waitforkey
	STA keynum_up
	
	; Handle down key
	LDX #LO(string_down)
	LDY #HI(string_down)
	JSR printstring
	JSR waitforkey
	STA keynum_down
	
	; Handle left key
	LDX #LO(string_left)
	LDY #HI(string_left)
	JSR printstring
	JSR waitforkey
	STA keynum_left

	; Handle right key
	LDX #LO(string_right)
	LDY #HI(string_right)
	JSR printstring
	JSR waitforkey
	STA keynum_right

	; Handle jump key
	LDX #LO(string_jump)
	LDY #HI(string_jump)
	JSR printstring
	JSR waitforkey
	STA keynum_jump
	RTS


;----------------------------------------------------------------------------------
;	Wait for the player to press a key that hasn't yet been chosen,
;	and print its name
;----------------------------------------------------------------------------------

.waitforkey

	; Explicit check for Shift
	LDA #&79
	LDX #&80
	JSR osbyte
	TXA
	BPL didntpressshift
	LDX #0
	JMP gotakey
	.didntpressshift
	
	; Explicit check for Ctrl
	LDA #&79
	LDX #&81
	JSR osbyte
	TXA
	BPL didntpressctrl
	LDX #1
	JMP gotakey
	.didntpressctrl
	
	; Keyboard scan
	LDA #&7A
	JSR osbyte
	CPX #&FF
	BEQ waitforkey
	
	; Now we have a key number in X
	.gotakey
	STX internalkeynum
	TXA:EOR #&FF:STA inkeynum		; make inkey code from internal key number
	LDY keycounter					; number of keys already chosen
	TXA:AND #&0F:STA keyrownum		; keyboard row
	TXA:AND #&F0:STA keycolumnnum	; keyboard column
	LDA #0
	STA numrowclashes				; number of row clashes
	STA numcolumnclashes			; number of column clashes

	.checkkeyclashes
	TXA
	CMP disallowedkeytab,Y
	BEQ waitforkey

	LDA disallowedkeytab,Y
	AND #&0F
	CMP keyrownum
	BNE notsamerow
	INC numrowclashes
	.notsamerow
	
	LDA disallowedkeytab,Y
	AND #&F0
	CMP keycolumnnum
	BNE notsamecolumn
	INC numcolumnclashes
	.notsamecolumn
	
	DEY
	BPL checkkeyclashes
	
	LDA numrowclashes
	BEQ keyok					; no row clashes
	LDA numcolumnclashes
	BEQ keyok					; no column clashes
	
	; Beep to indicate key clash
	LDA #&D6
	LDX #&01
	LDY #&00
	JSR osbyte					; set beep duration to 1
	LDA #7
	JSR oswrch
	JMP waitforkey

	; We have a valid key
	.keyok
	INC keycounter
	LDY keycounter
	TXA
	STA disallowedkeytab,Y

	
.printkeyname_core
	
	CPX #2
	BCS notshiftorctrl
	CPX #0
	BNE notshift
	
	; key is shift
	LDX #LO(string_shift)
	LDY #HI(string_shift)
	JMP printstringandreturninkey
	
	; key is ctrl
	.notshift
	LDX #LO(string_control)
	LDY #HI(string_control)
	JMP printstringandreturninkey
	
	; key is one other than shift or ctrl
	.notshiftorctrl
	LDY internalkeynum								; internal key number
	LDA (keytranstab),Y
	CMP #33:BCC keywithspecialname
	CMP #127:BCS keywithspecialname
	
	; normal key; just print its name here
	PHA
	LDA #''':JSR oswrch
	PLA
	JSR oswrch
	LDA #''':JSR oswrch
	JMP returninkey
	
	; special key; print its long name here
	.keywithspecialname
	CMP #0
	BNE nottab
	LDX #LO(string_tab)
	LDY #HI(string_tab)
	JMP printstringandreturninkey
	.nottab

	CMP #1
	BNE notcapslock
	LDX #LO(string_capslock)
	LDY #HI(string_capslock)
	JMP printstringandreturninkey
	.notcapslock

	CMP #2
	BNE notshiftlock
	LDX #LO(string_shiftlock)
	LDY #HI(string_shiftlock)
	JMP printstringandreturninkey
	.notshiftlock

	CMP #27
	BNE notescape
	LDX #LO(string_escape)
	LDY #HI(string_escape)
	JMP printstringandreturninkey
	.notescape

	CMP #32
	BNE notspace
	LDX #LO(string_space)
	LDY #HI(string_space)
	JMP printstringandreturninkey
	.notspace
	
	CMP #127
	BNE notdelete
	LDX #LO(string_delete)
	LDY #HI(string_delete)
	JMP printstringandreturninkey
	.notdelete
	
	CMP #13
	BNE notreturn
	LDX #LO(string_return)
	LDY #HI(string_return)
	JMP printstringandreturninkey
	.notreturn
	
	CMP #&8B
	BNE notcopy
	LDX #LO(string_copy)
	LDY #HI(string_copy)
	JMP printstringandreturninkey
	.notcopy
	
	CMP #&8C
	BNE notleftarrow
	LDX #LO(string_leftarrow)
	LDY #HI(string_leftarrow)
	JMP printstringandreturninkey
	.notleftarrow
	
	CMP #&8D
	BNE notrightarrow
	LDX #LO(string_rightarrow)
	LDY #HI(string_rightarrow)
	JMP printstringandreturninkey
	.notrightarrow
	
	CMP #&8E
	BNE notdownarrow
	LDX #LO(string_downarrow)
	LDY #HI(string_downarrow)
	JMP printstringandreturninkey
	.notdownarrow

	CMP #&8F
	BNE notuparrow
	LDX #LO(string_uparrow)
	LDY #HI(string_uparrow)
	JMP printstringandreturninkey
	.notuparrow
	
	; check if it's an f-key
	CMP #&80:BCC returninkey
	CMP #&8A:BCS returninkey
	
	; print f-key
	PHA
	LDA #'f':JSR oswrch
	PLA
	SEC
	SBC #&50
	JSR oswrch
	JMP returninkey
	
	
.printstringandreturninkey
	JSR printstring
	
.returninkey
	LDA inkeynum					; inkey code
	RTS


;----------------------------------------------------------------------------------
;	Key-related strings
;----------------------------------------------------------------------------------

.string_keyselection
	EQUB string_keyselection_end - string_keyselection_start
.string_keyselection_start
	EQUB 16						; CLG
	EQUB 18, 0, 4				; GCOL 0,4
	EQUB 25, 4					; MOVE ...
	EQUW 480, 950				; MOVE 480,950
	EQUS "K E Y"
	EQUB 25, 4					; MOVE ...
	EQUW 96, 850				; MOVE 96,850
	EQUS "S E L E C T I O N"
	EQUB 18, 0, 2				; GCOL 0,2
.string_keyselection_end


.string_up
	EQUB string_up_end - string_up_start
.string_up_start
	EQUB 25, 4					; MOVE ...
	EQUW 196, 700				; MOVE 196,700
	EQUS "Up .. "
.string_up_end


.string_down
	EQUB string_down_end - string_down_start
.string_down_start
	EQUB 25, 4					; MOVE ...
	EQUW 64, 620				; MOVE 64,620
	EQUS "Down .. "
.string_down_end


.string_left
	EQUB string_left_end - string_left_start
.string_left_start
	EQUB 25, 4					; MOVE ...
	EQUW 64, 540				; MOVE 64, 540
	EQUS "Left .. "
.string_left_end


.string_right
	EQUB string_right_end - string_right_start
.string_right_start
	EQUB 25, 4					; MOVE ...
	EQUW 0, 460					; MOVE 0, 460
	EQUS "Right .. "
.string_right_end


.string_jump
	EQUB string_jump_end - string_jump_start
.string_jump_start
	EQUB 25, 4					; MOVE ...
	EQUW 64, 380				; MOVE 64, 380
	EQUS "Jump .. "
.string_jump_end


.string_tab				EQUS 3, "Tab"
.string_capslock		EQUB 9, "Caps Lock"
.string_shiftlock		EQUB 10, "Shift Lock"
.string_escape			EQUB 6, "Escape"
.string_space			EQUB 5, "Space"
.string_delete			EQUS 6, "Delete"
.string_return			EQUS 6, "Return"
.string_copy			EQUS 4, "Copy"
.string_leftarrow		EQUS 10, "Left Arrow"
.string_rightarrow		EQUS 11, "Right Arrow"
.string_downarrow		EQUS 10, "Down Arrow"
.string_uparrow			EQUS 8, "Up Arrow"
.string_shift			EQUS 5, "Shift"
.string_control			EQUS 7, "Control"



;----------------------------------------------------------------------------------
;	Show the currently defined keys on screen
;----------------------------------------------------------------------------------

.showkeys_core

	; Print string "KEYS"
	LDX #LO(string_keys)
	LDY #HI(string_keys)
	JSR printstring
	
	; Read keyboard translation table address
	LDA #&AC
	LDX #0
	LDY #255
	JSR osbyte
	STX keytranstab
	STY keytranstab+1
	
	; Display up key
	LDX #LO(string_up)
	LDY #HI(string_up)
	JSR printstring
	LDA keynum_up
	JSR printkeyname

	; Display down key
	LDX #LO(string_down)
	LDY #HI(string_down)
	JSR printstring
	LDA keynum_down
	JSR printkeyname

	; Display left key
	LDX #LO(string_left)
	LDY #HI(string_left)
	JSR printstring
	LDA keynum_left
	JSR printkeyname

	; Display right key
	LDX #LO(string_right)
	LDY #HI(string_right)
	JSR printstring
	LDA keynum_right
	JSR printkeyname

	; Display jump key
	LDX #LO(string_jump)
	LDY #HI(string_jump)
	JSR printstring
	LDA keynum_jump
	JSR printkeyname
	
	; Display hold and abort text
	LDX #LO(string_holdabort)
	LDY #HI(string_holdabort)
	JSR printstring
	RTS
	

;----------------------------------------------------------------------------------
;	Print the name of the key whose INKEY code is in A
;----------------------------------------------------------------------------------

.printkeyname

	EOR #&FF
	TAX
	STA internalkeynum
	JMP printkeyname_core
	

;----------------------------------------------------------------------------------
;	Other key-related strings
;----------------------------------------------------------------------------------

.string_keys
	EQUB string_keys_end - string_keys_start
.string_keys_start
	EQUB 25, 4					; MOVE ...
	EQUW 512, 800				; MOVE 512,800
	EQUB 18, 0, 4				; GCOL 0,4
	EQUS "KEYS"
	EQUB 18, 0, 8				; GCOL 0,8
.string_keys_end


.string_holdabort
	EQUB string_holdabort_end - string_holdabort_start
.string_holdabort_start
	EQUB 18, 0, 2				; GCOL 0,2
	EQUB 25, 4					; MOVE ...
	EQUW 64, 280				; MOVE 64,280
	EQUS "Hold .. ", 39, "H", 39
	EQUB 25, 4					; MOVE ...
	EQUW 0, 200					; MOVE 0,200
	EQUS "Abort .. Escape +", 39, "H", 39
.string_holdabort_end




;----------------------------------------------------------------------------------
;	Make movement sounds
;----------------------------------------------------------------------------------

.domovementsound

	; See if we're moving
	LDA movementx
	ORA movementy
	BNE ismoving
	RTS
	.ismoving
	
	; Only do it every other frame
	LDA updatetimer
	AND #1
	BEQ domovementsound2
	RTS
	.domovementsound2
	
	; Get movement type
	LDA movementtype
	BNE notmovinghorizontally
	
	; Moving horizontally (along a platform)
	
	LDA #100
	JMP playsoundblip

	.notmovinghorizontally
	CMP #1
	BNE notmovingvertically

	; Moving vertically (on a ladder)
	
	LDA #150
	JMP playsoundblip
	
	.notmovingvertically
	CMP #2
	BNE notjumpingsound
	
	; Jumping
	
	LDA jumpfalldist
	CMP #&0B
	BCC jumpingupsound

	; do jump falling sound
	LDA #&BE
	SEC
	SBC jumpfalldist
	SBC jumpfalldist
	JMP playsoundblip

	; do jump rising sound
	.jumpingupsound
	LDA #&96
	CLC
	ADC jumpfalldist
	ADC jumpfalldist
	JMP playsoundblip
	
	.notjumpingsound
	CMP #&03
	BNE notfallingsound
	
	; Falling
	
	LDA #&6E
	SEC
	SBC jumpfalldist
	SBC jumpfalldist
	JMP playsoundblip

	.notfallingsound
	; If we got here, we are on a lift - only make a sound if we're moving horizontally
	LDA movementx
	BNE movingonlift
	RTS

	.movingonlift
	LDA #100

;----------------------------------------------------------------------------------
;	Play sound blip (movement sounds)
;	A = pitch to play
;----------------------------------------------------------------------------------

.playsoundblip

	STA blipsoundblock+4
	LDX #LO(blipsoundblock)
	LDY #HI(blipsoundblock)
	LDA #7
	JSR osword
	RTS
	
.blipsoundblock
	EQUW &13			; channel
	EQUW 1				; envelope
	EQUW 0				; pitch (self-modified)
	EQUW 1				; length
	
.deathsoundblock
	EQUW 3
	EQUW 2
	EQUW 120
	EQUW 30
	
.eggsoundblock
	EQUW &10
	EQUW 3
	EQUW 0
	EQUW 4
	
.bonussoundblock
	EQUW &10
	EQUW 1
	EQUW 4
	EQUW 1
	
.SPARE
	SKIP 8



;----------------------------------------------------------------------------------
;	Map data pointers
;----------------------------------------------------------------------------------

.mapptrs
	EQUW map0data
	EQUW map1data
	EQUW map2data
	EQUW map3data
	EQUW map4data
	EQUW map5data
	EQUW map6data
	EQUW map7data

	

;----------------------------------------------------------------------------------
;	Map 0 data
;----------------------------------------------------------------------------------

.map0data
	
	EQUB (map0platform_end - map0platform_start) / 3	; number of platforms
	EQUB (map0ladder_end - map0ladder_start) / 3		; number of ladders
	EQUB 0												; has lifts flag
	EQUB (map0seed_end - map0seed_start) / 2			; number of seeds
	EQUB 2												; initial number of birds
	
	; Platform data (Y, startX, endX)
	
	.map0platform_start
	EQUB 1, 0, 19
	EQUB 6, 1, 18
	EQUB 11, 2, 8
	EQUB 11, 14, 18
	EQUB 12, 9, 10
	EQUB 13, 11, 12
	EQUB 14, 13, 14
	EQUB 15, 15, 16
	EQUB 16, 3, 7
	EQUB 17, 9, 11
	EQUB 21, 5, 9
	EQUB 21, 11, 16
	EQUB 21, 18, 19
	.map0platform_end

	; Ladder data (X, bottom Y, top Y)
	
	.map0ladder_start
	EQUB 3, 7, 13
	EQUB 7, 2, 23
	EQUB 11, 2, 8
	EQUB 16, 2, 8
	.map0ladder_end

	; No lift
	
	; Data for 12 eggs (X, Y)

	EQUB 4, 2
	EQUB 1, 7
	EQUB 13, 7
	EQUB 18, 7
	EQUB 2, 12
	EQUB 10, 13
	EQUB 17, 12
	EQUB 4, 17
	EQUB 10, 18
	EQUB 6, 22
	EQUB 13, 22
	EQUB 19, 22
	
	; Seed data (X, Y)
	
	.map0seed_start
	EQUB 2, 2
	EQUB 13, 2
	EQUB 5, 7
	EQUB 14, 7
	EQUB 5, 12
	EQUB 15, 12
	EQUB 16, 16
	EQUB 11, 18
	EQUB 9, 22
	EQUB 14, 22
	.map0seed_end

	; Bird data (X, Y)
	
	EQUB 5, 17
	EQUB 8, 22
	EQUB 4, 12
	EQUB 6, 7
	EQUB 12, 2

	
;----------------------------------------------------------------------------------
;	Map 1 data
;----------------------------------------------------------------------------------

.map1data
	
	EQUB (map1platform_end - map1platform_start) / 3	; number of platforms
	EQUB (map1ladder_end - map1ladder_start) / 3		; number of ladders
	EQUB 0												; has lifts flag
	EQUB (map1seed_end - map1seed_start) / 2			; number of seeds
	EQUB 3												; initial number of birds
	
	; Platform data (Y, startX, endX)
	
	.map1platform_start
	EQUB 1, 0, 3
	EQUB 1, 5, 19
	EQUB 6, 0, 6
	EQUB 6, 8, 10
	EQUB 6, 12, 14
	EQUB 6, 16, 19
	EQUB 11, 0, 3
	EQUB 11, 5, 14
	EQUB 11, 16, 19
	EQUB 16, 0, 10
	EQUB 16, 12, 19
	EQUB 21, 4, 10
	EQUB 21, 12, 19
	.map1platform_end

	; Ladder data (X, bottom Y, top Y)
	
	.map1ladder_start
	EQUB 2, 2, 18
	EQUB 4, 17, 23
	EQUB 6, 7, 18
	EQUB 9, 2, 8
	EQUB 9, 12, 23
	EQUB 13, 12, 18
	EQUB 17, 2, 13
	EQUB 17, 17, 23
	.map1ladder_end

	; No lift
	
	; Data for 12 eggs (X, Y)

	EQUB 5, 2
	EQUB 12, 2
	EQUB 0, 7
	EQUB 4, 7
	EQUB 13, 7
	EQUB 0, 12
	EQUB 7, 12
	EQUB 19, 12
	EQUB 7, 17
	EQUB 7, 22
	EQUB 15, 22
	EQUB 19, 22
	
	; Seed data (X, Y)
	
	.map1seed_start
	EQUB 0, 2
	EQUB 3, 2
	EQUB 15, 2
	EQUB 16, 7
	EQUB 0, 17
	EQUB 10, 17
	EQUB 12, 22
	.map1seed_end

	; Bird data (X, Y)
	
	EQUB 6, 22
	EQUB 1, 2
	EQUB 18, 12
	EQUB 11, 12
	EQUB 13, 22


	
;----------------------------------------------------------------------------------
;	Map 2 data
;----------------------------------------------------------------------------------

.map2data
	
	EQUB (map2platform_end - map2platform_start) / 3	; number of platforms
	EQUB (map2ladder_end - map2ladder_start) / 3		; number of ladders
	EQUB 1												; has lifts flag
	EQUB (map2seed_end - map2seed_start) / 2			; number of seeds
	EQUB 3												; initial number of birds
	
	; Platform data (Y, startX, endX)
	
	.map2platform_start
	EQUB 1, 0, 2
	EQUB 2, 3, 4
	EQUB 1, 7, 9
	EQUB 1, 11, 19
	EQUB 5, 15, 18
	EQUB 10, 0, 4
	EQUB 15, 0, 3
	EQUB 19, 3, 4
	EQUB 6, 7, 10
	EQUB 6, 12, 12
	EQUB 7, 14, 14
	EQUB 8, 15, 15
	EQUB 9, 17, 17
	EQUB 10, 18, 19
	EQUB 12, 12, 13
	EQUB 12, 15, 15
	EQUB 15, 18, 19
	EQUB 16, 17, 17
	EQUB 17, 15, 15
	EQUB 18, 12, 13
	EQUB 19, 7, 11
	EQUB 21, 13, 15
	EQUB 20, 16, 16
	EQUB 20, 18, 19
	.map2platform_end

	; Ladder data (X, bottom Y, top Y)
	
	.map2ladder_start
	EQUB 1, 2, 12
	EQUB 3, 11, 21
	EQUB 8, 7, 21
	EQUB 10, 7, 21
	EQUB 13, 19, 23
	EQUB 18, 2, 7
	EQUB 19, 11, 17
	.map2ladder_end

	; Lift X
	
	EQUB 5
	
	; Data for 12 eggs (X, Y)

	EQUB 4, 3
	EQUB 15, 2
	EQUB 16, 6
	EQUB 4, 11
	EQUB 4, 20
	EQUB 9, 7
	EQUB 15, 9
	EQUB 15, 13
	EQUB 1, 16
	EQUB 17, 17
	EQUB 19, 18
	EQUB 19, 21
	
	; Seed data (X, Y)
	
	.map2seed_start
	EQUB 2, 2
	EQUB 2, 11
	EQUB 7, 7
	EQUB 7, 20
	EQUB 0, 16
	EQUB 13, 2
	EQUB 12, 19
	EQUB 15, 18
	EQUB 13, 13
	EQUB 18, 21
	.map2seed_end

	; Bird data (X, Y)

	EQUB 2, 16
	EQUB 9, 20
	EQUB 17, 6
	EQUB 0, 2
	EQUB 8, 7



;----------------------------------------------------------------------------------
;	Map 3 data
;----------------------------------------------------------------------------------

.map3data
	
	EQUB (map3platform_end - map3platform_start) / 3	; number of platforms
	EQUB (map3ladder_end - map3ladder_start) / 3		; number of ladders
	EQUB 1												; has lifts flag
	EQUB (map3seed_end - map3seed_start) / 2			; number of seeds
	EQUB 4												; initial number of birds
	
	; Platform data (Y, startX, endX)
	
	.map3platform_start
	EQUB 1, 0, 4
	EQUB 1, 6, 10
	EQUB 1, 13, 19
	EQUB 6, 0, 4
	EQUB 6, 7, 10
	EQUB 6, 13, 17
	EQUB 5, 19, 19
	EQUB 12, 0, 1
	EQUB 13, 3, 3
	EQUB 14, 5, 5
	EQUB 15, 7, 8
	EQUB 11, 7, 8
	EQUB 11, 13, 16
	EQUB 10, 18, 19
	EQUB 16, 8, 10
	EQUB 17, 0, 0
	EQUB 18, 2, 2
	EQUB 19, 3, 3
	EQUB 20, 4, 4
	EQUB 21, 5, 5
	EQUB 21, 7, 10
	EQUB 16, 13, 14
	EQUB 16, 16, 16
	EQUB 16, 18, 19
	EQUB 21, 13, 15
	EQUB 21, 17, 19
	.map3platform_end

	; Ladder data (X, bottom Y, top Y)
	
	.map3ladder_start
	EQUB 3, 2, 8
	EQUB 8, 2, 23
	EQUB 14, 12, 23
	EQUB 15, 2, 8
	EQUB 19, 16, 23
	.map3ladder_end

	; Lift X
	
	EQUB 11
	
	; Data for 12 eggs (X, Y)

	EQUB 0, 2
	EQUB 0, 13
	EQUB 0, 18
	EQUB 7, 7
	EQUB 9, 17
	EQUB 13, 2
	EQUB 16, 7
	EQUB 13, 12
	EQUB 19, 11
	EQUB 17, 16
	EQUB 16, 21
	EQUB 16, 24
	
	; Seed data (X, Y)
	
	.map3seed_start
	EQUB 0, 7
	EQUB 10, 2
	EQUB 18, 2
	EQUB 5, 15
	EQUB 9, 22
	EQUB 13, 22
	.map3seed_end

	; Bird data (X, Y)

	EQUB 10, 22
	EQUB 17, 22
	EQUB 17, 2
	EQUB 4, 2
	EQUB 10, 7



;----------------------------------------------------------------------------------
;	Map 4 data
;----------------------------------------------------------------------------------

.map4data
	
	EQUB (map4platform_end - map4platform_start) / 3	; number of platforms
	EQUB (map4ladder_end - map4ladder_start) / 3		; number of ladders
	EQUB 1												; has lifts flag
	EQUB (map4seed_end - map4seed_start) / 2			; number of seeds
	EQUB 4												; initial number of birds
	
	; Platform data (Y, startX, endX)
	
	.map4platform_start
	EQUB 1, 0, 1
	EQUB 1, 3, 11
	EQUB 1, 13, 15
	EQUB 1, 18, 19
	EQUB 6, 0, 5
	EQUB 6, 9, 12
	EQUB 6, 14, 15
	EQUB 11, 0, 5
	EQUB 11, 10, 15
	EQUB 11, 19, 19
	EQUB 16, 0, 5
	EQUB 21, 3, 7
	EQUB 20, 9, 9
	EQUB 19, 11, 13
	EQUB 18, 14, 14
	EQUB 22, 12, 15
	EQUB 21, 18, 19
	.map4platform_end

	; Ladder data (X, bottom Y, top Y)
	
	.map4ladder_start
	EQUB 3, 2, 8
	EQUB 2, 12, 18
	EQUB 4, 12, 23
	EQUB 7, 2, 7
	EQUB 7, 10, 17
	EQUB 10, 2, 8
	EQUB 12, 7, 13
	EQUB 12, 20, 24
	EQUB 14, 2, 8
	.map4ladder_end

	; Lift X
	
	EQUB 16
	
	; Data for 12 eggs (X, Y)

	EQUB 0, 2
	EQUB 0, 7
	EQUB 0, 12
	EQUB 0, 17
	EQUB 5, 7
	EQUB 5, 22
	EQUB 9, 11
	EQUB 13, 6
	EQUB 11, 20
	EQUB 13, 23
	EQUB 19, 12
	EQUB 19, 22
	
	; Seed data (X, Y)
	
	.map4seed_start
	EQUB 4, 2
	EQUB 5, 2
	EQUB 6, 2
	EQUB 13, 2
	EQUB 15, 2
	EQUB 18, 2
	EQUB 10, 12
	EQUB 15, 12
	EQUB 3, 22
	EQUB 6, 22
	EQUB 7, 22
	EQUB 15, 23
	EQUB 18, 22
	.map4seed_end

	; Bird data (X, Y)
	EQUB 1, 7
	EQUB 3, 12
	EQUB 1, 17
	EQUB 14, 12
	EQUB 15, 7


;----------------------------------------------------------------------------------
;	Map 5 data
;----------------------------------------------------------------------------------

.map5data
	
	EQUB (map5platform_end - map5platform_start) / 3	; number of platforms
	EQUB (map5ladder_end - map5ladder_start) / 3		; number of ladders
	EQUB 1												; has lifts flag
	EQUB (map5seed_end - map5seed_start) / 2			; number of seeds
	EQUB 4												; initial number of birds
	
	; Platform data (Y, startX, endX)
	
	.map5platform_start
	EQUB 1, 0, 2
	EQUB 1, 6, 8
	EQUB 1, 11, 14
	EQUB 6, 0, 1
	EQUB 6, 3, 5
	EQUB 6, 12, 14
	EQUB 11, 2, 7
	EQUB 11, 12, 17
	EQUB 10, 17, 19
	EQUB 16, 0, 5
	EQUB 16, 16, 19
	EQUB 21, 6, 6
	EQUB 21, 8, 8
	EQUB 20, 12, 17
	EQUB 22, 17, 19
	EQUB 2, 17, 17
	.map5platform_end

	; Ladder data (X, bottom Y, top Y)
	
	.map5ladder_start
	EQUB 0, 2, 8
	EQUB 4, 4, 18
	EQUB 14, 7, 13
	EQUB 14, 19, 23
	EQUB 17, 2, 13
	EQUB 17, 16, 24
	.map5ladder_end

	; Lift X
	
	EQUB 9
	
	; Data for 12 eggs (X, Y)

	EQUB 2, 2
	EQUB 16, 2
	EQUB 5, 7
	EQUB 12, 7
	EQUB 12, 12
	EQUB 16, 12
	EQUB 7, 17
	EQUB 3, 21
	EQUB 6, 22
	EQUB 12, 21
	EQUB 19, 17
	EQUB 19, 23
	
	; Seed data (X, Y)
	
	.map5seed_start
	EQUB 11, 2
	EQUB 12, 2
	EQUB 13, 2
	EQUB 14, 2
	EQUB 0, 17
	EQUB 2, 17
	EQUB 3, 17
	EQUB 7, 12
	EQUB 19, 11
	.map5seed_end

	; Bird data (X, Y)
	
	EQUB 1, 17
	EQUB 1, 2
	EQUB 18, 17
	EQUB 13, 7
	EQUB 18, 11



;----------------------------------------------------------------------------------
;	Map 6 data
;----------------------------------------------------------------------------------

.map6data
	
	EQUB (map6platform_end - map6platform_start) / 3	; number of platforms
	EQUB (map6ladder_end - map6ladder_start) / 3		; number of ladders
	EQUB 1												; has lifts flag
	EQUB (map6seed_end - map6seed_start) / 2			; number of seeds
	EQUB 3												; initial number of birds
	
	; Platform data (Y, startX, endX)
	
	.map6platform_start
	EQUB 21, 11, 16
	EQUB 16, 0, 4
	EQUB 16, 6, 7
	EQUB 11, 0, 2
	EQUB 6, 1, 3
	EQUB 4, 0, 1
	EQUB 1, 3, 4
	EQUB 2, 5, 6
	EQUB 1, 7, 8
	EQUB 2, 9, 9
	EQUB 3, 9, 9
	EQUB 3, 12, 12
	EQUB 8, 5, 8
	EQUB 9, 5, 5
	EQUB 10, 5, 5
	EQUB 11, 5, 5
	EQUB 12, 5, 5
	EQUB 11, 8, 8
	EQUB 12, 8, 8
	EQUB 15, 12, 15
	EQUB 11, 10, 11
	EQUB 9, 14, 16
	EQUB 2, 15, 16
	.map6platform_end

	; Ladder data (X, bottom Y, top Y)
	
	.map6ladder_start
	EQUB 1, 2, 18
	EQUB 3, 2, 8
	EQUB 5, 20, 24
	EQUB 7, 20, 24
	EQUB 9, 20, 24
	EQUB 13, 16, 23
	EQUB 15, 10, 17
	.map6ladder_end

	; Lift X
	
	EQUB 18
	
	; Data for 12 eggs (X, Y)

	EQUB 6, 23
	EQUB 8, 23
	EQUB 10, 23
	EQUB 15, 22
	EQUB 7, 17
	EQUB 2, 3
	EQUB 7, 9
	EQUB 11, 12
	EQUB 16, 15
	EQUB 16, 10
	EQUB 12, 4
	EQUB 17, 2
	
	; Seed data (X, Y)
	
	.map6seed_start
	EQUB 2, 7
	EQUB 3, 17
	EQUB 8, 9
	EQUB 12, 22
	.map6seed_end

	; Bird data (X, Y)
	
	EQUB 13, 22
	EQUB 1, 17
	EQUB 14, 10
	EQUB 0, 5
	EQUB 2, 12
	

;----------------------------------------------------------------------------------
;	Map 7 data
;----------------------------------------------------------------------------------

.map7data
	
	EQUB (map7platform_end - map7platform_start) / 3	; number of platforms
	EQUB (map7ladder_end - map7ladder_start) / 3		; number of ladders
	EQUB 0												; has lifts flag
	EQUB (map7seed_end - map7seed_start) / 2			; number of seeds
	EQUB 3												; initial number of birds
	
	; Platform data (Y, startX, endX)
	
	.map7platform_start
	EQUB 1, 0, 19
	EQUB 6, 2, 4
	EQUB 6, 7, 13
	EQUB 6, 16, 18
	EQUB 11, 2, 5
	EQUB 11, 8, 12
	EQUB 11, 15, 18
	EQUB 16, 3, 6
	EQUB 16, 9, 11
	EQUB 16, 14, 17
	EQUB 21, 3, 3
	EQUB 21, 6, 6
	EQUB 21, 8, 12
	EQUB 21, 14, 14
	EQUB 21, 17, 17
	.map7platform_end

	; Ladder data (X, bottom Y, top Y)
	
	.map7ladder_start
	EQUB 3, 2, 8
	EQUB 17, 2, 8
	EQUB 10, 7, 13
	EQUB 4, 12, 18
	EQUB 16, 12, 18
	EQUB 10, 17, 23
	.map7ladder_end

	; No lift
		
	; Data for 12 eggs (X, Y)

	EQUB 5, 6
	EQUB 15, 6
	EQUB 6, 11
	EQUB 14, 11
	EQUB 8, 16
	EQUB 12, 16
	EQUB 5, 21
	EQUB 15, 21
	EQUB 7, 21
	EQUB 13, 21
	EQUB 3, 24
	EQUB 17, 24
	
	; Seed data (X, Y)
	
	.map7seed_start
	EQUB 1, 2
	EQUB 2, 2
	EQUB 4, 2
	EQUB 5, 2
	EQUB 6, 2
	EQUB 8, 2
	EQUB 9, 2
	EQUB 10, 2
	EQUB 11, 2
	EQUB 12, 2
	EQUB 13, 2
	EQUB 14 ,2
	EQUB 15, 2
	EQUB 16, 2
	EQUB 18, 2
	EQUB 19, 2
	.map7seed_end

	; Bird data (X, Y)
	
	EQUB 17, 2
	EQUB 10, 12
	EQUB 10, 22
	EQUB 3, 17
	EQUB 17, 17
	

.SPARE2
	EQUB &55, &42, &28, &34, &29, &3A, &20, &45
	
.codelow_end



;---------------------------------------------------------------------------------------------------
; The part of the code which lives in 'main' memory

.codemain_start

;----------------------------------------------------------------------------------
;	Sprite data table - width, height, address
;----------------------------------------------------------------------------------

.spritetable
;   width, height	  data address					  index
	EQUB 150, 24	: EQUW &3600					: SpriteId_Unused			= 0
	EQUB 8, 8		: EQUW sprite_platform			: SpriteId_Platform			= 1
	EQUB 8, 8		: EQUW sprite_ladder			: SpriteId_Ladder			= 2
	EQUB 8, 8		: EQUW sprite_egg				: SpriteId_Egg				= 3
	EQUB 8, 8		: EQUW sprite_seed				: SpriteId_Seed				= 4
	EQUB 16, 4		: EQUW sprite_lift				: SpriteId_Lift				= 5
	EQUB 8, 16		: EQUW sprite_manright1			: SpriteId_ManRight1		= 6
	EQUB 8, 16		: EQUW sprite_manright2			: SpriteId_ManRight2		= 7
	EQUB 8, 16		: EQUW sprite_manright3			: SpriteId_ManRight3		= 8
	EQUB 8, 16		: EQUW sprite_manleft1			: SpriteId_ManLeft1			= 9
	EQUB 8, 16		: EQUW sprite_manleft2			: SpriteId_ManLeft2			= 10
	EQUB 8, 16		: EQUW sprite_manleft3			: SpriteId_ManLeft3			= 11
	EQUB 8, 16		: EQUW sprite_manupdown1		: SpriteId_ManUpDown1		= 12
	EQUB 8, 18		: EQUW sprite_manupdown2		: SpriteId_ManUpDown2		= 13
	EQUB 8, 18		: EQUW sprite_manupdown3		: SpriteId_ManUpDown3		= 14
	EQUB 16, 24		: EQUW sprite_bigbirdright1		: SpriteId_BigBirdRight1	= 15
	EQUB 16, 24		: EQUW sprite_bigbirdright2		: SpriteId_BigBirdRight2	= 16
	EQUB 16, 24		: EQUW sprite_bigbirdleft1		: SpriteId_BigBirdLeft1		= 17
	EQUB 16, 24		: EQUW sprite_bigbirdleft2		: SpriteId_BigBirdLeft2		= 18
	EQUB 24, 48		: EQUW sprite_cagewithhole		: SpriteId_CageWithHole		= 19
	EQUB 24, 48		: EQUW sprite_cage				: SpriteId_Cage				= 20
	EQUB 8, 20		: EQUW sprite_birdright1		: SpriteId_BirdRight1		= 21
	EQUB 8, 20		: EQUW sprite_birdright2		: SpriteId_BirdRight2		= 22
	EQUB 8, 20		: EQUW sprite_birdleft1			: SpriteId_BirdLeft1		= 23
	EQUB 8, 20		: EQUW sprite_birdleft2			: SpriteId_BirdLeft2		= 24
	EQUB 8, 20		: EQUW sprite_birdupdown1		: SpriteId_BirdUpDown1		= 25
	EQUB 8, 22		: EQUW sprite_birdupdown2		: SpriteId_BirdUpDown2		= 26
	EQUB 16, 20		: EQUW sprite_birdeatright1		: SpriteId_BirdEatRight1	= 27
	EQUB 16, 20		: EQUW sprite_birdeatright2		: SpriteId_BirdEatRight2	= 28
	EQUB 16, 20		: EQUW sprite_birdeatleft1		: SpriteId_BirdEatLeft1		= 29
	EQUB 16, 20		: EQUW sprite_birdeatleft2		: SpriteId_BirdEatLeft2		= 30
	EQUB 8, 7		: EQUW sprite_digit0			: SpriteId_Digit0			= 31
	EQUB 8, 7		: EQUW sprite_digit1			: SpriteId_Digit1			= 32
	EQUB 8, 7		: EQUW sprite_digit2			: SpriteId_Digit2			= 33
	EQUB 8, 7		: EQUW sprite_digit3			: SpriteId_Digit3			= 34
	EQUB 8, 7		: EQUW sprite_digit4			: SpriteId_Digit4			= 35
	EQUB 8, 7		: EQUW sprite_digit5			: SpriteId_Digit5			= 36
	EQUB 8, 7		: EQUW sprite_digit6			: SpriteId_Digit6			= 37
	EQUB 8, 7		: EQUW sprite_digit7			: SpriteId_Digit7			= 38
	EQUB 8, 7		: EQUW sprite_digit8			: SpriteId_Digit8			= 39
	EQUB 8, 7		: EQUW sprite_digit9			: SpriteId_Digit9			= 40
	EQUB 24, 9		: EQUW sprite_score				: SpriteId_Score			= 41
	EQUB 32, 9		: EQUW sprite_highlightbox		: SpriteId_HighlightBox		= 42
	EQUB 32, 9		: EQUW sprite_player			: SpriteId_Player			= 43
	EQUB 40, 9		: EQUW sprite_level				: SpriteId_Level			= 44
	EQUB 48, 9		: EQUW sprite_bonus				: SpriteId_Bonus			= 45
	EQUB 40, 9		: EQUW sprite_time				: SpriteId_Time				= 46
	EQUB 8, 3		: EQUW sprite_life				: SpriteId_Life				= 47
	EQUB 16, 30		: EQUW sprite_bigc				: SpriteId_BigC				= 48
	EQUB 16, 30		: EQUW sprite_bigh				: SpriteId_BigH				= 49
	EQUB 16, 30		: EQUW sprite_bigu				: SpriteId_BigU				= 50
	EQUB 16, 30		: EQUW sprite_bigk				: SpriteId_BigK				= 51
	EQUB 16, 30		: EQUW sprite_bigi				: SpriteId_BigI				= 52
	EQUB 16, 30		: EQUW sprite_bige				: SpriteId_BigE				= 53
	EQUB 16, 30		: EQUW sprite_bigg				: SpriteId_BigG				= 54

	SKIP 36


	
;----------------------------------------------------------------------------------
;	Sprite data
;----------------------------------------------------------------------------------

.sprite_platform
	EQUB %11111011
	EQUB %00000000
	EQUB %10111111
	EQUB %00000000
	EQUB %11101111
	EQUB %00000000
	EQUB %00000000
	EQUB %00000000

.sprite_ladder
	EQUB %01000010
	EQUB %01000010
	EQUB %01000010
	EQUB %01000010
	EQUB %01111110
	EQUB %01000010
	EQUB %01000010
	EQUB %01000010

.sprite_egg
	EQUB %00000000
	EQUB %00111000
	EQUB %01101100
	EQUB %01011110
	EQUB %01111110
	EQUB %01111100
	EQUB %00111000
	EQUB %00000000

.sprite_seed
	EQUB %00000000
	EQUB %00000000
	EQUB %00000000
	EQUB %00001000
	EQUB %00010100
	EQUB %00101010
	EQUB %01010101
	EQUB %00000000

.sprite_lift
	EQUB %00011111, %11111000
	EQUB %00011111, %11111000
	EQUB %00011011, %11011000
	EQUB %00010001, %10001000

.sprite_manright1
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00110100
	EQUB %00111100
	EQUB %00010000
	EQUB %00011000
	EQUB %00111100
	EQUB %01101110
	EQUB %01101110
	EQUB %01101110
	EQUB %01101110
	EQUB %00111100
	EQUB %00011000
	EQUB %00010000
	EQUB %00011000

.sprite_manright2
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00110100
	EQUB %00111100
	EQUB %00010000
	EQUB %00011000
	EQUB %00111100
	EQUB %01101110
	EQUB %01101110
	EQUB %01110110
	EQUB %01110110
	EQUB %00111100
	EQUB %00111000
	EQUB %01001010
	EQUB %00100100

.sprite_manright3
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00110100
	EQUB %00111100
	EQUB %00010000
	EQUB %00011000
	EQUB %00111100
	EQUB %01101110
	EQUB %01101110
	EQUB %01011110
	EQUB %01011110
	EQUB %00111100
	EQUB %00111000
	EQUB %01001010
	EQUB %00100100

.sprite_manleft1
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00101100
	EQUB %00111100
	EQUB %00001000
	EQUB %00011000
	EQUB %00111100
	EQUB %01110110
	EQUB %01110110
	EQUB %01110110
	EQUB %01110110
	EQUB %00111100
	EQUB %00011000
	EQUB %00001000
	EQUB %00011000

.sprite_manleft2
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00101100
	EQUB %00111100
	EQUB %00001000
	EQUB %00011000
	EQUB %00111100
	EQUB %01110110
	EQUB %01110110
	EQUB %01101110
	EQUB %01101110
	EQUB %00111100
	EQUB %00011100
	EQUB %01010010
	EQUB %00100100

.sprite_manleft3
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00101100
	EQUB %00111100
	EQUB %00001000
	EQUB %00011000
	EQUB %00111100
	EQUB %01110110
	EQUB %01110110
	EQUB %01111010
	EQUB %01111010
	EQUB %00111100
	EQUB %00011100
	EQUB %01010010
	EQUB %00100100

.sprite_manupdown1
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00111100
	EQUB %00111100
	EQUB %00011000
	EQUB %00011000
	EQUB %10111101
	EQUB %11111111
	EQUB %01111110
	EQUB %01111110
	EQUB %01111110
	EQUB %00111100
	EQUB %00100100
	EQUB %00100100
	EQUB %01100110

.sprite_manupdown2
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00111100
	EQUB %00111101
	EQUB %00011001
	EQUB %00011001
	EQUB %00111101
	EQUB %11111111
	EQUB %11111110
	EQUB %11111110
	EQUB %11111110
	EQUB %10111100
	EQUB %00111110
	EQUB %00100000
	EQUB %00100000
	EQUB %00100000
	EQUB %01100000

.sprite_manupdown3
	EQUB %00011000
	EQUB %00111100
	EQUB %11111111
	EQUB %00111100
	EQUB %10111100
	EQUB %10011000
	EQUB %10011000
	EQUB %10111100
	EQUB %11111111
	EQUB %01111111
	EQUB %01111111
	EQUB %01111111
	EQUB %00111101
	EQUB %01111100
	EQUB %00000100
	EQUB %00000100
	EQUB %00000100
	EQUB %00000110

.sprite_bigbirdright1
	EQUB %00000000, %01110000
	EQUB %00000000, %11111000
	EQUB %00000001, %11101000
	EQUB %00000001, %11101111
	EQUB %00000001, %11111111
	EQUB %00000001, %11111000
	EQUB %00000000, %11110000
	EQUB %00000000, %11100000
	EQUB %00000000, %01100000
	EQUB %00001110, %01110000
	EQUB %00011111, %01110000
	EQUB %00111111, %11111000
	EQUB %01111111, %11111000
	EQUB %11111111, %01111000
	EQUB %11111111, %10111000
	EQUB %10111111, %10111100
	EQUB %10111111, %10111100
	EQUB %11011111, %10111100
	EQUB %01101111, %01111100
	EQUB %01110110, %11111100
	EQUB %00111001, %11111000
	EQUB %00011111, %11111000
	EQUB %00001111, %11110000
	EQUB %00000011, %11100000

.sprite_bigbirdright2
	EQUB %00000000, %01110000
	EQUB %00000000, %11111001
	EQUB %00000001, %11101010
	EQUB %00000001, %11101100
	EQUB %00000001, %11111100
	EQUB %00000001, %11111010
	EQUB %00000000, %11110001
	EQUB %00000000, %11100000
	EQUB %00000000, %01100000
	EQUB %00001110, %01110000
	EQUB %00011111, %01110000
	EQUB %00111111, %11111000
	EQUB %01110001, %11111000
	EQUB %11101110, %01111000
	EQUB %11011111, %10111000
	EQUB %10111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %01111111, %11111100
	EQUB %01111111, %11111100
	EQUB %00111111, %11111000
	EQUB %00011111, %11111000
	EQUB %00001111, %11110000
	EQUB %00000011, %11100000

.sprite_bigbirdleft1
	EQUB %00001110, %00000000
	EQUB %00011111, %00000000
	EQUB %00010111, %10000000
	EQUB %11110111, %10000000
	EQUB %11111111, %10000000
	EQUB %00011111, %10000000
	EQUB %00001111, %00000000
	EQUB %00000111, %00000000
	EQUB %00000110, %00000000
	EQUB %00001110, %01110000
	EQUB %00001110, %11111000
	EQUB %00011111, %11111100
	EQUB %00011111, %11111110
	EQUB %00011110, %11111111
	EQUB %00011101, %11111111
	EQUB %00111101, %11111101
	EQUB %00111101, %11111101
	EQUB %00111101, %11111011
	EQUB %00111110, %11110110
	EQUB %00111111, %01101110
	EQUB %00011111, %10011100
	EQUB %00011111, %11111000
	EQUB %00001111, %11110000
	EQUB %00000111, %11000000

.sprite_bigbirdleft2
	EQUB %00001110, %00000000
	EQUB %10011111, %00000000
	EQUB %01010111, %10000000
	EQUB %00110111, %10000000
	EQUB %00111111, %10000000
	EQUB %01011111, %10000000
	EQUB %10001111, %00000000
	EQUB %00000111, %00000000
	EQUB %00000110, %00000000
	EQUB %00001110, %01110000
	EQUB %00001110, %11111000
	EQUB %00011111, %11111100
	EQUB %00011111, %10001110
	EQUB %00011110, %01110111
	EQUB %00011101, %11111011
	EQUB %00111111, %11111101
	EQUB %00111111, %11111111
	EQUB %00111111, %11111111
	EQUB %00111111, %11111110
	EQUB %00111111, %11111110
	EQUB %00011111, %11111100
	EQUB %00011111, %11111000
	EQUB %00001111, %11110000
	EQUB %00000111, %11000000

.sprite_cagewithhole
	EQUB %00000000, %00111000, %00000000
	EQUB %00000000, %01000100, %00000000
	EQUB %00000000, %01000100, %00000000
	EQUB %00000000, %01000100, %00000000
	EQUB %00000000, %00111000, %00000000
	EQUB %00000000, %00010000, %00000000
	EQUB %00000000, %11111110, %00000000
	EQUB %00000011, %01111101, %10000000
	EQUB %00001100, %11010110, %01100000
	EQUB %00010001, %01010101, %00010000
	EQUB %00100010, %01010100, %10001000
	EQUB %00100100, %10010010, %01001000
	EQUB %01000100, %10010010, %01000100
	EQUB %01001000, %10010010, %00100100
	EQUB %10001000, %10010010, %00100010
	EQUB %10001001, %00010001, %00100010
	EQUB %11010001, %00010000, %00010110
	EQUB %10110001, %00010000, %00001010
	EQUB %10011001, %00000000, %00000010
	EQUB %10010111, %00000000, %00000010
	EQUB %10010001, %11100000, %00000010
	EQUB %10010001, %00000000, %00000010
	EQUB %10010001, %00010000, %00000010
	EQUB %10010001, %00010000, %00010010
	EQUB %10010001, %00010000, %00010010
	EQUB %10010001, %00010000, %00010010
	EQUB %10010000, %00000000, %00010010
	EQUB %10010000, %00000000, %00010010
	EQUB %10010000, %00000000, %00010010
	EQUB %11010000, %00000000, %00010110
	EQUB %10110000, %00000000, %00011010
	EQUB %10010000, %00000000, %00110010
	EQUB %10010000, %00000000, %00010010
	EQUB %10010000, %00000000, %00010010
	EQUB %10010000, %00000000, %00010010
	EQUB %10010000, %00000000, %00010010
	EQUB %10010000, %00000000, %00010010
	EQUB %10010000, %00000000, %00010010
	EQUB %10010001, %00000000, %00010010
	EQUB %10010001, %00000001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %11010001, %00010001, %00010010
	EQUB %01010001, %00010001, %00010100
	EQUB %00110001, %00010001, %00011000
	EQUB %00011001, %00010001, %00110000
	EQUB %00000111, %00010001, %11000000
	EQUB %00000000, %11111110, %00000000

.sprite_cage
	EQUB %00000000, %00111000, %00000000
	EQUB %00000000, %01000100, %00000000
	EQUB %00000000, %01000100, %00000000
	EQUB %00000000, %01000100, %00000000
	EQUB %00000000, %00111000, %00000000
	EQUB %00000000, %00010000, %00000000
	EQUB %00000000, %11111110, %00000000
	EQUB %00000011, %01111101, %10000000
	EQUB %00001100, %11010110, %01100000
	EQUB %00010001, %01010101, %00010000
	EQUB %00100010, %01010100, %10001000
	EQUB %00100100, %10010010, %01001000
	EQUB %01000100, %10010010, %01000100
	EQUB %01001000, %10010010, %00100100
	EQUB %10001000, %10010010, %00100010
	EQUB %10001001, %00010001, %00100010
	EQUB %11010001, %00010001, %00010110
	EQUB %10110001, %00010001, %00011010
	EQUB %10011001, %00010001, %00110010
	EQUB %10010111, %00010001, %11010010
	EQUB %10010001, %11111111, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %11010001, %00010001, %00010110
	EQUB %10110001, %00010001, %00011010
	EQUB %10011001, %00010001, %00110010
	EQUB %10010111, %00010001, %11010010
	EQUB %10010001, %11111111, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %10010001, %00010001, %00010010
	EQUB %11010001, %00010001, %00010010
	EQUB %01010001, %00010001, %00010100
	EQUB %00110001, %00010001, %00011000
	EQUB %00011001, %00010001, %00110000
	EQUB %00000111, %00010001, %11000000
	EQUB %00000000, %11111110, %00000000

.sprite_birdright1
	EQUB %00001100
	EQUB %00011011
	EQUB %00011100
	EQUB %00001000
	EQUB %00001000
	EQUB %00000100
	EQUB %00000100
	EQUB %00000010
	EQUB %00110010
	EQUB %01111011
	EQUB %01111111
	EQUB %01111111
	EQUB %01111111
	EQUB %00111110
	EQUB %00011000
	EQUB %00010000
	EQUB %00010000
	EQUB %00010000
	EQUB %00010000
	EQUB %00011000

.sprite_birdright2
	EQUB %00001101
	EQUB %00011010
	EQUB %00011101
	EQUB %00001000
	EQUB %00001000
	EQUB %00000100
	EQUB %00000100
	EQUB %00000010
	EQUB %00110010
	EQUB %01111011
	EQUB %01111111
	EQUB %01111111
	EQUB %01111111
	EQUB %00111110
	EQUB %00011000
	EQUB %00101000
	EQUB %00101000
	EQUB %01000100
	EQUB %01000101
	EQUB %00100010

.sprite_birdleft1
	EQUB %00110000
	EQUB %11011000
	EQUB %00111000
	EQUB %00010000
	EQUB %00010000
	EQUB %00100000
	EQUB %00100000
	EQUB %01000000
	EQUB %01001100
	EQUB %11011110
	EQUB %11111110
	EQUB %11111110
	EQUB %11111110
	EQUB %01111100
	EQUB %00011000
	EQUB %00001000
	EQUB %00001000
	EQUB %00001000
	EQUB %00001000
	EQUB %00011000

.sprite_birdleft2
	EQUB %10110000
	EQUB %01011000
	EQUB %10111000
	EQUB %00010000
	EQUB %00010000
	EQUB %00100000
	EQUB %00100000
	EQUB %01000000
	EQUB %01001100
	EQUB %11011110
	EQUB %11111110
	EQUB %11111110
	EQUB %11111110
	EQUB %01111100
	EQUB %00011000
	EQUB %00010100
	EQUB %00010100
	EQUB %00100010
	EQUB %10100010
	EQUB %01000100

.sprite_birdupdown1
	EQUB %00011000
	EQUB %00111100
	EQUB %00111100
	EQUB %00111100
	EQUB %00011000
	EQUB %00011000
	EQUB %00011000
	EQUB %00111100
	EQUB %01111110
	EQUB %01111110
	EQUB %01111110
	EQUB %01111110
	EQUB %01111110
	EQUB %00111100
	EQUB %00111100
	EQUB %00100100
	EQUB %00100100
	EQUB %00100110
	EQUB %00100000
	EQUB %01100000

.sprite_birdupdown2
	EQUB %00011000
	EQUB %00111100
	EQUB %00111100
	EQUB %00111100
	EQUB %00011000
	EQUB %00011000
	EQUB %00011000
	EQUB %00111100
	EQUB %01111110
	EQUB %01111110
	EQUB %01111110
	EQUB %01111110
	EQUB %01111110
	EQUB %00111100
	EQUB %00111100
	EQUB %00100100
	EQUB %00100100
	EQUB %01100100
	EQUB %00000100
	EQUB %00000100
	EQUB %00000100
	EQUB %00000110

.sprite_birdeatright1
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00111000
	EQUB %00110000, %00101000
	EQUB %01111000, %01111000
	EQUB %01111100, %11000100
	EQUB %01111111, %11000010
	EQUB %01111111, %10000000
	EQUB %00111111, %00000000
	EQUB %00111111, %00000000
	EQUB %00011111, %00000000
	EQUB %00010110, %00000000
	EQUB %00010000, %00000000
	EQUB %00010000, %00000000
	EQUB %00010000, %00000000
	EQUB %00011000, %00000000

.sprite_birdeatright2
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00110000, %00000000
	EQUB %01111000, %00000000
	EQUB %01111100, %00000000
	EQUB %01111110, %00000000
	EQUB %01111111, %11111000
	EQUB %00111111, %11110100
	EQUB %00111111, %00010100
	EQUB %00011111, %00001000
	EQUB %00010110, %00001000
	EQUB %00010000, %00001000
	EQUB %00010000, %00000000
	EQUB %00010000, %00000000
	EQUB %00011000, %00000000

.sprite_birdeatleft1
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00011100, %00000000
	EQUB %00010100, %00001100
	EQUB %00011110, %00011110
	EQUB %00100011, %00111110
	EQUB %01000011, %11111110
	EQUB %00000001, %11111110
	EQUB %00000000, %11111100
	EQUB %00000000, %11111100
	EQUB %00000000, %11111000
	EQUB %00000000, %01101000
	EQUB %00000000, %00001000
	EQUB %00000000, %00001000
	EQUB %00000000, %00001000
	EQUB %00000000, %00011000

.sprite_birdeatleft2
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00000000
	EQUB %00000000, %00001100
	EQUB %00000000, %00011110
	EQUB %00000000, %00111110
	EQUB %00000000, %01111110
	EQUB %00011111, %11111110
	EQUB %00101111, %11111100
	EQUB %00101000, %11111100
	EQUB %00010000, %11111000
	EQUB %00010000, %01101000
	EQUB %00010000, %00001000
	EQUB %00000000, %00001000
	EQUB %00000000, %00001000
	EQUB %00000000, %00011000

.sprite_digit0
	EQUB %01100000
	EQUB %10010000
	EQUB %10010000
	EQUB %10010000
	EQUB %10010000
	EQUB %10010000
	EQUB %01100000

.sprite_digit1
	EQUB %00100000
	EQUB %01100000
	EQUB %00100000
	EQUB %00100000
	EQUB %00100000
	EQUB %00100000
	EQUB %01110000

.sprite_digit2
	EQUB %01100000
	EQUB %10010000
	EQUB %00010000
	EQUB %00100000
	EQUB %01000000
	EQUB %10000000
	EQUB %11110000

.sprite_digit3
	EQUB %01100000
	EQUB %10010000
	EQUB %00010000
	EQUB %00100000
	EQUB %00010000
	EQUB %10010000
	EQUB %01100000

.sprite_digit4
	EQUB %10000000
	EQUB %10000000
	EQUB %10100000
	EQUB %10100000
	EQUB %11110000
	EQUB %00100000
	EQUB %00100000

.sprite_digit5
	EQUB %11110000
	EQUB %10000000
	EQUB %11100000
	EQUB %00010000
	EQUB %00010000
	EQUB %10010000
	EQUB %01100000

.sprite_digit6
	EQUB %01100000
	EQUB %10010000
	EQUB %10000000
	EQUB %11100000
	EQUB %10010000
	EQUB %10010000
	EQUB %01100000

.sprite_digit7
	EQUB %11110000
	EQUB %00010000
	EQUB %00010000
	EQUB %00100000
	EQUB %00100000
	EQUB %01000000
	EQUB %01000000

.sprite_digit8
	EQUB %01100000
	EQUB %10010000
	EQUB %10010000
	EQUB %01100000
	EQUB %10010000
	EQUB %10010000
	EQUB %01100000

.sprite_digit9
	EQUB %01100000
	EQUB %10010000
	EQUB %10010000
	EQUB %01110000
	EQUB %00010000
	EQUB %10010000
	EQUB %01100000

.sprite_score
	EQUB %11111111, %11111111, %11111000
	EQUB %10001000, %10001001, %10001000
	EQUB %10111011, %10101010, %10111000
	EQUB %10111011, %10101010, %10111000
	EQUB %10001011, %10101001, %10011000
	EQUB %11101011, %10101010, %10111000
	EQUB %11101011, %10101010, %10111000
	EQUB %10001000, %10001010, %10001000
	EQUB %11111111, %11111111, %11111000

.sprite_highlightbox
	EQUB %11111111, %11111111, %11111111, %11111110
	EQUB %11111111, %11111111, %11111111, %11111110
	EQUB %11111111, %11111111, %11111111, %11111110
	EQUB %11111111, %11111111, %11111111, %11111110
	EQUB %11111111, %11111111, %11111111, %11111110
	EQUB %11111111, %11111111, %11111111, %11111110
	EQUB %11111111, %11111111, %11111111, %11111110
	EQUB %11111111, %11111111, %11111111, %11111110
	EQUB %11111111, %11111111, %11111111, %11111110

.sprite_player
	EQUB %11111111, %11111111, %11111111, %11111111
	EQUB %10011011, %11011010, %10001001, %11111111
	EQUB %10101011, %10101010, %10111010, %11111111
	EQUB %10101011, %10101010, %10111010, %11111111
	EQUB %10011011, %10001101, %10011001, %11111111
	EQUB %10111011, %10101101, %10111010, %11111111
	EQUB %10111011, %10101101, %10111010, %11111111
	EQUB %10111000, %10101101, %10001010, %11111111
	EQUB %11111111, %11111111, %11111111, %11111111

.sprite_level
	EQUB %11111111, %11111111, %11111111, %11111111, %11111100
	EQUB %10111000, %10101000, %10111111, %11111111, %11111100
	EQUB %10111011, %10101011, %10111111, %11111111, %11111100
	EQUB %10111011, %10101011, %10111111, %11111111, %11111100
	EQUB %10111001, %10101001, %10111111, %11111111, %11111100
	EQUB %10111011, %10101011, %10111111, %11111111, %11111100
	EQUB %10111011, %11011011, %10111111, %11111111, %11111100
	EQUB %10001000, %11011000, %10001111, %11111111, %11111100
	EQUB %11111111, %11111111, %11111111, %11111111, %11111100

.sprite_bonus
	EQUB %11111111, %11111111, %11111111, %11111111, %11111111, %11110000
	EQUB %10011000, %10110101, %01000111, %11111111, %11111111, %11110000
	EQUB %10101010, %10010101, %01011111, %11111111, %11111111, %11110000
	EQUB %10101010, %10010101, %01011111, %11111111, %11111111, %11110000
	EQUB %10011010, %10100101, %01000111, %11111111, %11111111, %11110000
	EQUB %10101010, %10100101, %01110111, %11111111, %11111111, %11110000
	EQUB %10101010, %10110101, %01110111, %11111111, %11111111, %11110000
	EQUB %10011000, %10110100, %01000111, %11111111, %11111111, %11110000
	EQUB %11111111, %11111111, %11111111, %11111111, %11111111, %11110000

.sprite_time
	EQUB %11111111, %11111111, %11111111, %11111111, %11000000
	EQUB %10001010, %01001000, %11111111, %11111111, %11000000
	EQUB %11011010, %01001011, %11111111, %11111111, %11000000
	EQUB %11011010, %10101011, %11111111, %11111111, %11000000
	EQUB %11011010, %10101001, %11111111, %11111111, %11000000
	EQUB %11011010, %10101011, %11111111, %11111111, %11000000
	EQUB %11011010, %11101011, %11111111, %11111111, %11000000
	EQUB %11011010, %11101000, %11111111, %11111111, %11000000
	EQUB %11111111, %11111111, %11111111, %11111111, %11000000

.sprite_life
	EQUB %01000000
	EQUB %11100000
	EQUB %00000000

.sprite_bigc
	EQUB %00000011, %10000000
	EQUB %00001111, %11100000
	EQUB %00011111, %11110000
	EQUB %00011111, %11111000
	EQUB %00111111, %11111000
	EQUB %00111111, %11111100
	EQUB %01111111, %11111100
	EQUB %01111111, %11111100
	EQUB %01111110, %01111100
	EQUB %01111100, %00111000
	EQUB %11111000, %00011000
	EQUB %11111000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11111000, %00000000
	EQUB %11111000, %00011000
	EQUB %01111100, %00111000
	EQUB %01111110, %01111100
	EQUB %01111111, %11111100
	EQUB %01111111, %11111100
	EQUB %00111111, %11111100
	EQUB %00111111, %11111000
	EQUB %00011111, %11111000
	EQUB %00011111, %11110000
	EQUB %00001111, %11100000
	EQUB %00000011, %10000000

.sprite_bigh
	EQUB %01100000, %00011000
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %01100000, %00011000

.sprite_bigu
	EQUB %01100000, %00011000
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11110000, %00111100
	EQUB %11111000, %01111100
	EQUB %11111100, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %01111111, %11111000
	EQUB %01111111, %11111000
	EQUB %00111111, %11110000

.sprite_bigk
	EQUB %01100000, %00010000
	EQUB %11110000, %00111000
	EQUB %11110000, %00111000
	EQUB %11110000, %01111100
	EQUB %11110000, %01111100
	EQUB %11110000, %11111100
	EQUB %11110000, %11111100
	EQUB %11110001, %11111000
	EQUB %11110001, %11111000
	EQUB %11110011, %11110000
	EQUB %11110011, %11110000
	EQUB %11110111, %11100000
	EQUB %11111111, %11100000
	EQUB %11111111, %11000000
	EQUB %11111111, %10000000
	EQUB %11111111, %11000000
	EQUB %11111111, %11000000
	EQUB %11111111, %11100000
	EQUB %11111111, %11100000
	EQUB %11110011, %11110000
	EQUB %11110011, %11110000
	EQUB %11110001, %11111000
	EQUB %11110001, %11111000
	EQUB %11110000, %11111100
	EQUB %11110000, %11111100
	EQUB %11110000, %01111100
	EQUB %11110000, %01111100
	EQUB %11110000, %00111000
	EQUB %11110000, %00111000
	EQUB %01100000, %00010000

.sprite_bigi
	EQUB %01111111, %11111000
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %01111111, %11111000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %00000111, %10000000
	EQUB %01111111, %11111000
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %01111111, %11111000

.sprite_bige
	EQUB %00111111, %11111000
	EQUB %01111111, %11111100
	EQUB %01111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %11111111, %11111000
	EQUB %11111000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11111111, %11100000
	EQUB %11111111, %11110000
	EQUB %11111111, %11110000
	EQUB %11111111, %11110000
	EQUB %11111111, %11110000
	EQUB %11111111, %11100000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11111000, %00000000
	EQUB %11111111, %11111000
	EQUB %11111111, %11111100
	EQUB %11111111, %11111100
	EQUB %01111111, %11111100
	EQUB %01111111, %11111100
	EQUB %00111111, %11111000

.sprite_bigg
	EQUB %00000011, %10000000
	EQUB %00001111, %11100000
	EQUB %00011111, %11110000
	EQUB %00011111, %11111000
	EQUB %00111111, %11111000
	EQUB %00111111, %11111100
	EQUB %01111111, %11111100
	EQUB %01111111, %11111100
	EQUB %01111110, %01111100
	EQUB %01111100, %00111000
	EQUB %11111000, %00011000
	EQUB %11111000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %00000000
	EQUB %11110000, %11111000
	EQUB %11110000, %11111000
	EQUB %11111000, %11111100
	EQUB %11111000, %01111100
	EQUB %01111100, %00111100
	EQUB %01111110, %00111100
	EQUB %01111111, %01111100
	EQUB %01111111, %11111100
	EQUB %00111111, %11111100
	EQUB %00111111, %11111100
	EQUB %00011111, %11111100
	EQUB %00011111, %11111000
	EQUB %00001111, %11111000
	EQUB %00000011, %11110000
	

.SPARE3
	EQUB &20
	SKIPTO &1900
	EQUB &0D, &FF
	

;----------------------------------------------------------------------------------
;	Plot sprite
;
;	(read)			= sprite data
;	(write)			= screen address
;	spriteline		= line within character row of sprite, 0-7
;	spritecolumn	= 0 or 1 for the pixel of the Mode 2 byte
;	spritewidth		= width of sprite data in bytes (multiples of 8 pixels)
;	spriteheight	= height of sprite in pixels
;	spritecolour	= byte which would set leftmost Mode 2 pixel in the desired colour
;
;	THIS IS HORRENDOUSLY INEFFICIENT - OPTIMISE ME!
;----------------------------------------------------------------------------------

.plotsprite
	
	LDA spritecolumn:STA columncounter		; 0 or 1
	LDY #0	
	LDA spritewidth:STA widthcounter		; sprite width counter
	LDX #0:LDA (read,X):STA spritebyte		; sprite data
	LDA #8:STA pixelbitcounter				; pixel bit counter
	
	; Prepare colour mask
	
	LDA spritecolour
	LDX columncounter
	BEQ dontrotatecolour
	.rotatecolourloop
	LSR A
	DEX
	BNE rotatecolourloop					; !!! OPTIMISE ME !!! not needed for Mode 2 version
	.dontrotatecolour
	STA pixelvalue							; the colour byte
	
	LDA #2:SEC:SBC columncounter
	STA columncounter						; number of pixels to plot (2 or 1 depending on sprite column)
	LDX #0
	
	.plotpixelloop
	ASL spritebyte							; get next bit from sprite data
	BCC pixelclear
	LDA (write),Y
	EOR pixelvalue
	STA (write),Y							; write pixel
	.pixelclear
	
	DEC pixelbitcounter						; dec bit counter
	BNE morebitsleft
	
	INC read:BNE P%+4:INC read+1			; move to next sprite byte
	
	DEC widthcounter						; dec sprite width counter
	BEQ spritedonerow
	
	LDA (read,X):STA spritebyte				; update sprite data
	LDA #8:STA pixelbitcounter				; pixel bit counter
	
	.morebitsleft
	LSR pixelvalue							; shift colour byte to next pixel
	DEC columncounter						; dec number of pixels to plot in this byte
	BNE plotpixelloop
	
	TYA:CLC:ADC #8:TAY						; move to next sprite data byte in the row
	
	LDA spritecolour:STA pixelvalue
	LDA #2:STA columncounter
	JMP plotpixelloop
	
	.spritedonerow
	DEC spriteheight
	BEQ plotspriteexit
	
	JSR spritegotonextrow
	JMP plotsprite
	
	.plotspriteexit
	RTS
	

;----------------------------------------------------------------------------------
;	Sets screen address / line to next row
;----------------------------------------------------------------------------------
	
.spritegotonextrow
	
	INC spriteline
	LDA spriteline
	AND #7
	BEQ movetonextcharrow
	INC write
	RTS
	
	.movetonextcharrow
	STA spriteline
	CLC
	LDA write:ADC #&79:STA write
	LDA write+1:ADC #2:STA write+1
	RTS
	

;----------------------------------------------------------------------------------
;	Calculate screen address from position in X, Y
;
;	Returns:
;	(write)			= screen address
;	spriteline		= line within character row
;	spritecolumn	= column 0 or 1
;
;	THIS IS HORRENDOUSLY INEFFICIENT - OPTIMISE ME!
;----------------------------------------------------------------------------------

.calcscrnaddr
	
	LDA #0:STA write+1
	STA spritetemp
	
	; calculate ((255-Y) AND &F8) * 80
	TYA:EOR #&FF:TAY
	AND #&F8
	STA write
	ASL A:ROL write+1					; *2
	ASL A:ROL write+1					; *4
	CLC:ADC write:STA write
	LDA #0:ADC write+1:STA write+1		; *5
	ASL write:ROL write+1				; *10
	ASL write:ROL write+1				; *20
	ASL write:ROL write+1				; *40
	ASL write:ROL write+1				; *80
	
	; adjust for line within character row
	TYA:AND #7:STA spriteline			; get spriteline	
	CLC:ADC write:STA write				; adjust address by spriteline
	
	TXA:AND #1:STA spritecolumn			; get spritecolumn
	
	; adjust for x position
	TXA:AND #&FE
	ASL A:ROL spritetemp
	ASL A:ROL spritetemp				; get x pos offset
	ADC write
	STA write
	LDA spritetemp
	ADC write+1
	ADC #&30
	STA write+1							; and adjust screen address
	RTS


;----------------------------------------------------------------------------------
;	Get sprite data of sprite A into spritewidth, spriteheight and (read)
;----------------------------------------------------------------------------------

.getspritedata
	
	; get sprite data pointer in (read)
	LDY #0:STY read+1
	ASL A:ROL read+1
	ASL A:ROL read+1
	ADC #LO(spritetable)
	STA read
	LDA read+1
	ADC #HI(spritetable)
	STA read+1
	
	; get width of sprite
	LDA (read),Y
	STA spritewidthpixels				; width of sprite in pixels
	CLC:ADC #7
	LSR A:LSR A:LSR A
	STA spritewidth						; sprite width in bytes
	
	; get height of sprite
	INY:LDA (read),Y
	STA spriteheight					; sprite height in pixels
	
	; get address of sprite data
	INY:LDA (read),Y:TAX
	INY:LDA (read),Y
	STX read
	STA read+1
	RTS


;----------------------------------------------------------------------------------
;	Plot sprite A at character block X, Y
;----------------------------------------------------------------------------------

.plotspriteatcharpos
	
	PHA
	
	TXA
	CLC
	ROL A
	ROL A
	ROL A
	TAX
	
	TYA
	SEC:ROL A
	SEC:ROL A
	SEC:ROL A
	TAY
	
	JSR calcscrnaddr
	
	PLA
	JSR getspritedata
	
	JSR plotsprite
	RTS

	

;----------------------------------------------------------------------------------
;	Print string at address YYXX
;
;	?YYXX = string length
;----------------------------------------------------------------------------------

.printstring
	
	STX string
	STY string+1
	LDY #0:LDA (string),Y
	STA stringlength
	
	.printstringloop
	INY:LDA (string),Y
	JSR oswrch
	CPY stringlength
	BNE printstringloop
	RTS



;----------------------------------------------------------------------------------
;	Handle keyboard input
;----------------------------------------------------------------------------------

.handlekeyboard	
	
	; Check pause key
	LDX #&AB
	LDY #&FF
	LDA #&81
	JSR osbyte
	CPY #0
	BEQ checkkeys
	
	; Check for pause key held
	.paused
	LDX #&AB
	LDY #&FF
	LDA #&81
	JSR osbyte
	CPY #0
	BEQ stillpaused
	
	; Check for escape
	LDX #&8F
	LDY #&FF
	LDA #&81
	JSR osbyte
	CPY #0
	BEQ stillpaused
	
	; H+Escape to quit to menu
	LDA #&80:STA keys
	RTS
	
	.stillpaused
	JSR checkkeys
	LDA keys
	BEQ paused						; any movement key finishes pause mode
		
	.checkkeys
	LDA #0:STA keys
	LDA #1:STA keybit
	LDX keynum_right:JSR checkkey
	LDX keynum_left:JSR checkkey
	LDX keynum_down:JSR checkkey
	LDX keynum_up:JSR checkkey
	LDX keynum_jump:JSR checkkey
	RTS
	

;----------------------------------------------------------------------------------
;	Check if key X is pressed, and OR ?keybit into keys bitfield if so
;----------------------------------------------------------------------------------

.checkkey

	LDY #&FF
	LDA #&81
	JSR osbyte
	CPY #0
	BEQ keynotpressed
	LDA keys:ORA keybit:STA keys
	.keynotpressed
	ASL keybit
	RTS


;----------------------------------------------------------------------------------
;	Generate a random number
;----------------------------------------------------------------------------------
	
.rnd

	LDA rndseed
	AND #&48
	ADC #&38
	ASL A
	ASL A
	ROL rndseed+3
	ROL rndseed+2
	ROL rndseed+1
	ROL rndseed
	RTS


;----------------------------------------------------------------------------------
;	Add A * 10^X to score
;----------------------------------------------------------------------------------

.addscore
	
	LDY #DigitsColour:STY spritecolour
	
	LDY score,X						; get original digit
	CLC
	ADC score,X
	CPX #3
	BNE dontawardextralife
	INC extralifeflag
	.dontawardextralife
	CMP #10
	BCC nomorecarry
	
	SEC
	SBC #10
	STA score,X
	JSR updatedigit
	LDA #1
	DEX
	BPL addscore
	RTS
	
	.nomorecarry
	STA score,X
	
	
;----------------------------------------------------------------------------------
;	Update digit X of score to A (Y = old digit)
;----------------------------------------------------------------------------------

.updatedigit
	
	CPX #2
	BCS updatedigit2
	RTS								; don't bother to update the least significant 2 digits
	.updatedigit2

	STA temp5						; new digit
	STX temp6						; digit number
	STY temp7						; original digit
	
	LDA currentscorexpos
	CLC
	.add5timesxloop
	ADC #5
	DEX
	BPL add5timesxloop
	
	STA temp4						; x position of digit
	TAX
	LDA temp7						; original digit
	LDY #&F7						; y position of digit
	JSR displaydigit				; remove old digit

	LDA temp5						; new digit
	LDX temp4						; x position of digit
	LDY #&F7						; y position of digit
	JSR displaydigit				; display new digit
	
	LDX temp6						; preserve x
	RTS
	

;----------------------------------------------------------------------------------
;	Display digit A at X,Y
;----------------------------------------------------------------------------------

.displaydigit
	
	PHA
	JSR calcscrnaddr
	PLA
	
	CLC
	ADC #SpriteId_Digit0
	JSR getspritedata
	JSR plotsprite
	RTS


;----------------------------------------------------------------------------------
;	Frame delay
;----------------------------------------------------------------------------------
	
.framedelay
	
	; Read interval timer into &00-&04
	LDA #3
	LDX #LO(intervaltimerblock)
	LDY #HI(intervaltimerblock)
	JSR osword
	LDA intervaltimerblock+1
	BNE finisheddelay
	LDA intervaltimerblock
	CMP #3
	BCC framedelay
	
	.finisheddelay
	; Set interval timer to 0
	LDA #0
	STA intervaltimerblock
	STA intervaltimerblock+1
	LDA #4
	LDX #LO(intervaltimerblock)
	LDY #HI(intervaltimerblock)
	JSR osword
	RTS
	

;----------------------------------------------------------------------------------
;	Initialise map (build and display map)
;----------------------------------------------------------------------------------

.initmap
	
	LDA #16:JSR oswrch					; CLG
	JSR drawtopstatus
	
	; Get map data pointer
	LDA screen:ASL A:TAY				; get screen index * 2
	LDA mapptrs,Y:STA mapdataptr
	INY
	LDA mapptrs,Y:STA mapdataptr+1

	; Get map properties
	LDY #0
	LDA (mapdataptr),Y:STA numplatforms
	INY
	LDA (mapdataptr),Y:STA numladders
	INY
	LDA (mapdataptr),Y:STA liftflag
	INY
	LDA (mapdataptr),Y:STA numseeds
	INY
	LDA (mapdataptr),Y:STA numbirds
	
	; Clear expanded map
	LDA #0
	TAX
	.clearmaploop
	STA mapdata,X
	STA mapdata+&100,X
	DEX
	BNE clearmaploop
	
	; Deal with platforms
	
	LDA #PlatformColour:STA spritecolour
	LDA numplatforms:STA temp3			; platform counter
	STY temp2
	
	.putplatformsloop
	LDY temp2
	INY
	LDA (mapdataptr),Y:STA temp4		; platform Y
	INY
	LDA (mapdataptr),Y:STA temp5		; platform start X
	INY
	LDA (mapdataptr),Y					; platform end X
	SEC:SBC temp5:STA temp6				; platform length - 1
	STY temp2
	
	.putplatformloop
	LDA #SpriteId_Platform	; same as MapId_Platform
	LDY temp4
	LDX temp5
	JSR setmapblock
	LDX temp5
	JSR plotspriteatcharpos
	INC temp5
	DEC temp6
	BPL putplatformloop
	
	DEC temp3
	BNE putplatformsloop

	; Deal with ladders
	
	LDA #LadderColour:STA spritecolour
	LDA numladders:STA temp3
	
	.putladdersloop
	LDY temp2
	INY
	LDA (mapdataptr),Y:STA temp4		; ladder X
	INY
	LDA (mapdataptr),Y:STA temp5		; ladder start Y
	INY
	LDA (mapdataptr),Y					; ladder end Y
	SEC:SBC temp5:STA temp6				; ladder length - 1
	STY temp2
	
	.putladderloop
	LDX temp4
	LDY temp5
	JSR getmapblock						; Check what's already there
	BEQ blankmapblock					; if nothing, skip this bit
	
	; unplot platform piece which is where the ladder is about to overwrite
	LDX #PlatformColour:STX spritecolour
	LDX temp4
	JSR plotspriteatcharpos				; erase platform
	LDA #SpriteId_Platform
	LDX #LadderColour:STX spritecolour
	
	.blankmapblock
	ORA #MapId_Ladder					; map data will be 2 (just ladder), or 3 (platform+ladder junction)
	LDX temp4
	LDY temp5
	JSR setmapblock			

	LDA #SpriteId_Ladder				; plot the ladder piece
	LDX temp4
	LDY temp5
	JSR plotspriteatcharpos
	
	INC temp5
	DEC temp6
	BPL putladderloop
	
	DEC temp3
	BNE putladdersloop
	
	; Deal with lift
	
	LDA liftflag:BEQ noliftonthismap
	LDY temp2
	INY
	LDA (mapdataptr),Y
	STY temp2
	ASL A:ASL A:ASL A:STA liftx
	.noliftonthismap
	
	; Deal with eggs
	
	LDA #EggColour:STA spritecolour
	LDA #0:STA temp3						; egg counter
	STA numeggsleft
	LDA playerdataoffset:STA temp1
	
	.puteggsloop
	LDY temp2
	INY
	LDA (mapdataptr),Y:STA temp4			; egg X
	INY
	LDA (mapdataptr),Y:STA temp5			; egg Y
	STY temp2
	
	; check whether the egg is collected already
	LDX temp1
	LDA collectedeggsflags,X
	BNE alreadycollectedegg
	
	; put egg on map (MapId_Egg + index<<4)
	LDA temp3:ASL A:ASL A:ASL A:ASL A
	ADC #MapId_Egg
	LDX temp4
	LDY temp5
	JSR setmapblock
	
	; draw egg
	LDA #SpriteId_Egg
	LDX temp4
	LDY temp5
	JSR plotspriteatcharpos
	
	INC numeggsleft
	
	.alreadycollectedegg
	INC temp1								; inc collectedeggs pointer
	INC temp3								; inc egg counter
	LDA temp3:CMP #12:BCC puteggsloop
	
	; Deal with seed
	
	LDA #SeedColour:STA spritecolour
	LDA #0:STA temp3
	LDA playerdataoffset:STA temp1
	
	.putseedloop
	LDY temp2
	INY
	LDA (mapdataptr),Y:STA temp4			; seed X
	INY
	LDA (mapdataptr),Y:STA temp5			; seed Y
	STY temp2
	
	; check whether the seed is collected already
	LDX temp1
	LDA collectedseedflags,X
	BNE alreadycollectedseed
	
	; put seed on map (MapId_Seed + index<<4)
	LDA temp3:ASL A:ASL A:ASL A:ASL A
	ADC #MapId_Seed
	LDX temp4
	LDY temp5
	JSR setmapblock
	
	; draw seed
	LDA #SpriteId_Seed
	LDX temp4
	LDY temp5
	JSR plotspriteatcharpos
	
	.alreadycollectedseed
	INC temp1
	INC temp3
	LDA temp3:CMP numseeds:BCC putseedloop
	
	; Deal with big bird
	
	LDA #CageColour:STA spritecolour
	
	; get screen address of cage
	LDX #0
	LDY #220
	JSR calcscrnaddr
	
	; get appropriate sprite (cage with or without hole)
	LDX #SpriteId_CageWithHole
	LDA bigbirdflag
	BEQ birdincage
	INX									; use empty cage instead
	.birdincage
	TXA
	JSR getspritedata
	JSR plotsprite
	
	; Deal with birds
	
	LDY temp2
	LDX #0
	.putbirdsloop
	INY
	LDA (mapdataptr),Y:STA birdcharx,X
	INY
	LDA (mapdataptr),Y:STA birdchary,X
	INX
	CPX #5
	BCC putbirdsloop
	RTS
	
	
;----------------------------------------------------------------------------------
;	Draw top status
;----------------------------------------------------------------------------------

.drawtopstatus
	
	LDA #StatusColour:STA spritecolour
	
	; Plot SCORE sprite
	LDX #0:LDY #248:JSR calcscrnaddr
	LDA #SpriteId_Score:JSR getspritedata
	JSR plotsprite
	
	; Plot highlight bar (on which the score digits are overlaid)
	LDX playernum		; player number 1-4
	LDA #0
	CLC
	.getplayerstatusxloop
	ADC #34
	DEX
	BPL getplayerstatusxloop
	SEC
	SBC #7
	TAX					; calculate X=playernum*34-7
	
	LDY #&F8
	JSR calcscrnaddr
	LDA #SpriteId_HighlightBox:JSR getspritedata
	JSR plotsprite
	
	; Plot score and lives for all players
	LDX #0:STX temp1
	.drawplayerscorelivesloop
	JSR drawplayerscorelives
	INC temp1
	LDX temp1
	CPX numplayers
	BCC drawplayerscorelivesloop
	
	LDA #StatusColour:STA spritecolour

	; Plot PLAYER sprite
	LDX #0:LDY #232:JSR calcscrnaddr
	LDA #SpriteId_Player:JSR getspritedata
	JSR plotsprite
	
	; Plot player digit
	LDX #27:LDY #231:JSR calcscrnaddr
	LDA playernum:CLC:ADC #SpriteId_Digit1:JSR getspritedata
	JSR plotsprite
	
	; Plot LEVEL sprite
	LDX #36:LDY #232:JSR calcscrnaddr
	LDA #SpriteId_Level:JSR getspritedata
	JSR plotsprite
	
	; Plot level number
	LDA #0:STA temp4:STA temp5
	LDX level
	INX
	STX temp6
	LDA temp6
	LDX #0
	.get10sloop
	CMP #10:BCC got10s
	SEC:SBC #10
	INX
	JMP get10sloop
	.got10s
	STA temp6						; units digit
	
	TXA
	LDX #0
	.get100sloop
	CMP #10:BCC got100s
	SEC:SBC #10
	INX
	JMP get100sloop
	.got100s
	STA temp5						; 10s digit
	STX temp4						; 100s digit
	
	LDA temp4:BEQ lessthanlevel100
	
	; Plot 100s digit
	LDX #59:LDY #231:JSR displaydigit
	.lessthanlevel100
	
	; Plot 10s digit
	LDA temp5
	LDX #64:LDY #231:JSR displaydigit
	
	; Plot units digit
	LDA temp6
	LDX #69:LDY #231:JSR displaydigit

	; Plot BONUS sprite
	LDX #78:LDY #232:JSR calcscrnaddr
	LDA #SpriteId_Bonus:JSR getspritedata
	JSR plotsprite
	
	; Plot bonus digits
	LDA bonus+0:LDX #102:LDY #231:JSR displaydigit
	LDA bonus+1:LDX #107:LDY #231:JSR displaydigit
	LDA bonus+2:LDX #112:LDY #231:JSR displaydigit
	LDA #0:LDX #117:LDY #231:JSR displaydigit
	
	; Plot TIME sprite
	LDX #126:LDY #232:JSR calcscrnaddr
	LDA #SpriteId_Time:JSR getspritedata
	JSR plotsprite
	
	; Set initial time and plot time digits
	LDA difficulty
	LSR A
	CMP #8:BCC P%+4:LDA #8			; cap to 8
	EOR #255:SEC:ADC #9				; 9-(difficulty/2 capped to 8)
	STA time
	LDX #145:LDY #231:JSR displaydigit
	
	LDA #0:STA time+1
	LDX #150:LDY #231:JSR displaydigit
	
	LDA #0:STA time+2
	LDX #155:LDY #231:JSR displaydigit
	
	RTS
	
	
;----------------------------------------------------------------------------------
;	Draw player X's score and lives
;----------------------------------------------------------------------------------

.drawplayerscorelives
	
	; Get x position for player X
	LDA #0
	CLC
	.mulby34
	ADC #34
	DEX
	BPL mulby34
	SEC
	SBC #7
	STA temp4								; temp4 = base x position for player X
	
	LDA #StatusColour:STA spritecolour
	
	; Get player X data offset
	LDA temp1
	ASL A:ASL A:ASL A:ASL A:ASL A:ASL A
	TAX:INX:INX
	STX temp6								; temp6 = score digits index
	
	LDX temp4:INX:STX temp5					; temp5 = x position of score
	
	; Draw score
	LDA #6:STA temp7						; digits counter
	.showscoreloop
	LDX temp6:LDA playerscore,X
	LDX temp5:LDY #247:JSR displaydigit
	LDA temp5:CLC:ADC #5:STA temp5
	INC temp6
	DEC temp7
	BNE showscoreloop
	
	; Draw lives
	LDA #LivesColour:STA spritecolour
	
	LDX temp1
	LDA lives,X
	BEQ nolivestodraw
	
	CMP #8:BCC P%+4:LDA #8					; cap drawn lives to 8
	STA temp7								; lives counter
	LDA temp4:STA temp5						; temp5 = x position of lives
	
	.showlivesloop
	LDX temp5:LDY #238:JSR calcscrnaddr
	LDA #SpriteId_Life:JSR getspritedata
	JSR plotsprite
	DEC temp7
	BEQ nolivestodraw
	LDA temp5:CLC:ADC #4:STA temp5
	JMP showlivesloop
	
	.nolivestodraw
	RTS
	

;----------------------------------------------------------------------------------
;	Handle player controls
;----------------------------------------------------------------------------------

.handleplayercontrols
	
	LDA #0
	STA movementx
	STA movementy
	
	; Set movement x/y according to keys pressed
	LDA keys	
	LSR A:BCC rightnotpressed:INC movementx:.rightnotpressed
	LSR A:BCC leftnotpressed:DEC movementx:.leftnotpressed	
	LSR A:BCC downnotpressed:DEC movementy:.downnotpressed
	LSR A:BCC upnotpressed:INC movementy:.upnotpressed
	
	ASL movementy
	
	; Depending on what we're doing, act on the controls
	LDA movementtype:BEQ onplatform			; movementtype=0 = on platform
	CMP #2:BNE notjumping
	JMP jumping								; movementtype=2 = jumping
	.notjumping
	BCS notclimbing
	JMP climbing							; movementtype=1 = climbing
	.notclimbing
	CMP #3:BNE notfalling
	JMP falling								; movementtype=3 = falling
	.notfalling
	JMP onlift								; movementtype=4 = on lift
	

;----------------------------------------------------------------------------------
;	Player on platform
;----------------------------------------------------------------------------------

.onplatform
	
	; Check jump
	LDA keys:AND #16:BEQ nottryingjump
	JMP attemptjump
	.nottryingjump
	
	; Check whether wanting to climb
	LDA movementy
	BEQ nottryingclimb
	
	; Attempt climb
	LDX playerfracx:CPX #3:BNE nottryingclimb		; if not precisely positioned, won't work
	LDA movementy:BMI attemptclimbdown
	
	; Check if we can climb up
	.attemptclimbup
	LDX playercharx
	LDY playerchary:INY:INY							; 2 chars above
	JSR getmapblock
	AND #MapId_Ladder
	BEQ nottryingclimb								; not on a ladder, won't work
	BNE doclimb										; all conditions met - do climb
	
	; Check if we can climb down
	.attemptclimbdown
	LDX playercharx
	LDY playerchary:DEY								; 1 char below
	JSR getmapblock
	AND #MapId_Ladder
	BEQ nottryingclimb								; not on a ladder, won't work
	
	; Do the climb
	.doclimb
	LDA #0:STA movementx							; prohibit horizontal movement when climbing
	LDA #1:STA movementtype							; movement type = climbing
	JMP platformmove
	
	; Attempt walk
	.nottryingclimb
	LDA #0:STA movementy							; walking - no y movement
	LDA playerfracx:CLC:ADC movementx
	LDX playercharx
	CMP #0:BPL P%+3:DEX
	CMP #8:BMI P%+3:INX
	LDY playerchary:DEY								; check the position underneath us
	JSR getmapblock
	AND #MapId_Platform
	BNE notfallingoffplatform
	
	; About to fall off a platform (we have to roll off the edge a little)
	TAY		; Y=0
	LDX #255
	LDA movementx:CLC:ADC playerfracx
	AND #7
	CMP #4
	BCS fallofftotheleft
	.fallofftotheright
	LDX #1
	INY
	.fallofftotheleft
	STX jumpdir										; direction we roll off the platform
	STY jumpfalldist			; ?????
	LDA #3:STA movementtype							; movement type = falling
	.notfallingoffplatform
	
	; Attempt horizontal movement
	JSR tryhorizontalmovement
	BCC platformmove
	LDA #0:STA movementx							; cancel horizontal movement
	
	; Finally, move the player
	.platformmove
	LDA movementx:BEQ playernotmoving
	STA playerfacingdir								; if trying to move, set facing dir to -1 or +1
	.playernotmoving
	JMP moveplayer
	
	
;----------------------------------------------------------------------------------
;	Player climbing
;----------------------------------------------------------------------------------

.climbing
	
	; Check jump
	LDA keys:AND #16:BEQ nottryingtojump2
	JMP attemptjump
	.nottryingtojump2
	
	; Check trying to leave ladder
	LDA movementx
	BEQ normalclimbing
	
	LDX playerfracy:BNE normalclimbing				; don't allow leaving ladder if not aligned
	
	LDX playercharx
	LDY playerchary:DEY								; check char below us
	JSR getmapblock
	AND #MapId_Platform
	BEQ normalclimbing								; if not a platform below us, can't leave the ladder
	
	LDA #0:STA movementy
	LDA #0:STA movementtype							; movement type = platform
	JMP laddermove
	
	; Normal up/down ladder movement
	.normalclimbing
	LDA #0:STA movementx							; disallow left/right movement
	LDA movementy:BEQ laddermove					; if no vertical movment, exit
	LDA playerfracy:BNE laddermove					; if between blocks, no need to check whether we can move or not
	LDA movementy:BMI climbingdown
	
	; Trying to go up
	.climbingup
	LDX playercharx
	LDY playerchary:INY:INY
	JSR getmapblock
	AND #MapId_Ladder
	BNE laddermove									; ladder above us, can move
	STA movementy									; movementy=0
	JMP laddermove
	
	; Trying to go down
	.climbingdown
	LDX playercharx
	LDY playerchary:DEY
	JSR getmapblock
	AND #MapId_Ladder
	BNE laddermove									; ladder below us, can move
	STA movementy									; movementy=0
	
	; Attempt ladder movement
	.laddermove
	LDA #0:STA playerfacingdir
	JMP moveplayer
	
	
;----------------------------------------------------------------------------------
;	Player jumping
;----------------------------------------------------------------------------------

.jumping
	
	LDA jumpdir:STA movementx					; force movementx to the jump direction
	LDA movementy:STA temp2						; temp2 = old movementy
	
	; get new movementy
	LDA jumpfalldist:LSR A:LSR A
	CMP #6:BCC P%+4:LDA #6						; cap at 6
	EOR #&FF:SEC:ADC #2							; 2-((jumpfalldist/4) capped to 6)
	STA movementy
	
	INC jumpfalldist
	
	; if hitting the top of the screen, bounce off
	LDA playery:CMP #220:BCC notjumpedtotopofscreen
	LDA #&FF:STA movementy
	LDA #&0C:STA jumpfalldist
	JMP checkjumponlift
	.notjumpedtotopofscreen
	
	; see if we are trying to catch a ladder mid-jump
	LDA playerfracx
	CLC:ADC movementx
	CMP #&03
	BNE notcatchingladdermidjump				; only bother to check this when we're ladder-aligned
	LDA temp2
	BEQ notcatchingladdermidjump				; up/down not pressed, don't try to catch ladder
	BMI trycatchladderpressingdown
	
	; comes here if we're trying to catch a ladder when pressing 'up'
	.trycatchladderpressingup
	LDX playercharx
	LDY playerchary:INY
	JSR getmapblock
	AND #MapId_Ladder
	BNE catchladderpressingup
	
	LDX playercharx
	LDY playerchary:INY
	LDA playerfracy
	CMP #&04:BCC P%+3:INY
	JSR getmapblock
	AND #MapId_Ladder
	BEQ notcatchingladdermidjump
	
	; caught it
	.catchladderpressingup
	LDA #&01:STA movementtype					; movement type = climbing
	LDA playerfracy:CLC:ADC movementy
	AND #&01
	BEQ alreadyalignedok1
	INC movementy								; small pixel adjustment to correctly y align with ladder
	.alreadyalignedok1
	JMP jumpmove

	; comes here if we're trying to catch a ladder when pressing 'down'
	.trycatchladderpressingdown
	LDX playercharx
	LDY playerchary
	JSR getmapblock
	AND #MapId_Ladder
	BEQ notcatchingladdermidjump
	
	LDX playercharx
	LDY playerchary:INY
	JSR getmapblock
	AND #MapId_Ladder
	BEQ notcatchingladdermidjump
	
	; caught it
	LDA #&01:STA movementtype					; movement type = climbing
	LDA playerfracy:CLC:ADC movementy
	AND #&01
	BEQ alreadyalignedok2
	DEC movementy								; small pixel adjustment to correctly y align with ladder
	.alreadyalignedok2
	JMP jumpmove

	; comes here if we're not trying to catch a ladder mid-jump
	.notcatchingladdermidjump
	
	LDA movementy:CLC:ADC playerfracy
	BEQ jumponyboundary
	BPL jumpaboveyboundary
	
	; we have moved below the y boundary below
	.jumpbelowyboundary
	LDX playercharx
	LDY playerchary:DEY							; check character below
	JSR getmapblock
	AND #MapId_Platform
	BEQ checkjumponlift							; nothing impeding - move
	LDA #0:STA movementtype						; we are about to land on a platform
	LDA #0:SEC:SBC playerfracy:STA movementy	; cut short the y movement accordingly
	JMP checkjumponlift
	
	; we are exactly aligned with the y boundary
	.jumponyboundary
	LDX playercharx
	LDY playerchary:DEY							; check character below
	JSR getmapblock
	AND #MapId_Platform
	BEQ checkjumponlift
	LDA #0:STA movementtype						; we have just landed on a platform
	JMP checkjumponlift
	
	; we are moving above the y boundary
	.jumpaboveyboundary
	CMP #8:BNE checkjumponlift
	LDX playercharx
	LDY playerchary
	JSR getmapblock
	AND #MapId_Platform
	BEQ checkjumponlift
	LDA #0:STA movementtype						; we have just jumped up to meet a platform
	JMP checkjumponlift
	
	; Check jumping onto lift
	.checkjumponlift
	LDA liftflag:BEQ nolifttolandon
	
	; Check collision with lift
	LDA liftx
	SEC:SBC #1
	CMP playerx:BCS nolifttolandon
	ADC #10
	CMP playerx:BCC nolifttolandon
	
	LDA playery:SEC:SBC #17:STA temp4			; temp4 = y position just below player's feet
	SBC #2:CLC:ADC movementy:STA temp5			; temp5 = bottom limit that would catch lift
	
	; Check collision with lift 1
	LDA lift1y:CMP temp4
	BEQ hitlift1
	BCS checklift2
	CMP temp5
	BCC checklift2
	
	; Hit lift 1
	.hitlift1
	LDX whichlift:BNE adjustlift1pos
	CLC:ADC #1									; lifts are updated on alternate frames, so adjust if necessary
	.adjustlift1pos
	JMP moveupwithlift

	; Check collision with lift 2
	.checklift2
	LDA lift2y:CMP temp4
	BEQ hitlift2
	BCS nolifttolandon
	CMP temp5
	BCC nolifttolandon
	
	; Hit lift 2
	.hitlift2
	LDX whichlift:BEQ moveupwithlift
	CLC:ADC #1
	
	; Move up with the lift
	.moveupwithlift
	SEC:SBC temp4:CLC:ADC #1:STA movementy		; adjust movement vector to land player perfectly on lift
	LDA #0:STA jumpfalldist
	LDA #4:STA movementtype						; movement type = on lift
	JMP jumpmove
	
	.nolifttolandon
	JSR tryhorizontalmovement
	BCC jumpmove								; horizontal movement ok - move
	
	; Something impeded horizontal movement, so bounce off the side
	LDA #0:SEC:SBC movementx:STA movementx
	STA jumpdir
	
	.jumpmove
	JMP moveplayer
	

;----------------------------------------------------------------------------------
;	Player attempting to jump
;----------------------------------------------------------------------------------

.attemptjump
	
	LDA #0:STA jumpfalldist
	LDA #2:STA movementtype						; movement type = jumping
	LDA movementx:STA jumpdir
	BEQ jumpkeepcurrentdir						; if jumping straight up, don't change facing dir
	STA playerfacingdir
	.jumpkeepcurrentdir
	JMP jumping
	

;----------------------------------------------------------------------------------
;	Player falling
;----------------------------------------------------------------------------------

.falling
	
	INC jumpfalldist
	LDA jumpfalldist:CMP #4:BCS fallstraightdown
	
	; at the beginning of the fall, roll off the platform we came from
	LDA jumpdir:STA movementx
	LDA #255:STA movementy
	JMP fallingmain
	
	; this is the 'proper' falling
	.fallstraightdown
	LDA #0:STA movementx
	LDA jumpfalldist:LSR A:LSR A
	CMP #4:BCC P%+4:LDA #3
	EOR #255:STA movementy						; movementy = -1 - ((justfalldist/4) capped to 3)
	
	; check for collisions while falling
	.fallingmain
	LDA movementy:CLC:ADC playerfracy
	BEQ fallingonyboundary
	BPL fallingmove
	
	; we have crossed the y boundary below
	.fallingbelowyboundary
	LDX playercharx
	LDY playerchary:DEY							; check block below
	JSR getmapblock
	AND #MapId_Platform
	BEQ fallingmove								; if empty, fall
	
	; we have landed on a platform
	LDA #0:STA movementtype						; movementtype = on platform
	LDA #0:SEC:SBC playerfracy:STA movementy	; align with platform
	JMP fallingmove
	
	; we are aligned with a y boundary
	.fallingonyboundary
	LDX playercharx
	LDY playerchary:DEY							; check block below
	JSR getmapblock
	AND #MapId_Platform
	BEQ fallingmove								; if empty, fall

	; we have landed on a platform
	LDA #0:STA movementtype						; movementtype = on platform
	
	.fallingmove
	JMP moveplayer
	
	
;----------------------------------------------------------------------------------
;	Player on lift
;----------------------------------------------------------------------------------

.onlift
	
	; Check for jump
	LDA keys:AND #&10:BEQ notjumpingfromlift
	JMP attemptjump
	.notjumpingfromlift

	; Check whether player is still on lift
	LDA liftx
	SEC:SBC #1
	CMP playerx:BCS playermovedofflift
	ADC #10
	CMP playerx:BCS playerstillonlift
	
	; Player is not on lift, start falling next frame
	.playermovedofflift
	LDA #0:STA jumpfalldist
	STA jumpdir
	LDA #3:STA movementtype						; movementtype = falling

	; Move up with lift
	.playerstillonlift
	LDA #1:STA movementy
	LDA movementx:BEQ notmovingonlift
	STA playerfacingdir
	.notmovingonlift
	
	; Deal with any sideways player movement on lift
	JSR tryhorizontalmovement
	BCC dontimpedemovementonlift
	LDA #0:STA movementx						; could not move sideways so block movement
	.dontimpedemovementonlift
	
	; Check whether player is crushed at the top of the screen
	LDA playery:CMP #220
	BCC moveplayer
	INC playerdieflag							; kill player
	
	
;----------------------------------------------------------------------------------
;	MOVE THE PLAYER
;----------------------------------------------------------------------------------

.moveplayer
	
	; Unplot player old frame
	LDA playerspritenum:JSR plotplayer
	
	; Move player x
	LDA playerx:CLC:ADC movementx:STA playerx
	LDA playerfracx:CLC:ADC movementx
	BPL P%+4:DEC playercharx
	CMP #8:BMI P%+4:INC playercharx
	AND #7:STA playerfracx
	
	; Move playery
	LDA playery:CLC:ADC movementy:STA playery
	LDA playerfracy:CLC:ADC movementy
	BPL P%+4:DEC playerchary
	CMP #8:BMI P%+4:INC playerchary
	AND #7:STA playerfracy
	
	; Get new player animation frame
	LDX #SpriteId_ManRight1
	LDA playerfacingdir:BEQ playerupdownanim
	BPL playerrightanim
	LDX #SpriteId_ManLeft1
	.playerrightanim
	STX temp1									; temp1 = animation frame base
	LDA playerfracx:LSR A:JMP calcplayeranim
	
	.playerupdownanim
	LDA #SpriteId_ManUpDown1
	STA temp1									; temp1 = animation frame base
	LDA playerfracy:LSR A
	
	.calcplayeranim
	LDX #2:STX temp2
	BIT temp2									; test A AND 2
	BEQ first2frames
	AND #1:ASL A								; so that anim sequence is 0, 1, 0, 2
	.first2frames
	
	LDX movementtype:CPX #1:BNE animnotclimbing
	
	; Prepare climbing anims
	LDX movementy:BNE makeplayeranim
	LDA #0										; if not moving, no animation
	JMP makeplayeranim
	
	; Other anims
	.animnotclimbing
	LDX movementx:BNE makeplayeranim
	LDA #0										; if not moving, no animation
	
	; Build the actual animation frame
	.makeplayeranim
	CLC:ADC temp1:STA playerspritenum
	JSR plotplayer
	
	; Now test for picking up things
	LDX playercharx
	LDY playerchary
	LDA playerfracy:CMP #4:BCC P%+3:INY			; test the block above if more than midway through in Y
	STY temp2
	JSR getmapblock
	STA temp1
	AND #MapId_Egg OR MapId_Seed
	BEQ exitplayermove
	
	AND #MapId_Seed:BNE hitseed
	
	; Player hit an egg
	DEC numeggsleft

	; Make egg collected sound
	LDA #6:STA eggsoundblock+4
	LDX #LO(eggsoundblock)
	LDY #HI(eggsoundblock)
	LDA #7
	JSR osword
	
	; Remove egg from player's flags
	LDA temp1:LSR A:LSR A:LSR A:LSR A			; get egg number
	CLC
	ADC playerdataoffset
	TAX
	DEC collectedeggsflags,X					; collect this player's egg

	; Unplot the egg
	LDX playercharx
	LDY temp2
	JSR removeegg
	
	; Score points
	LDA level:LSR A:LSR A
	CLC:ADC #1
	CMP #10:BCC P%+4:LDA #10
	LDX #5
	JSR addscore								; gain 100-1000 points (depending on level)
	JMP exitplayermove
	
	; Player hit a seed
	.hitseed
	
	; Make seed collected sound
	LDA #5:STA eggsoundblock+4
	LDX #LO(eggsoundblock)
	LDY #HI(eggsoundblock)
	LDA #7
	JSR osword
	
	; Remove seed from player's flags
	LDA temp1:LSR A:LSR A:LSR A:LSR A			; get seed number
	CLC
	ADC playerdataoffset
	TAX
	DEC collectedseedflags,X
	
	; Unplot the seed
	LDX playercharx
	LDY temp2
	JSR removeseed
	
	; Score points
	LDA #5
	LDX #6
	JSR addscore
	
	; Stall time countdown for 20 updates
	LDA #20:STA stalltime
	
	.exitplayermove
	RTS
	
	

;----------------------------------------------------------------------------------
;	Check whether player can move horizontally in the direction of movementx
;	Returns C clear if ok
;----------------------------------------------------------------------------------

.tryhorizontalmovement
	
	LDA movementx
	BMI tryleftmovement
	BNE tryrightmovement
	CLC										; no movement; always succeeds
	RTS

	
.tryleftmovement
	
	; If at the extreme left of the screen, fail
	LDA playerx:CMP #1:BCC horizmovefailed
	
	; If midblock, succeed
	LDA playerfracx:CMP #2:BCS horizmovesucceeded
	
	; If movementy is 2, succeed (I don't know why this is true)
	LDA movementy:CMP #2:BEQ horizmovesucceeded
	
	; Now test map to see if we can move
	LDX playercharx:DEX
	LDY playerchary
	LDA playerfracy:CLC:ADC movementy
	CMP #8
	BCC trylefttestblock
	BPL trylefttestblockabove
	DEY										; test block below
	JMP trylefttestblock
	.trylefttestblockabove
	INY										; test block above
	.trylefttestblock
	JSR getmapblock
	CMP #MapId_Platform
	BEQ horizmovefailed						; fail if JUST a platformn
	LDA movementy
	BPL horizmovesucceeded					; if not going down, always succeed

	LDX playercharx:DEX
	INY										; if going up, check the block above
	JSR getmapblock
	CMP #MapId_Platform						; check if JUST a platform
	BEQ horizmovefailed						; yes, failed
	BNE horizmovesucceeded					; no, success
	
	
.tryrightmovement
	
	; If at the extreme right of the screen, fail
	LDA playerx:CMP #152:BCS horizmovefailed
	
	; If midblock, succeed
	LDA playerfracx:CMP #5:BCC horizmovesucceeded
	
	; If movementy is 2, succeed (I don't know why this is true)
	LDA movementy:CMP #2:BEQ horizmovesucceeded
	
	; Now test map to see if we can move
	LDX playercharx:INX
	LDY playerchary
	LDA playerfracy:CLC:ADC movementy
	CMP #8
	BCC tryrighttestblock
	BPL tryrighttestblockabove
	DEY										; test block below
	JMP tryrighttestblock
	.tryrighttestblockabove
	INY										; test block above
	.tryrighttestblock
	JSR getmapblock
	CMP #MapId_Platform
	BEQ horizmovefailed
	LDA movementy
	BPL horizmovesucceeded
	
	LDX playercharx:INX
	INY
	JSR getmapblock
	CMP #MapId_Platform
	BEQ horizmovefailed
	
.horizmovesucceeded
	CLC:RTS
	
.horizmovefailed
	SEC:RTS
	
	

;----------------------------------------------------------------------------------
;	Unplots an egg
;----------------------------------------------------------------------------------

.removeegg
	
	TXA:PHA
	LDA #0:JSR setmapblock
	LDA #EggColour:STA spritecolour
	PLA:TAX
	LDA #SpriteId_Egg
	JSR plotspriteatcharpos
	RTS
	
	

;----------------------------------------------------------------------------------
;	Unplots seed
;----------------------------------------------------------------------------------

.removeseed
	
	TXA:PHA
	LDA #0:JSR setmapblock
	LDA #SeedColour:STA spritecolour
	PLA:TAX
	LDA #SpriteId_Seed
	JSR plotspriteatcharpos
	RTS



;----------------------------------------------------------------------------------
;	Plots player, frame A
;----------------------------------------------------------------------------------
	
.plotplayer
	
	LDX #PlayerColour:STX spritecolour
	JSR getspritedata
	LDX playerx
	LDY playery
	JSR calcscrnaddr
	JSR plotsprite
	RTS
	
	
	
;----------------------------------------------------------------------------------
;	Plots big bird, frame A
;----------------------------------------------------------------------------------

.plotbigbird
	
	LDX #BigBirdColour:STX spritecolour
	CLC:ADC #SpriteId_BigBirdRight1
	JSR getspritedata
	LDX bigbirdxpos
	LDY bigbirdypos
	JSR calcscrnaddr
	JSR plotsprite
	RTS
	


;----------------------------------------------------------------------------------
;	Plots bird
;----------------------------------------------------------------------------------

.plotbird
	
	LDX #BirdColour:STX spritecolour
	LDX temp1
	LDA birdanim,X
	CLC:ADC #SpriteId_BirdRight1
	PHA
	JSR getspritedata
	LDX temp1
	LDA birdpixelx,X
	LDY birdpixely,X
	TAX
	PLA
	CMP #SpriteId_BirdEatLeft1
	BCC noteatingtoleft
	
	; bird eating left anims need to be drawn 8 pixels to the left
	TXA:SBC #8:TAX		; C already set
	.noteatingtoleft
	
	JSR calcscrnaddr
	JSR plotsprite
	RTS



;----------------------------------------------------------------------------------
;	Moves a lift (different one each call)
;----------------------------------------------------------------------------------

.movelift
	
	; If no lift, do nothing
	LDA liftflag:BEQ exitmovelift
	
	; Get y pos of the lift we're moving
	LDY lift1y
	LDA whichlift:BEQ movelift1
	LDY lift2y
	.movelift1
	STY temp2
	
	LDA #LiftColour:STA spritecolour

	; Unplot old lift
	LDA #SpriteId_Lift:JSR getspritedata
	LDX liftx
	LDY temp2
	JSR calcscrnaddr
	JSR plotsprite
	
	; Move lift
	INC temp2:INC temp2
	LDA temp2:CMP #224:BNE liftstillonscreen
	LDA #6:STA temp2
	.liftstillonscreen
	
	; Plot new lift
	LDA #SpriteId_Lift:JSR getspritedata
	LDX liftx
	LDY temp2
	JSR calcscrnaddr
	JSR plotsprite
	
	; Store new y pos
	LDA whichlift:BEQ updatelift1
	LDA temp2:STA lift2y
	JMP togglelift
	.updatelift1
	LDA temp2:STA lift1y
	
	; Toggle current lift
	.togglelift
	LDA whichlift:EOR #255:STA whichlift
	
	.exitmovelift
	RTS
	
	

;----------------------------------------------------------------------------------
;	Get map block at X,Y into A
;----------------------------------------------------------------------------------

.getmapblock
	
	CPY #25:BCS offscreen
	CPX #20:BCS offscreen
	JSR calcmapaddr
	BCS readmapdatahi
	
	.readmapdatalo
	LDA mapdata,X
	RTS
	
	.readmapdatahi
	LDA mapdata+&100,X
	RTS
	
	.offscreen
	LDA #0
	RTS



;----------------------------------------------------------------------------------
;	Sets map block at X,Y to A
;----------------------------------------------------------------------------------

.setmapblock
	
	JSR calcmapaddr
	BCS writemapdatahi
	
	.writemapdatalo
	STA mapdata,X
	RTS
	
	.writemapdatahi
	STA mapdata+&100,X
	RTS
	

;----------------------------------------------------------------------------------
;	Calculates map data address of block X,Y
;	Returns offset in 256*C+X
;	Preserves A
;----------------------------------------------------------------------------------

.calcmapaddr
	
	PHA
	
	; Calculate Y*20
	STY temp7
	TYA:ASL A:ASL A
	ADC temp7
	ASL A:ASL A
	
	; ...and add X
	PHP
	CLC
	STA temp7
	TXA:ADC temp7:TAX
	BCS exitwithcset
	
	; exit with C according to the results of Y*20
	PLP:PLA
	RTS

	; exit with C set regardless
	.exitwithcset
	PLA:PLA
	RTS


	
;----------------------------------------------------------------------------------
;	Update birds
;----------------------------------------------------------------------------------

.updatebirds
	
	; Only move birds every 8 updates
	INC updatetimer
	LDA updatetimer
	CMP #8
	BNE dontmovebigbird
	
	; Reset timer and move big bird
	LDA #0:STA updatetimer
	JMP movebigbird
	
	.dontmovebigbird
	CMP #4
	BNE P%+5:JMP decreasetime		; if not the 4th tick, just decrease time
	JMP movebirds					; move walking birds every 8 updates, on the 4th tick
	
	
;----------------------------------------------------------------------------------
;	Update big bird
;----------------------------------------------------------------------------------

.movebigbird
	
	; Save facing direction
	LDA bigbirdanim:AND #2:STA temp4		; temp4 = facing direction

	; If there's no big bird flying, skip the movement code
	LDA bigbirdflag:BEQ animatebigbird
	
	; Move big bird horizontally
	LDA bigbirdxpos:CLC:ADC #4
	CMP playerx:BCS movebigbirdleft
	
	.movebigbirdright
	INC bigbirdxspeed						; Increment xspeed, to a maximum of 5
	LDA bigbirdxspeed:CMP #6
	BMI P%+4:DEC bigbirdxspeed
	LDA #0:STA temp4						; Bird faces right
	JMP movebigbirdvertically
	
	.movebigbirdleft
	DEC bigbirdxspeed						; Decrement xspeed, to a minimum of -5
	LDA bigbirdxspeed:CMP #256-5
	BPL P%+4:INC bigbirdxspeed
	LDA #2:STA temp4						; Bird faces left
	
	; Move big bird vertically
	.movebigbirdvertically
	LDA playery:CLC:ADC #4
	CMP bigbirdypos:BCC movebigbirddown
	
	.movebigbirdup
	INC bigbirdyspeed						; Increment yspeed, to a maximum of 5
	LDA bigbirdyspeed:CMP #6
	BMI P%+4:DEC bigbirdyspeed
	JMP bigbirdbounce
	
	.movebigbirddown
	DEC bigbirdyspeed						; Decrement yspeed, to a minimum of -5
	LDA bigbirdyspeed:CMP #256-5
	BPL P%+4:INC bigbirdyspeed
	
	; Bounce big bird off the bottom of the screen
	.bigbirdbounce
	LDA bigbirdypos:CLC:ADC bigbirdyspeed
	CMP #40
	BCS dontbounceoffbottom
	
	LDA bigbirdyspeed:EOR #255:STA bigbirdyspeed
	INC bigbirdyspeed
	.dontbounceoffbottom
	
	; Bounce big bird off the sides of the screen
	LDA bigbirdxpos:CLC:ADC bigbirdxspeed
	CMP #160-16
	BCC animatebigbird
	
	LDA bigbirdxspeed:EOR #255:STA bigbirdxspeed
	INC bigbirdxspeed

	
.animatebigbird
	
	LDA bigbirdanim
	JSR plotbigbird							; Unplot old bird
	
	LDA bigbirdxpos:CLC:ADC bigbirdxspeed:STA bigbirdxpos
	LDA bigbirdypos:CLC:ADC bigbirdyspeed:STA bigbirdypos
	
	LDA bigbirdanim:AND #1:EOR #1:ORA temp4:STA bigbirdanim
	JSR plotbigbird							; Plot new bird
	
	RTS
	

;----------------------------------------------------------------------------------
;	Update walking birds
;----------------------------------------------------------------------------------

.movebirds
	
	DEC currentbirdindex
	LDX currentbirdindex
	BPL dontresetbirdindex
	
	; Reset index to walking speed... if this is greater than the number of birds, it'll do
	; nothing for the excess updates
	LDX birdwalkingspeed
	STX currentbirdindex
	.dontresetbirdindex
	
	CPX numbirds
	BCC movebird
	RTS
	
	
.movebird
	
	STX temp1								; temp1 = current bird number
	
	LDA birdstatus,X
	CMP #1
	BNE birddosomething
	JMP animatebird							; every other frame, do nothing
	
	.birddosomething
	BCC birdwalking							; birdstatus=0; normal movement
	JMP birdeatingseed						; birdstatus>1; eating seed


.birdwalking
	
	LDA birdcharx,X:STA temp4
	LDA birdchary,X:STA temp5
	LDA #0:STA temp6
	
	; Test block below left
	LDX temp4
	LDY temp5
	DEX
	DEY
	JSR getmapblock
	AND #MapId_Platform
	BEQ noplatformtotheleft
	STA temp6								; bit 0 = platform to the left
	.noplatformtotheleft
	
	; Test block below right
	LDX temp4
	LDY temp5
	INX
	DEY
	JSR getmapblock
	AND #MapId_Platform
	BEQ noplatformtotheright
	LDA #2:ORA temp6:STA temp6				; bit 1 = platform to the right
	.noplatformtotheright
	
	; Test block directly below
	LDX temp4
	LDY temp5
	DEY
	JSR getmapblock
	AND #MapId_Ladder
	BEQ noladderbelow
	LDA #8:ORA temp6:STA temp6				; bit 3 = ladder directly below
	.noladderbelow
	
	; Test block above
	LDX temp4
	LDY temp5
	INY:INY
	JSR getmapblock
	AND #MapId_Ladder
	BEQ noladderabove
	LDA #4:ORA temp6:STA temp6				; bit 2 = ladder above
	.noladderabove
	
	; Look at possible movement options
	JSR countsetbits
	CPX #1:BNE morethanonechoice
	
	; Only one direction possible
	LDA temp6
	LDX temp1
	STA birddir,X
	JMP birdgotdirection
	
	; If more than one direction, first consider only those which don't double back on ourselves
	.morethanonechoice
	LDX temp1
	LDA birddir,X
	CMP #4:BCS birdmovingupdown
	EOR #&FC								; consider current direction + up/down
	JMP birdmovingleftright
	.birdmovingupdown
	EOR #&F3								; consider current direction + left/right
	.birdmovingleftright
	AND temp6								; mask with valid directions
	STA temp6								; and store as new valid directions
	JSR countsetbits
	CPX #1:BNE stillmorethanonechoice
	
	; Have settled at one choice - use it
	LDX temp1
	LDA temp6
	STA birddir,X
	JMP birdgotdirection
	
	; Still a choice - roll a dice....
	.stillmorethanonechoice
	LDA temp6:STA temp7
	.tryrandomdirectionloop
	JSR rnd									; mask valid directions with random number until we get a value with only one bit set
	LDA rndseed:AND temp7:STA temp6
	JSR countsetbits
	CPX #1:BNE tryrandomdirectionloop
	
	LDX temp1
	LDA temp6
	STA birddir,X
	
.birdgotdirection
	LDX temp1
	LDA birddir,X
	AND #3:BEQ animatebird
	AND #1:BEQ newbirddirright
	
	; Move bird left
	LDX temp4
	LDY temp5
	DEX
	JSR getmapblock
	JMP birdmovedhorizontally
	
	; Move bird right
	.newbirddirright
	LDX temp4
	LDY temp5
	INX
	JSR getmapblock
	
	.birdmovedhorizontally
	AND #MapId_Seed
	BEQ animatebird							; if not a seed, actually move and animate the bird
	LDX temp1
	LDA #2:STA birdstatus,X					; Initiate eating seed
	JMP animatebird
	
	
	; Counts number of set bits in temp6
	
.countsetbits
	LDX #0
	LDA temp6
	.countsetbitsloop
	LSR A
	BCC P%+3:INX
	CMP #0
	BNE countsetbitsloop
	RTS
	
	; Eat the seed here
	
.birdeatingseed
	CMP #4:BNE animatebird
	
	; just ate seed - first find seed position
	LDA birddir,X
	LDY birdcharx,X:STY temp4
	LDY birdchary,X:STY temp5
	LDX temp4:DEX							; assume the seed is to the left
	AND #1:BNE foundseedpos					; if moving right, it must be to the right
	INX:INX
	.foundseedpos
	STX temp6
	JSR getmapblock
	STA temp2
	AND #MapId_Seed
	BEQ animatebird							; If no seed, it means the player collected it already
	
	; remove the seed from the game
	LDA temp2:LSR A:LSR A:LSR A:LSR A
	CLC
	ADC playerdataoffset
	TAX
	DEC collectedseedflags,X
	LDX temp6
	LDY temp5
	JSR removeseed

	; Move and animate the bird
	
.animatebird
	
	JSR plotbird
	
	LDX temp1
	LDA birdstatus,X
	CMP #2:BCS animatebirdeating
	
	LDA birddir,X
	LSR A:BCS animatebirdleft
	LSR A:BCS animatebirdright
	LSR A:BCS animatebirdup
	
	.animatebirddown
	LDA birdpixely,X:SEC:SBC #4:STA birdpixely,X	; move down 4 pixels
	LDA birdstatus,X:BEQ animatebirddown2			; every other frame (bit 0), moves down a char
	DEC birdchary,X:.animatebirddown2
	LDA #SpriteId_BirdUpDown1 - SpriteId_BirdRight1
	JMP animatebird2
	
	.animatebirdup
	LDA birdpixely,X:CLC:ADC #4:STA birdpixely,X	; move up 4 pixels
	LDA birdstatus,X:BEQ animatebirdup2
	INC birdchary,X:.animatebirdup2
	LDA #SpriteId_BirdUpDown1 - SpriteId_BirdRight1
	JMP animatebird2
	
	.animatebirdleft
	LDA birdpixelx,X:SEC:SBC #4:STA birdpixelx,X	; move left 4 pixels
	LDA birdstatus,X:BEQ animatebirdleft2
	DEC birdcharx,X:.animatebirdleft2
	LDA #SpriteId_BirdLeft1 - SpriteId_BirdRight1
	JMP animatebird2
	
	.animatebirdright
	LDA birdpixelx,X:CLC:ADC #4:STA birdpixelx,X	; move right 4 pixels
	LDA birdstatus,X:BEQ animatebirdright2
	INC birdcharx,X:.animatebirdright2
	LDA #SpriteId_BirdRight1 - SpriteId_BirdRight1
	JMP animatebird2								; silly
	
	.animatebird2
	STA birdanim,X
	LDA birdstatus,X:EOR #1:STA birdstatus,X
	CLC:ADC birdanim,X:STA birdanim,X
	JSR plotbird
	RTS
	
	.animatebirdeating
	LDA birdstatus,X
	ASL A
	AND #31
	STA birdstatus,X
	BEQ finishedeating
	LDA #SpriteId_BirdEatRight1 - SpriteId_BirdRight1
	.finishedeating

	LDY birddir,X:CPY #1:BNE eatingright
	CLC:ADC #2
	.eatingright
	
	LDY birdstatus,X:CPY #8:BNE eatingsecondframe
	CLC:ADc #1
	.eatingsecondframe
	
	STA birdanim,X
	JSR plotbird
	RTS
	


;----------------------------------------------------------------------------------
;	Decrease the timer
;----------------------------------------------------------------------------------

.decreasetime
	
	LDA #DigitsColour:STA spritecolour
	LDA stalltime:BEQ dodecreasetime
	DEC stalltime
	RTS
	

.dodecreasetime
	
	; Decrease time and update digits
	LDX #2:STX temp1
	.decreasetimeloop
	JSR showtimedigit
	LDX temp1:DEC time,X
	PHP
	BPL timenocarry
	LDA #9:STA time,X
	.timenocarry
	JSR showtimedigit
	DEC temp1
	PLP
	BMI decreasetimeloop
	
	; If reached zero, kill the player
	CLC
	LDA time:ADC time+1:ADC time+2
	BNE timenotzero
	INC playerdieflag
	RTS
	
	; Every 5 time ticks, decrement bonus
	.timenotzero
	LDA time+2:BEQ decreasebonus		; time MOD 10 = 0
	CMP #5:BEQ decreasebonus			; time MOD 5 = 0
	RTS
	
	.decreasebonus
	LDA bonusexpiredflag:BEQ dodecreasebonus
	RTS
	
	; Decrease bonus and update digits
	.dodecreasebonus
	LDX #2:STX temp1
	.decreasebonusloop
	JSR showbonusdigit
	LDX temp1:DEC bonus,X
	PHP
	BPL bonusnocarry
	LDA #9:STA bonus,X
	.bonusnocarry
	JSR showbonusdigit
	DEC temp1
	PLP
	BMI decreasebonusloop
	
	CLC
	LDA bonus:ADC bonus+1:ADC bonus+2
	BNE exitdecreasebonus
	INC bonusexpiredflag
	.exitdecreasebonus
	RTS
	
	
;----------------------------------------------------------------------------------
;	Show a digit of the time remaining (temp1 = which digit)
;----------------------------------------------------------------------------------

.showtimedigit

	LDA temp1:TAY
	ASL A:ASL A:ADC temp1:ADC #145:TAX		; x position of digit
	LDA time,Y
	LDY #231								; y position of digit
	JSR displaydigit
	RTS


;----------------------------------------------------------------------------------
;	Show a digit of the bonus (temp1 = which digit)
;----------------------------------------------------------------------------------
	
.showbonusdigit

	LDA temp1:TAY
	ASL A:ASL A:ADC temp1:ADC #102:TAX		; x position of digit
	LDA bonus,Y
	LDY #231								; y position of digit
	JSR displaydigit
	RTS
	
	

;----------------------------------------------------------------------------------
;	Collision detection routines
;----------------------------------------------------------------------------------

.checkcollisions

	LDA numbirds:BEQ checkcollisionbigbird
	
	; Check collision with walking birds
	LDA #0:STA temp3
	.checkcollisionbirdloop
	LDX temp3									; temp3 = bird number
	
	; Check overlap in X
	LDA birdpixelx,X:SEC:SBC playerx
	CLC:ADC #5
	CMP #11:BCS birdnotcollided					; not this one, skip straight to next one
	
	; Check overlap in Y
	LDA birdpixely,X:SEC:SBC #1:SBC playery
	CLC:ADC #14
	CMP #29:BCS birdnotcollided
	
	; Collided with a bird!
	INC playerdieflag
	
	.birdnotcollided
	INC temp3:LDA temp3:CMP numbirds
	BCC checkcollisionbirdloop
	
	; Check collision with big bird
	.checkcollisionbigbird
	LDA bigbirdflag:BEQ exitcheckcollisions
	
	; Check overlap in X
	LDA bigbirdxpos:CLC:ADC #4
	SEC:SBC playerx
	CLC:ADC #5
	CMP #11:BCS exitcheckcollisions
	
	; Check overlap in Y
	LDA bigbirdypos:SEC:SBC #5
	SBC playery
	CLC:ADC #14
	CMP #29:BCS exitcheckcollisions
	
	; Collided with the big bird
	INC playerdieflag
	
	.exitcheckcollisions
	RTS
	

;----------------------------------------------------------------------------------
;	High score routines - find high score entry X
;	Address returned in (hiscoreaddr)
;----------------------------------------------------------------------------------

.gethiscoreaddr

	LDA #0:STA hiscoreaddr+1
	DEX:TXA
	ASL A:ASL A
	ASL A:ROL hiscoreaddr+1
	ASL A:ROL hiscoreaddr+1
	CLC
	ADC #LO(hiscoretab):STA hiscoreaddr
	LDA hiscoreaddr+1
	ADC #HI(hiscoretab):STA hiscoreaddr+1
	RTS


;----------------------------------------------------------------------------------
;	Reset all hiscores to 1000 "A&F"
;----------------------------------------------------------------------------------

.resethiscoretab

	LDA #10:STA temp3
	
	.resethiscoretabloop
	LDX temp3
	JSR gethiscoreaddr
	
	; initialise high score name
	LDY #15
	LDA #' '
	.clearhiscorenameloop
	STA (hiscoreaddr),Y
	DEY
	CPY #10
	BNE clearhiscorenameloop
	
	LDA #'F':STA (hiscoreaddr),Y:DEY
	LDA #'&':STA (hiscoreaddr),Y:DEY
	LDA #'A':STA (hiscoreaddr),Y:DEY
	
	; initialise high score (00001000)
	LDA #0
	.clearhiscoreloop
	STA (hiscoreaddr),Y
	DEY:BPL clearhiscoreloop
	LDA #1:LDY #4:STA (hiscoreaddr),Y
	
	DEC temp3:BNE resethiscoretabloop
	RTS


;----------------------------------------------------------------------------------
;	Check if we have a new high score, and insert it into the correct place
;	in the high score table
;----------------------------------------------------------------------------------

.checknewhiscore

	LDA #1:STA temp3						; temp3 = high score index
	
	.checknewhiscoreloop
	LDX temp3
	JSR gethiscoreaddr
	
	LDY #0
	.comparescoreloop
	LDA (hiscoreaddr),Y
	CMP score,Y
	BMI inserthiscore						; if our score is higher, shuffle the others down and put the new high score here
	BNE checknexthiscore
	INY:CPY #8
	BNE comparescoreloop
	
	.checknexthiscore
	INC temp3
	LDA temp3:CMP #11
	BCC checknewhiscoreloop
	RTS

	; Insert new high score here
	
.inserthiscore

	JSR shufflehiscores

	; copy score
	LDY #7
	.inserthiscoreloop
	LDA score,Y
	STA (hiscoreaddr),Y
	DEY
	BPL inserthiscoreloop
	
	; clear name
	LDY #15
	LDA #' '
	.insertblanknameloop
	STA (hiscoreaddr),Y
	DEY
	CPY #7
	BNE insertblanknameloop
	RTS
	
	
;----------------------------------------------------------------------------------
;	Shuffle high scores down from entry temp3 to make gap
;----------------------------------------------------------------------------------

.shufflehiscores

	LDA #9:STA temp4						; start at high score 9
	
	.shuffleloop
	LDX temp4:CPX temp3:BCC shuffled
	JSR gethiscoreaddr

	; Copy each entry down a slot
	; this is done in a stupid way, using &30..&3F as a temporary buffer for each entry
	LDY #15
	.readhiscoreloop
	LDA (hiscoreaddr),Y
	STA hiscoretemp,Y
	DEY:BPL readhiscoreloop
	
	LDX temp4:INX
	JSR gethiscoreaddr
	
	LDY #15
	.writehiscoreloop
	LDA hiscoretemp,Y
	STA (hiscoreaddr),Y
	DEY:BPL writehiscoreloop
	
	DEC temp4
	JMP shuffleloop
	
	.shuffled
	LDX temp3
	JSR gethiscoreaddr
	RTS
	

;----------------------------------------------------------------------------------
;	Show high scores
;----------------------------------------------------------------------------------
	
.showhiscores

	LDA #1:STA temp3						; temp3 = high score entry
	
	; print "HIGH SCORES" string
	LDX #LO(string_highscores)
	LDY #HI(string_highscores)
	JSR printstring

	LDA #LO(704):STA hiscoreypos
	LDA #HI(704):STA hiscoreypos+1
	
	.showhiscoresloop
	LDX #LO(string_hiscorepos)
	LDY #HI(string_hiscorepos)
	JSR printstring
	
	; print high score index 1-10 (left-padded with a space)
	LDA #' '
	LDX temp3:STX temp4
	CPX #10:BNE nothiscore10
	LDA #'1':LDX #0:STX temp4
	.nothiscore10
	JSR oswrch
	LDA temp4:CLC:ADC #'0':JSR oswrch
	
	; print high score
	LDX temp3
	JSR gethiscoreaddr
	LDY #0:STY temp4					; flag whether zeroes are leading ones or not
	.hiscoredigitsloop
	LDA (hiscoreaddr),Y
	BNE printhighscoredigit				; non-zero, print it as-is
	LDX temp4
	BNE printhighscoredigit				; not a leading zero, print it as-is
	LDA #' '
	JMP printhighscorechar
	
	.printhighscoredigit
	CLC:ADC #'0'
	INC temp4							; finished leading zeroes
	.printhighscorechar
	JSR oswrch
	
	INY:CPY #8
	BCC hiscoredigitsloop
	
	LDA #' ':JSR oswrch
	
	; print high score name
	.hiscorenameloop
	LDA (hiscoreaddr),Y
	JSR oswrch
	INY:CPY #16
	BCC hiscorenameloop
	
	; print next score
	INC temp3
	LDA temp3:CMP #11
	BEQ showhiscoresend
	
	; adjust y position to plot at
	LDA hiscoreypos:SEC:SBC #48:STA hiscoreypos
	LDA hiscoreypos+1:SBC #0:STA hiscoreypos+1
	
	JMP showhiscoresloop
	
	.showhiscoresend
	RTS
	
	
;----------------------------------------------------------------------------------
;	Enter player's score into high score table if required
;----------------------------------------------------------------------------------

.updatehiscoretab

	JSR checknewhiscore
	LDA temp3:CMP #11:BNE gethiscorename
	RTS
	
.gethiscorename
	STA temp1
	
	; position high score prompt at right y position
	LDA #LO(704):STA promptypos
	LDA #HI(704):STA promptypos+1
	LDA temp1:SEC:SBC #1:BEQ promptpositioned
	TAX
	.positionpromptloop
	LDA promptypos:SEC:SBC #48:STA promptypos
	LDA promptypos+1:SBC #0:STA promptypos+1
	DEX
	BNE positionpromptloop
	.promptpositioned
	
	; Display "ENTER YOUR NAME Player X"
	LDX #LO(string_enteryourname)
	LDY #HI(string_enteryourname)
	JSR printstring
	LDA playernum:CLC:ADC #'1':JSR oswrch
	
	; Show high scores
	JSR showhiscores
	
	; Show input prompt
	LDX #LO(string_hiscoreprompt)
	LDY #HI(string_hiscoreprompt)
	JSR printstring
	
	; Prepare for player input
	LDA #4:LDX #1:JSR osbyte
	LDA #15:LDX #1:JSR osbyte
	LDA #229:LDX #1:LDY #0:JSR osbyte
	
	; Get player input
	LDX #LO(osword0block)
	LDY #HI(osword0block)
	LDA #0
	JSR osword
	
	; Copy inputted name into high score table
	LDX temp1
	JSR gethiscoreaddr
	LDY #8
	.copynewhiscorenameloop
	LDA hiscorenamebuffer-8,Y
	CMP #13:BEQ exitgethiscorename
	STA (hiscoreaddr),Y
	INY
	CPY #16
	BCC copynewhiscorenameloop
	
	.exitgethiscorename
	RTS
	

;----------------------------------------------------------------------------------
;	High score related strings
;----------------------------------------------------------------------------------
	
.string_highscores
	EQUB string_highscores_end - string_highscores_start
.string_highscores_start
	EQUB 18, 0, 1				; GCOL 0,1
	EQUB 25, 4					; MOVE ...
	EQUW 288, 800				; MOVE 288,800
	EQUS "HIGH SCORES"
	EQUB 18, 0, 3				; GCOL 0,3
.string_highscores_end


.string_hiscorepos
	EQUB string_hiscorepos_end - string_hiscorepos_start
.string_hiscorepos_start
	EQUB 25, 4					; MOVE ...
	EQUW 32						; MOVE 32,...
	.hiscoreypos
	EQUW 0						; MOVE 32,0
.string_hiscorepos_end


.string_hiscoreprompt
	EQUB string_hiscoreprompt_end - string_hiscoreprompt_start
.string_hiscoreprompt_start
	EQUB 18, 0, 1				; GCOL 0,1
	EQUB 25, 4					; MOVE ...
	EQUW 672					; MOVE 672,...
	.promptypos
	EQUW 0						; MOVE 672,0
	EQUS ">"
.string_hiscoreprompt_end


.string_enteryourname
	EQUB string_enteryourname_end - string_enteryourname_start
.string_enteryourname_start
	EQUB 24						; VDU 24,...
	EQUW 0, 0, 1279, 892		; VDU 24,0,0,1279,892
	EQUB 16						; CLG
	EQUB 26						; VDU 26
	EQUB 18, 0, 1				; GCOL 0,1
	EQUB 25, 4					; MOVE ...
	EQUW 160, 160				; MOVE 160,160
	EQUS "ENTER YOUR NAME"
	EQUB 25, 4					; MOVE ...
	EQUW 384, 100				; MOVE 384,100
	EQUB 18, 0, 2				; GCOL 0,2
	EQUS "Player "
.string_enteryourname_end


.osword0block
	EQUW hiscorenamebuffer
	EQUB hiscorenamebuffer_end - hiscorenamebuffer - 1		; CR occupies final byte
	EQUB 32
	EQUB 127
	
.hiscorenamebuffer
	SKIP 9
.hiscorenamebuffer_end
	
	
	

;----------------------------------------------------------------------------------
;	Entry point (only entered once at beginning of game)
;----------------------------------------------------------------------------------

.entrypoint

	JSR initialise
	

;----------------------------------------------------------------------------------
;	Beginning of the game lifecycle - the title page
;----------------------------------------------------------------------------------

.start

	JSR titlepage
	JSR choosenumplayers	

;----------------------------------------------------------------------------------
;	Player starting their turn
;----------------------------------------------------------------------------------

.restartplayer
	
	; Print "Get Ready"
	LDX #LO(string_getready)
	LDY #HI(string_getready)
	JSR printstring

	; Print "Player N"
	LDX #LO(string_playerN)
	LDY #HI(string_playerN)
	JSR printstring
	LDA playernum:CLC:ADC #'1':JSR oswrch
	
	LDA #20:JSR pause
	
;----------------------------------------------------------------------------------
;	Start a new level
;----------------------------------------------------------------------------------
	
.startnewlevel

	JSR initlevel
	JSR initmap
	JSR initcharacters
	
	;;;;; This code was added into a later release of the game
	LDA #&7C:JSR osbyte
	;;;;;
	
;----------------------------------------------------------------------------------
;	Main loop
;----------------------------------------------------------------------------------
	
.mainloop

	JSR handlekeyboard
	JSR handleplayercontrols
	JSR domovementsound
	JSR movelift
	JSR updatebirds
	JSR checkextralife
	JSR checkcollisions
	JSR framedelay
	LDA playerdieflag:BNE playerdead
	LDA playery:CMP #17:BCC playerdead		; hit top of screen
	LDA numeggsleft:BEQ levelcomplete
	LDA keys:BMI start						; if 'quit' selected
	JMP mainloop
	
	
;----------------------------------------------------------------------------------
;	Comes here when screen is completed
;----------------------------------------------------------------------------------

.levelcomplete

	LDA bonusexpiredflag:BNE nobonustoaward
	
	; award bonus here
	.awardbonusloop
	LDA #1:LDX #6:JSR addscore				; add 10 to score
	JSR dodecreasebonus
	JSR checkextralife
	LDA bonus+2:BEQ playbonussound
	CMP #5:BNE dontplaybonussound
	
	.playbonussound
	LDX #LO(bonussoundblock)
	LDY #HI(bonussoundblock)
	LDA #7
	JSR osword
	.dontplaybonussound
	
	LDA bonusexpiredflag
	BEQ awardbonusloop
	
	.nobonustoaward
	
	; set up next level
	INC level
	JSR saveplayerdata
	JSR initplayerleveldata
	JSR restoreplayerdata
	JMP startnewlevel
	
	
;----------------------------------------------------------------------------------
;	Comes here when player dies
;----------------------------------------------------------------------------------

.playerdead

	JSR saveplayerdata
	LDX #LO(deathtunedata)
	LDY #HI(deathtunedata)
	JSR playdeathtune
	
	; check if player is totally dead
	LDX playernum
	DEC lives,X
	BNE nextplayersturn
	
	; player is totally dead - print "GAME OVER"
	LDX #LO(string_gameover)
	LDY #HI(string_gameover)
	JSR printstring
	
	; Print "Player N"
	LDX #LO(string_playerN)
	LDY #HI(string_playerN)
	JSR printstring
	LDA playernum:CLC:ADC #'1':JSR oswrch
	
	LDA #10:JSR pause
	
	;;;;; This code was added into a later release of the game
	LDA #&7C:JSR osbyte
	;;;;;
	
	JSR updatehiscoretab
	LDA #5:JSR pause
	
	; See if there are any active players left
	DEC numaliveplayers
	BEQ allplayersdead

;----------------------------------------------------------------------------------
;	Move to next player
;----------------------------------------------------------------------------------
	
.nextplayersturn

	LDX playernum:INX:TXA:AND #3:STA playernum		; go to next player
	CMP numplayers:BCS nextplayersturn				; if not so many players, repeat
	TAX
	LDA lives,X:BEQ nextplayersturn					; if this player is dead, repeat
	
	; Got next player
	JSR restoreplayerdata
	JMP restartplayer
	

;----------------------------------------------------------------------------------
;	Everyone is dead; return to the very beginning of the gameflow
;----------------------------------------------------------------------------------

.allplayersdead

	JMP start
	

;----------------------------------------------------------------------------------
;	Gameflow related strings
;----------------------------------------------------------------------------------

.string_gameover
	EQUB string_gameover_end - string_gameover_start
.string_gameover_start
	EQUB 24						; VDU 24,...
	EQUW 256, 336, 1024, 532	; VDU 24,256;336;1024;532;
	EQUB 16						; CLG
	EQUB 26						; VDU 26
	EQUB 25, 4					; MOVE ...
	EQUW 352, 500				; MOVE 352,500
	EQUB 18, 0, 8				; GCOL 0,8
	EQUS "GAME OVER"
.string_gameover_end


.string_getready
	EQUB string_getready_end - string_getready_start
.string_getready_start
	EQUB 16						; CLG
	EQUB 25, 4					; MOVE ...
	EQUW 352, 500				; MOVE 352,500
	EQUB 18, 0, 4				; GCOL 0,4
	EQUS "Get Ready"
	EQUB 18, 0, 8				; GCOL 0,8
.string_getready_end


.string_playerN
	EQUB string_playerN_end - string_playerN_start
.string_playerN_start
	EQUB 25, 4					; MOVE ...
	EQUW 384, 400				; MOVE 352,500
	EQUS "Player "
.string_playerN_end



;----------------------------------------------------------------------------------
;	One-time initialisation, e.g. copy code to low memory, set screen mode, etc
;	This has to change location eventually
;----------------------------------------------------------------------------------

.initialise

	LDA #200:LDX #2:LDY #0:JSR osbyte
	
	; Copy code to low memory
	LDX #0
	.copyloop
	FOR n, 0, 7
		LDA relocated_code + n*&100,X
		STA codelow_start + n*&100,X
	NEXT
	DEX
	BNE copyloop
	
	; Select screen mode
	LDA #22:JSR oswrch
	LDA #2:JSR oswrch
	
	; Select VDU 5 (twice, for no good reason)
	LDA #5:JSR oswrch
	LDA #5:JSR oswrch
	
	; Set default keys
	LDA #&9D:STA keynum_jump		; spacebar
	LDA #&BE:STA keynum_up			; A
	LDA #&9E:STA keynum_down		; Z
	LDA #&99:STA keynum_left		; <
	LDA #&98:STA keynum_right		; >
	
	JSR resethiscoretab
	
	; Initialise envelopes
	LDX #LO(envelope1)
	LDY #HI(envelope1)
	LDA #8
	JSR osword
	
	LDX #LO(envelope2)
	LDY #HI(envelope2)
	LDA #8
	JSR osword

	LDX #LO(envelope3)
	LDY #HI(envelope3)
	LDA #8
	JSR osword
	
	; Initialise palette
	LDX #15:STX temp1
	.initpalette
	LDX temp1:STX string_vdu19_start+1
	LDA palettedata,X:STA string_vdu19_start+2
	LDX #LO(string_vdu19)
	LDY #HI(string_vdu19)
	JSR printstring
	DEC temp1
	BPL initpalette
	RTS
	
	
.string_vdu19
	EQUB string_vdu19_end - string_vdu19_start
.string_vdu19_start
	EQUB 19, 0, 0, 0, 0, 0
.string_vdu19_end


.palettedata
	EQUB 0				; Colour 0
	EQUB 3				; Colour 1
	EQUB 5				; Colour 2
	EQUB 2				; Colour 3
	EQUB 3				; Colour 4
	EQUB 3				; Colour 5
	EQUB 3				; Colour 6
	EQUB 3				; Colour 7
	EQUB 6				; Colour 8
	EQUB 6				; Colour 9
	EQUB 6				; Colour 10
	EQUB 6				; Colour 11
	EQUB 3				; Colour 12
	EQUB 3				; Colour 13
	EQUB 3				; Colour 14
	EQUB 3				; Colour 15
	

;----------------------------------------------------------------------------------
;	Prompt for number of players
;----------------------------------------------------------------------------------

.choosenumplayers
	
	; Print "How many players?"
	LDX #LO(string_howmanyplayers)
	LDY #HI(string_howmanyplayers)
	JSR printstring
	
	; Establish timeout for keypress
	LDA #0:STA temp4
	LDA #100:STA temp5
	
	.inputnumplayers
	
	; Check '1' key
	LDX #&CF:LDY #&FF:LDA #&81:JSR osbyte
	CPY #0:BEQ not1player
	LDA #1:JMP startgame
	.not1player

	; Check '2' key
	LDX #&CE:LDY #&FF:LDA #&81:JSR osbyte
	CPY #0:BEQ not2player
	LDA #2:JMP startgame
	.not2player

	; Check '3' key
	LDX #&EE:LDY #&FF:LDA #&81:JSR osbyte
	CPY #0:BEQ not3player
	LDA #3:JMP startgame
	.not3player

	; Check '4' key
	LDX #&ED:LDY #&FF:LDA #&81:JSR osbyte
	CPY #0:BEQ not4player
	LDA #4:JMP startgame
	.not4player
	
	DEC temp4:BNE inputnumplayers
	DEC temp5:BNE inputnumplayers
	
	; Timeout - back to title page
	PLA:PLA
	JMP start
	
	
;----------------------------------------------------------------------------------
;	Start game; A = number of players
;----------------------------------------------------------------------------------

.startgame

	STA numplayers
	STA numaliveplayers
	CLC:ADC #'0':JSR oswrch
	
	LDA #5:JSR pause
	
;----------------------------------------------------------------------------------
;	Initialise all player data to start of game defaults
;----------------------------------------------------------------------------------

.initallplayers

	LDX #3
	.resetplayerdataloop
	LDA #0:STA playerlevel,X
	LDA #5:STA lives,X
	DEX
	BPL resetplayerdataloop
	
	; Initialise all players' scores
	LDX #3:STX temp1
	.resetplayerscores
	TXA:ASL A:ASL A:ASL A:ASL A:ASL A:ASL A:TAX
	LDY #7
	LDA #0
	.resetplayerscores2
	STA playerscore,X
	INX
	DEY
	BPL resetplayerscores2
	DEC temp1
	LDX temp1
	BPL resetplayerscores
	
	; Initialise current player data
	LDA #0:STA level

	; Initialise per-player data
	LDA #4:STA playernum
	.resetperplayerloop
	DEC playernum
	JSR initplayerleveldata
	LDA playernum
	BNE resetperplayerloop
	
	; Get current player data from newly initialised per-player data
	JSR restoreplayerdata
	
	LDA #26:JSR oswrch
	RTS
	
	
.string_howmanyplayers
	EQUB string_howmanyplayers_end - string_howmanyplayers_start
.string_howmanyplayers_start
	EQUB 16						; CLG
	EQUB 25, 4					; MOVE ...
	EQUW 32, 500				; MOVE 32,500
	EQUS "How many players? "
.string_howmanyplayers_end
	

;----------------------------------------------------------------------------------
;	Pause for A units of time
;----------------------------------------------------------------------------------

.pause

	STA temp3
	.pauseloop1
	LDY #0
	LDX #0
	.pauseloop2
	DEX
	BNE pauseloop2
	DEY
	BNE pauseloop2
	DEC temp3
	BNE pauseloop1
	RTS
	
	
;----------------------------------------------------------------------------------
;	Render and update the title page
;----------------------------------------------------------------------------------

.titlepage

	TSX:STX savesp
	JSR initplayersfordemo
	
.titlepageloop

	; Show high scores
	LDA #16:JSR oswrch
	JSR showlogo
	JSR showhiscores
	JSR showkeyhelp
	LDA #30:STA temp3				; timer
	.titlepagewait1
	JSR checktitlepagekeys
	DEC temp3
	BNE titlepagewait1
	
	; Show random level
	JSR displayrandomlevel
	LDA #20:STA temp3				; timer
	.titlepagewait2
	JSR checktitlepagekeys
	DEC temp3
	BNE titlepagewait2
	
	; Show keys
	LDA #16:JSR oswrch
	JSR showlogo
	JSR showkeys
	JSR showkeyhelp
	LDA #30:STA temp3				; timer
	.titlepagewait3
	JSR checktitlepagekeys
	DEC temp3
	BNE titlepagewait3
	
	; Show random level
	JSR displayrandomlevel
	LDA #20:STA temp3
	.titlepagewait4
	JSR checktitlepagekeys
	DEC temp3
	BNE titlepagewait4
	
	JMP titlepageloop

	
;----------------------------------------------------------------------------------
;	Display random level
;----------------------------------------------------------------------------------

.displayrandomlevel

	JSR rnd
	LDA rndseed:AND #7:STA level:STA screen
	JSR initmap
	JSR initcharacters
	RTS


;----------------------------------------------------------------------------------
;	Initialise all 4 players (used by the demo)
;----------------------------------------------------------------------------------

.initplayersfordemo

	LDA #4:STA numplayers:STA numaliveplayers
	JSR initallplayers
	JSR initlevel
	RTS

	
;----------------------------------------------------------------------------------
;	Show Chuckie Egg logo
;	TODO: Optimise me!
;----------------------------------------------------------------------------------

.showlogo

	LDA #LogoColour:STA spritecolour
	
	LDA #SpriteId_BigC:LDX #2:LDY #240:JSR showbigletter
	LDA #SpriteId_BigH:LDX #17:LDY #240:JSR showbigletter
	LDA #SpriteId_BigU:LDX #32:LDY #240:JSR showbigletter
	LDA #SpriteId_BigC:LDX #47:LDY #240:JSR showbigletter
	LDA #SpriteId_BigK:LDX #62:LDY #240:JSR showbigletter
	LDA #SpriteId_BigI:LDX #77:LDY #240:JSR showbigletter
	LDA #SpriteId_BigE:LDX #92:LDY #240:JSR showbigletter
	
	LDA #SpriteId_BigE:LDX #114:LDY #240:JSR showbigletter
	LDA #SpriteId_BigG:LDX #129:LDY #240:JSR showbigletter
	LDA #SpriteId_BigG:LDX #144:LDY #240:JSR showbigletter
	RTS


;----------------------------------------------------------------------------------
;	Show help with keys (S to start, K to change keys)
;----------------------------------------------------------------------------------

.showkeyhelp

	LDX #LO(string_keyhelp)
	LDY #HI(string_keyhelp)
	JSR printstring
	RTS
	
.string_keyhelp
	EQUB string_keyhelp_end - string_keyhelp_start
.string_keyhelp_start
	EQUB 25, 4					; MOVE ...
	EQUW 128, 100				; MOVE 128,100
	EQUB 18, 0, 4				; GCOL 0,4
	EQUS "Press "
	EQUB 18, 0, 8				; GCOL 0,8
	EQUS "S "
	EQUB 18, 0, 4				; GCOL 0,4
	EQUS "to start"
	EQUB 25, 4					; MOVE ...
	EQUW 128, 50				; MOVE 128,50
	EQUB 18, 0, 8				; GCOL 0,8
	EQUS "K "
	EQUB 18, 0, 4				; GCOL 0,4
	EQUS "to change keys"
.string_keyhelp_end

	
;----------------------------------------------------------------------------------
;	Check title page keys
;----------------------------------------------------------------------------------

.checktitlepagekeys_core
	
	; Check 'S'
	LDA #&81:LDX #&AE:LDY #&FF:JSR osbyte
	CPY #0:BEQ didntpressS
	LDX savesp:TXS
	RTS					; start game
	.didntpressS
	
	; Check 'K'
	LDA #&81:LDX #&B9:LDY #&FF:JSR osbyte
	CPY #0:BNE pressedK
	RTS
	
	; Redefine keys
	.pressedK
	LDX savesp:TXS
	JSR choosekeys
	JMP titlepageloop
	

.checktitlepagekeys
	JSR checktitlepagekeys_core
	LDX #0:LDY #0
	.checktitlepagekeysdelay
	DEX
	BNE checktitlepagekeysdelay
	DEY
	BNE checktitlepagekeysdelay
	RTS


;----------------------------------------------------------------------------------
;	Show big logo letter
;----------------------------------------------------------------------------------

.showbigletter

	PHA
	JSR calcscrnaddr
	PLA
	JSR getspritedata
	JSR plotsprite
	RTS
	
	
;----------------------------------------------------------------------------------
;	Initialise level data (speed, number of birds, etc)
;----------------------------------------------------------------------------------

.initlevel
	
	; get screen number and difficulty
	LDA level:AND #7:STA screen
	LDA level:LSR A:LSR A:LSR A:STA difficulty
	
	; whether we have a big bird or not
	LDA #0:STA bigbirdflag
	LDA difficulty:BEQ nobigbirdyet
	INC bigbirdflag
	.nobigbirdyet
	
	LDA #0:STA updatetimer
	LDA #0:STA currentbirdindex

	; whether birds move more quickly
	LDA #8
	LDX difficulty:CPX #4:BCC birdsnotfastyet
	LDA #5
	.birdsnotfastyet
	STA birdwalkingspeed
	
	LDA #0:STA extralifeflag
	STA playerdieflag
	STA stalltime
	
	LDA #&76
	STA rndseed
	STA rndseed+1
	STA rndseed+2
	STA rndseed+3
	RTS
	

;----------------------------------------------------------------------------------
;	Initialise the per-player data for a new level
;----------------------------------------------------------------------------------

.initplayerleveldata
	
	LDA playernum
	ASL A:ASL A:ASL A:ASL A:ASL A:ASL A
	TAX
	
	; Initialise bonus based on level number
	LDA level:CLC:ADC #1:CMP #10
	BCC capto9:LDA #9:.capto9
	STA playerbonus,X
	LDA #0
	STA playerbonus+1,X
	STA playerbonus+2,X
	STA playerbonusexpiredflag,X
	
	; Mark eggs and seed as not collected
	LDY #16
	.clearcollectedflags
	STA collectedeggsflags,X
	STA collectedseedflags,X
	INX
	DEY
	BNE clearcollectedflags
	RTS
	

;----------------------------------------------------------------------------------
;	Restore current player score, bonus and level from backup
;----------------------------------------------------------------------------------

.restoreplayerdata
	
	; get current level
	LDX playernum
	LDA playerlevel,X:STA level

	; get data offset pointer
	TXA
	ASL A:ASL A:ASL A:ASL A:ASL A:ASL A
	STA playerdataoffset

	; get current score
	TAX	
	LDY #0
	.restoreplayerdataloop
	LDA playerscore,X:STA score,Y
	INX:INY
	CPY #8
	BCC restoreplayerdataloop
	
	; get current bonus
	LDX playerdataoffset
	LDY #0
	.restoreplayerdataloop2
	LDA playerbonus,X:STA bonus,Y
	INX:INY
	CPY #4
	BCC restoreplayerdataloop2
	
	; get score screen position
	; TODO: optimise: use a lookup table
	LDX playernum
	LDA #0
	CLC
	.restoreplayerdataloop3
	ADC #34
	DEX
	BPL restoreplayerdataloop3
	SEC:SBC #21
	STA currentscorexpos
	RTS


;----------------------------------------------------------------------------------
;	Save current player score, bonus and level to per-player backup
;----------------------------------------------------------------------------------

.saveplayerdata
	
	; save current level
	LDX playernum
	LDA level:STA playerlevel,X

	; save current score
	LDX playerdataoffset
	LDY #0
	.saveplayerdataloop
	LDA score,Y:STA playerscore,X
	INX:INY
	CPY #8
	BCC saveplayerdataloop
	
	; save current bonus
	LDX playerdataoffset
	LDY #0
	.saveplayerdataloop2
	LDA bonus,Y:STA playerbonus,X
	INX:INY
	CPY #4
	BCC saveplayerdataloop2
	
	RTS
	
	
;----------------------------------------------------------------------------------
;	Initialise player, birds, lifts and render them for the first time
;----------------------------------------------------------------------------------

.initcharacters

	LDA liftflag:BEQ initbigbird
	
	; init lifts
	LDA #8:STA lift1y
	LDA #90:STA lift2y
	LDA #0:STA whichlift
	LDA #LiftColour:STA spritecolour

	; plot first lift
	LDA #SpriteId_Lift:JSR getspritedata
	LDX liftx:LDY lift1y:JSR calcscrnaddr
	JSR plotsprite
	
	; plot second lift
	LDA #SpriteId_Lift:JSR getspritedata
	LDX liftx:LDY lift2y:JSR calcscrnaddr
	JSR plotsprite
	
	; init big bird
	.initbigbird
	
	LDA #4:STA bigbirdxpos
	LDA #204:STA bigbirdypos
	LDA #0:STA bigbirdxspeed:STA bigbirdyspeed:STA bigbirdanim
	JSR plotbigbird
	
	; determine how many birds appear
	LDX #&FF:STX temp1					; init bird index for later
	LDA difficulty
	CMP #1:BNE notphase2
	LDX #0:STX numbirds					; no birds on phase 2
	.notphase2
	CMP #3:BCC notphase1or3
	LDX #5:STX numbirds					; 5 birds from phase 4 onwards
	.notphase1or3
	
	; init birds
	.initbirdloop
	INC temp1
	LDX temp1:CPX numbirds:BCS doneinitbirds
	
	; reset bird X
	LDA birdcharx,X:ASL A:ASL A:ASL A:STA birdpixelx,X
	LDA birdchary,X:ASL A:ASL A:ASL A
	CLC:ADC #20:STA birdpixely,X		; add height of bird to get pixel position
	LDA #0:STA birdstatus,X:STA birdanim,X
	LDA #2:STA birddir,X
	JSR plotbird
	JMP initbirdloop
	.doneinitbirds
	
	LDA #3:JSR pause
	
	; init player
	LDA #60:STA playerx
	LDA #32:STA playery
	LDA #6:STA playerspritenum
	JSR plotplayer
	LDA #7:STA playercharx:STA playerfracx
	LDA #2:STA playerchary
	LDA #0:STA playerfracy:STA movementtype
	LDA #1:STA playerfacingdir
	JSR showlife
	RTS
	
	
;----------------------------------------------------------------------------------
;	Check whether an extra life should be awarded
;----------------------------------------------------------------------------------

.checkextralife

	LDA extralifeflag:BNE awardextralife
	RTS
	
.awardextralife
	LDA #0:STA extralifeflag
	JSR showlife
	LDX playernum
	INC lives,X
	RTS

	
;----------------------------------------------------------------------------------
;	Plot/delete life
;----------------------------------------------------------------------------------

.showlife

	LDA #LivesColour:STA spritecolour
	LDX playernum
	LDA lives,X:CMP #9:BCC showlife2
	RTS
	
.showlife2
	ASL A:ASL A
	ADC currentscorexpos
	ADC #10
	TAX
	LDY #238
	JSR calcscrnaddr
	LDA #SpriteId_Life
	JSR getspritedata
	JSR plotsprite
	RTS
	

;----------------------------------------------------------------------------------
;	Play death tune
;----------------------------------------------------------------------------------

.playdeathtune

	STX read:STY read+1
	LDY #0:STY temp2
	LDA (read),Y:STA temp3			; number of notes in the tune
	
	.playdeathtuneloop
	LDY temp2
	INY:LDA (read),Y:STA deathsoundblock+4
	INY:LDA (read),Y:STA deathsoundblock+6
	STY temp2
	LDX #LO(deathsoundblock)
	LDY #HI(deathsoundblock)
	LDA #7
	JSR osword
	
	DEC temp3
	BNE playdeathtuneloop
	RTS

	
;----------------------------------------------------------------------------------
;	Death tune data
;----------------------------------------------------------------------------------

.deathtunedata
	EQUB (deathtune_end - deathtune_start) / 2
.deathtune_start
	; pairs of (pitch, length)
	EQUB 33, 4
	EQUB 41, 2
	EQUB 33, 4
	EQUB 25, 2
	EQUB 21, 4
	EQUB 5, 2
	EQUB 13, 4
	EQUB 1, 2
	EQUB 5, 12
	EQUB 5, 1
	EQUB 13, 1
	EQUB 21, 1
	EQUB 25, 1
	EQUB 33, 1
	EQUB 49, 1
	EQUB 53, 1
.deathtune_end
	
	
;----------------------------------------------------------------------------------
;	Envelope data
;----------------------------------------------------------------------------------

.envelope1
	EQUB 1, 1, 0, 0, 0, 0, 0, 0, 126, 206, 0, 0, 100, 0
	
.envelope2
	EQUB 2, 1, 0, 0, 0, 0, 0, 0, 126, 254, 0, 251, 126, 100
	
.envelope3
	EQUB 3, 1, 0, 0, 0, 0, 0, 0, 50, 0, 0, 231, 100, 0

	
SKIPTO &3000
.codemain_end


;---------------------------------------------------------------------------------------------------
; Move the 'low' code to the end of the 'main' code, for relocation at runtime

.relocated_code
SKIP codelow_end - codelow_start
.relocated_code_end

COPYBLOCK codelow_start, codelow_end, relocated_code

SAVE "Ch_Egg", codemain_start, relocated_code_end, entrypoint
