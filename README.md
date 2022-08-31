# M5Cheg

### Porting Tatung Einstein Chuckie Egg to the Sord M5.

Well this was a thing I didn't think I'd end up doing but here we are. To be honest I thought it was going to be much harder than it turned out to be but that was just luck. A lot of features of the code were totally flukey and helped the port immensely. I chose Chuckie Egg ('CE') as a target because:

* I like it
* Every system should have it
* It's how I rank retro computer users

I chose the Tatung version as the source because, most significantly, the two systems share a big part of their architecture. Both Z80 and TMS99 video chips. I momentarily thought the M5 had an AY sound chip as well but I have a stupid short memory and didn't remember the absolute ball-ache I had converting the sound when I ported my own game BiggOil. D'oh.

So, porting. TL;DR: Modify MAME to output interesting info, understand enough of the source program using Ghidra/MAME debugger, patch the binary until it works. There you go, you can now go and port something! Porting is fun. It's also pretty brain scrambling at times but it's one of those things you just have to persevere with. I'm not going to make this a beginners guide. I won't be explaining basic concepts, sorry.

There were a number of milestones which I had in my mind as roughly thus:

* See something on screen
* Make the game respond to you
* Do the sound if I could be arsed

Another one popped into the list as I went along and this was to fix any original bugs that irritated me.

Tools what I thought I'd need:
* A copy of MAME built locally in Visual Studio so I can hack it to output helpful information
* All the docs:
  * Z80 programmer's manual
  * TMS programmer's guide
  * AY programmer's guide
  * M5 hardware manual (I wish!) had to make do with schematics
  * Einstein hardware manual.
* A working knowledge of Ghidra
* A hex editor
* An assembler
* Some way of patching the source binary

I hadn't used Ghidra before, and all the binary patching solutions I was aware of didn't fit my requirements so there's another task. Building MAME is something I'm used to so that shouldn't be hard, right..?

But I'm getting ahead of myself. We should see what we're up against. 

#### Step 0. See what we're up against.

Get MAME, all the rommy bits required to run Tatung and Sord, and the CE disk image. Tatung DOS is based off CPM and loads binaries at $100. So start MAME in debug mode, and when the debugger appears G 100 and see what happens. What happened was _very_ interesting. The game is relocated to $8000 and executed there. This was intially puzzling. There's no obvious immediate need for this behaviour. I thought maybe the game was assembled in place with a memory resident assembler but it the reason will reveal itself later.

In some ways this is good news. The M5Multi cart has RAM in the upper 32k memory region so it should run there, all being well, but MAME is a different problem as the default M5 device only has the standard 4K. Looking at the slot devices there's talk of a 32k RAM cart but for the life of me I can't make it work. So a hack it is.

**Yak shave 1: Make M5 look like an M5 with an M5Multi.**
* Get MAME source. Check out latest from GitHub.
* Get tools.
* Compile it. Man alive this cross platform build is slow. Stop that, it's silly.
* Build MAME with only the M5 and Einstein drivers. That's better but still super slow.
* Do the steps needed to generate the VS project files.
* Build with VS. Whoosh! Very quick. Multi core support - perhaps that could be enabled for other build too.
* A million errors! All related to some sound thing. No related info online.
* Start hacking stuff out of MAME hoping it's not needed and won't be a rabbit hole.
* It was a small rabbit hole. Eventually enough is hacked off though, and the thing builds.

Right. Now it builds let's see how to add 32K RAM. The M5 source is littered with hacks for some weird homebrew setup that a (presumably) small number of people had but is of little interest to me. Hack most of that out leaving a bare M5 driver, apart from the code that puts 32k of RAM in the upper region. I'm trivialising this, it was one of the hardest parts of this process and took best part of a day to get working.

With the Chuckie.com file extracted from the disk image, using the [EinyDSK tools](https://github.com/charlierobson/einsdein-vitamins/tree/master/utils/dsktool) what I wrote, I lopped off the relocator code and saved the raw binary. The resulting code blob is less than 16k in size, which is great news for fitting into a 16K ROM image. I have some experience of putting M5 ROM carts together so I re-purposed the startup ASM code from BiggOil. I included the CE binary in the code along with a relocator and assembled it to the roms folder in the MAME directory, to make running it easier. I added an entry in the MAME M5 ROMS XML so I could load the cart from the commandline. While these things take effort to set up they are important to reduce friction in the future.

Speaking of which, an important part of the porting process will be a reproducible 'build pipeline' so that was next. This is a grandiose way of saying I wrote a batch file to automate the build ha ha. 

I love an assembler called BRASS, it's free, cross platform (via Mono) and works great. It's a TASM compatible - which for whatever reason is something people still use despite it not being free 🤷‍♂️ Being able to reproduce the ROM from it constituent parts with a single command is important. It will save a lot of pain.

Right. We have a ROM cart and we can load it into MAME. Let's go. Let's G 8000 to e precise.

#### Step 1. See something on screen.

The Einstein has its VDP on hardware ports $08 and $09. The M5 is $10 and $11. Easiest thing to do is a translation in the emulator. So off to the Z80 emulator code in MAME and find the IN and OUT handler. These take the IO address as a parameter, so a quick re-mapping in the routine will have something on screen.

Running the code I see the screen update, but it's junk. I need to know what's happening so off to the VDP code in MAME. There is already some debug code in there so that was enabled and the M5 and Einstein start-ups were run. It showed that the M5 was setting up a different display mode to the Einstein. Nothing surprising there, so I added code to the cart start-up to configure the VPD identically to that of the Einstein.

Re-running the cart showed the title screen! It's important to have some wins and this was a big one. It made me think I could do this. I initially thought that the program had crashed after displaying the title but it was just playing the title screen music to itself, happily writing to the wrong sound chip registers, natch, and when that finished I was excited to see the scrolling text appear, indicating that the code was still running happily! It's waiting for a key, so let's do that next.

#### Step 2. Make the game respond to you.

The M5 reads its keyboard in a somewhat similar way to the Einstein, but not quite. Like most machines of that day the keyboard is a matrix which gets scanned on a row-by-row basis, examining each row for any bits indicating a key press. The Einstein's matrix is connected via the PSG's IO capability wheras the M5 is directly mapped to an IO address. We need to know where this input biz is happening so logging to the rescue again. I decided to log all IN and OUT operations. I can't be logging blindly so I added code to build a set of addresses and only log the address of the instruction doing the IO when it's first encountered. I filtered on the IO address also, so I was only seeing the addresses I was interested in at any one moment.

With a limited set of addresses showing some IN action I could start putting breakpoints in the debugger and seeing what they were doing. This will show something but it will only get you so far as code typically jumps around and keeping track of addresses in your head might be OK for rain man but I find it hard. So it's time to bring in the big guns.

**Yak shave 2: Get to grips with Ghidra**

Ghidra is a reverse engineering tool. Free, unlike all its competitors, and the work of the NSA so I'm on their list now. I fumbled around for a while but to be honest far less than I was imagining. With the Einy Chuckie binary loaded it was a matter of selecting the correct CPU architecture (Z80 is supported, as are most processors) and a couple of other parameters such as the loading offset. After a bit more fumbling I found the decompile option which went off and produced both an assembler listing and C code that approximated the code flow. That was useless however, as it's pure brute force and assembler programming is, as you should know, a work of art in many cases. We all have our little tricks and oddities, and any large scale assembler project inevitably develops quirks. Vestigial code. Self modifying sections. Routines that never return. Data sprinkled liberally thoughout code. On top of this every authour has their own unique fingerprint, accent if you will.

Ghidra allows you to comment the assembler, jump around the code using hyperlinks, see where code and data are referenced from (SO useful!) and rename the auto-generated labels once you start making sense of things. I love it. I couldn't have done this without it.

Focussing on the input routine I could add labels and gradually untangle the flow. In fact I spent a couple of hours jumping around the place identifying functions and variables. It was like a brilliant puzzle and the time just flew. I highly recommend this as a rainy day activity. After a while I'd found the main game loop, the intro screen, keyboard remapper and a bunch of other stuff.

A lot of the screen update is done with a custom print routine. There are a defined set of control codes for positioning and colouring the text. It's pretty nice. And it makes changing things easy too ;)

Focus you fakeyboard. Back to the input. Most input is based around a couple of ideas. Get the raw bits from the matrix. Provide mechanism for mapping these to a keycap representation.










