# M5Cheg

### Porting Tatung Einstein Chuckie Egg to the Sord M5.

Well this was a thing I didn't think I'd end up doing but here we are. To be honest I thought it was going to be much harder than it turned out to be but that was just luck. A lot of features of the code were reasonably portable and helped the port immensely. 

I chose Chuckie Egg ('CE') as a target because:

* I like it.
* Every system should have it.
* It's how I rank retro computer users. You're either a chuckiehacker or a chuckieegger.

I chose the Tatung version as the source because, most significantly, the two systems share a big part of their architecture. Both Z80 and TMS99 video chips. I momentarily thought the M5 had an AY sound chip as well but I have a stupid short memory and didn't remember the absolute ball-ache I had converting the sound when I ported my own game BiggOil. D'oh.

So, porting. TL;DR: Modify MAME to output interesting info, understand enough of the source program using Ghidra/MAME debugger, patch the binary until it works. There you go, you can now go and port something! Porting is fun. It's also pretty brain scrambling at times but it's one of those things you just have to persevere with. I'm not going to make this a beginners guide. I won't be explaining basic concepts, and it would take forever to go hard on detail so mostly I'm not going to. Sorry.

This doc is going to take the form of a monologue that accompanies the source repo. I'll link to files where you can see what I'm talking about. You can unpick detail from the source, like I did for the code. It'll be fun!

There were a number of milestones which I had in my mind as roughly thus:

* See something on screen.
* Make the game respond to you.
* Do the sound.
* Tidy up some rough edges.

Another one popped into the list as I went along:

* Fix any original bugs that irritate me.

Tools what I thought I'd need:

* A copy of MAME built locally in Visual Studio so I can hack it to output helpful information
* All the docs:
  * Z80 programmer's manual
  * TMS programmer's guide
  * AY programmer's guide
  * M5 hardware manual (I wish!) had to make do with schematics
  * Einstein hardware manual.
* A working knowledge of a reverse engineering tool, most probably Ghidra
* A hex editor
* An assembler
* Some way of patching the source binary

I hadn't used Ghidra before, and all the binary patching solutions I was aware of didn't fit my requirements so there's a couple of tasks right there. Building MAME is something I've done beforeso that shouldn't be hard, right..?

But I'm getting ahead of myself. We should see what we're up against. 

#### Step 0. See what we're up against.

Get MAME, all the rommy bits required to run Tatung and Sord, and the CE disk image. Tatung DOS is based off CPM and loads binaries at $100. So start MAME in debug mode, and when the debugger appears G 100 and see what happens. What happened was _very_ interesting. The game is relocated to $8000 and executed there. This was intially puzzling. There's no obvious immediate need for this behaviour. I thought maybe the game was assembled in place with a memory resident assembler but it the reason will reveal itself later.

This is great news. The M5Multi cart has RAM in the upper 32k memory region so it should run there, all being well. I probably won't have to do any relocating which has saved around 9732% of work! 🎉 🎉

MAME is a different problem as the default M5 device only has the standard 4K. Looking at the slot devices there's talk of a 32k RAM cart but for the life of me I can't make it work. So a hack it is.

**Yak shave 1: Make M5 look like an M5 with an M5Multi.**
* Get MAME source. Check out latest from GitHub.
* Get tools.
* Compile it. Man alive this cross platform build is slow. Stop that, it's silly.
* Build MAME with only the M5 and Einstein drivers. That's better but still super slow.
* Do the steps needed to generate the VS project files.
* Build with VS. Whoosh! Very quick. Multi core support - perhaps that could be enabled for other build too.
* A million errors! All related to some sound thing. No related info online.
* Start hacking stuff out of MAME hoping it's not needed and won't be a rabbit hole.
* It's a rabbit hole. Eventually enough is hacked off though, and the thing builds.

Right. Now let's see how to add 32K RAM. The M5 source is littered with hacks for some weird homebrew setup that a (presumably) small number of people had but is of little interest to me. Hack most of that out leaving a bare M5 driver, apart from the code that puts 32k of RAM in the upper region. I'm trivialising this, it was one of the hardest parts of this process and took best part of a couple of hours to get working. Personally I don't think this machine hack belongs in mainstream MAME (look at the fuss that gets made about hacked software) but that's just my opinion. I digress.

With the `chuckie.com` file extracted from the disk image, using the [EinyDSK tools](https://github.com/charlierobson/einsdein-vitamins/tree/master/utils/dsktool) what I wrote, I lopped off the relocator code and saved the raw binary. The resulting code blob is less than 16k in size, which is great news for fitting into a 16K ROM image. I have some experience of putting M5 ROM carts together so I re-purposed the startup ASM code from BiggOil. I included the CE binary in the code along with a relocator and assembled it to the roms folder in the MAME directory, to make running it easier. After a load of faffing about I added an entry in the hash/m5_cart.xml file, so I could load the cart from the commandline. While these things take effort to set up they are important to reduce friction in the future.

Speaking of which, an important part of the porting process will be a reproducible 'build pipeline' so that was next. This is a grandiose way of saying I wrote a batch file to automate the build ha ha. [BUILD.BAT](https://github.com/charlierobson/M5Cheg/blob/master/build.bat). That'll do.

I love an assembler called [BRASS](https://benryves.com/bin/brass/), it's free, cross platform (via Mono) and works great. I've used it for years. It's TASM compatible - which for whatever reason is something people still use despite it not being free 🤷‍♂️. Being able to reproduce the ROM from it constituent parts with a single command is important. It will save a lot of pain.

Right. We have a ROM cart and we can load it into MAME. I set up the VS project of MAME to run with appropriate command line parameters which means I can hit a single key and have MAME running with everything loaded as I need it: `m5p -debug -uimodekey HOME -cart1 cheg`. The cart1 parameter is a mapping to the cart I ~hacked up~ defined earlier.

OK, run up MAME and let's go. Let's G 8000 to be precise.

#### Step 1. See something on screen.

The Einstein has its VDP on hardware ports $08 and $09. The M5 is $10 and $11. Easiest thing to do is a translation in the emulator. So off to the Z80 emulator code in MAME and find the IN and OUT handler. These take the IO address as a parameter, so a quick re-mapping in the routine will have something on screen.

Running the code I see the screen update, but it's junk. I need to know what's happening so off to the VDP code in MAME. There is already some debug code in there so that was enabled and the M5 and Einstein start-ups were run. It showed that the M5 was setting up a different display mode to the Einstein. Nothing surprising there, so I added code to the cart start-up to configure the VPD identically to that of the Einstein.

Re-running the cart showed the title screen! It's important to have some wins and this was a big one. It made me think I could do this. I initially thought that the program had crashed after displaying the title but it was just playing the title screen music to itself, happily writing to the wrong sound chip registers, natch, and when that finished I was excited to see the scrolling text appear, indicating that the code was still running happily! It's waiting for a key, so let's do that next.

#### Step 2. Make the game respond to you.

The M5 reads its keyboard in a somewhat similar way to the Einstein, but not quite. Like most machines of that day the keyboard is a matrix which gets scanned on a row-by-row basis, examining each row for any bits indicating a key press. The Einstein's matrix is connected via the PSG's IO capability wheras the M5 is directly mapped to an IO address. We need to know where this input biz is happening so logging to the rescue again. I decided to log all IN and OUT operations. I can't be logging blindly as there's so much ouput, so I added code to build a set of accessed addresses and only log the instruction doing the IO when it's first encountered. I filtered on the IO address also, so I was only seeing the addresses I was interested in at any one moment.

With a limited set of addresses showing some IN action I could start putting breakpoints in the debugger and seeing what they were doing. This will show something but it will only get you so far as code typically jumps around and keeping track of addresses in your head might be OK for rain man but I find it hard. I'm more of a misty drizzle man so it's time to bring in the big guns.

**Yak shave 2: Get to grips with Ghidra**

Ghidra is a reverse engineering tool. Free, unlike all its competitors, and the work of the NSA so I'm on their list now. I fumbled around for a while but to be honest far less than I was imagining. With the Einy Chuckie binary loaded it was a matter of selecting the correct CPU architecture and a couple of other parameters such as the loading offset. Z80 is natively supported, as are most processors. After a bit more fumbling I found the decompile option which went off and produced both an assembler listing and C code that approximated the code flow. That was useless however, as it's pure brute force and assembler programming is, as you should know, a work of art in many cases. We all have our little tricks and oddities, and any large scale assembler project inevitably develops quirks. Vestigial code. Self modifying sections. Routines that never return. Data sprinkled liberally thoughout code. On top of this every authour has their own unique fingerprint, accent if you will. So no C today thanks.

Ghidra allows you to comment the assembler, jump around the code using hyperlinks, see where code and data are referenced from (SO useful!) and rename the auto-generated labels once you start making sense of things. I love it. I couldn't have done this without it. Most commands have a single key shortcut and once you've learned these navigating and documenting is a brisk breeze.

Focussing on the input routine I could add labels and gradually untangle the flow. In fact I spent a couple of hours jumping around the place identifying unrelated functions and variables. It was like a brilliant puzzle and the time just flew. I highly recommend this as a rainy day activity. After a while I'd found the main game loop, the intro screen, keyboard remapper, music player, and a bunch of other stuff.

A lot of the screen update is done with a custom print routine. There are a defined set of control codes for positioning and colouring the text. It's pretty nice. And it makes changing things easy too ;)

Focus you fakeyboard. Back to the input task at hand. Most microcomputer game input is based around a couple of ideas. Get the raw bits from the matrix. Provide mechanism for mapping these to a keycap representation.

With the previous 2 parts of the code identified I had to work out how to change them. It would require a lot of poking of bytes and like I said before, we need to be able to reproduce this at any time from the ground up so no hex editing for me. We need to patch binaries. Search internet. Waste time: felt like hours. All the patching tools I found were too heavyweight. I have a very specific workflow here - replace bytes in-place.

**Yak shave 3: Write a patcher**

I needed something with as few steps as possible so came up with the following plan.

* Define a process for making patches in the assembler
* Apply this patch to the binary

A simple data structure defining the patch offset and length followed by the patch bytes themselves seemed like a fine idea. So I wrote [a program](https://github.com/charlierobson/M5Cheg/tree/master/patcher) that would take the source binary, patch binary and output the patched data.

Patches are developed in assembler. I thought this was ideal because, well, most of the stuff I'd be patching was code so you may as well use the code-generating program to make the whole file. Patches look like this:
```
 .word <offset>
 .word <num bytes>
 code/data
 ...
 code/data
``` 
Simple!

BRASS isn't (as far as I know) able to define start addresses for each patch block, so I had to use some tricks and a lot of mental math to calculate relative addresses but this is easy enough, if tedious. One thing I wish I'd done is work out a way to verify the correctness of each block because I got the byte count wrong _a lot_. It was, again, easy to correct but tedious. I considered having each patch block in its own separate asm file and then include all the binary output in one master asm file but many patches refer to one another so that would have been it own special pain point. I may revisit this in future. This was a useful technique for a couple of unrelated patches that required generating offset tables though, e.g. [key cap remapping](https://github.com/charlierobson/M5Cheg/blob/master/keycaptable.asm).

With the ability to patch the binary off I went! First thing was implementing keyboard reading code that 1. worked and 2. fitted in the address space of the code that I was overwriting. For the most part this was OK, but some patches were larger than the space available so required finding a freed-up block of memory and relocating functionality.

Most keyboard routines have a matrix of keycap characters. For keycaps like SHIFT and ENTER there will be some code that represents the extended string. Setting the high bit of the character is a common technique, with the low bits representing an index into a table of addresses pointing to the string data. This was worked out but I had to compromise as the M5 has a lot more keys with non-ascii representations so I had to be creative with descriptions and techniques such as a common string for things like SHIFT.

I'll assume that you don't expect that this all worked first time most of the time. It certainly didn't. But this keyboard stuff is a relatively well understood area for me so this time it did.

From the title screen I could now press keys and have the game respond. I could get to instructions, the key remapper let me remap, and I could start the game. And what do you know, it worked! I was playing Chuckie Egg on the Sord! The graphics for the ducks (ostriches? hens? abominations?) were messed up, which led me onto another yakventure later, but it ran.

I noticed that during keyboard remapping I wasn't allowed to use A or H as control keys. This was tested in Einychuk, and yes it's a source bug. It's because you hold Esc + A or H during the game to abort or hold, respectively. The remap code checks which keys are already assigned and doesn't let you use them for multiple inputs, even though initially the game has QAOP as the character control keys so it's evidently not a problem. The A & H keys aren't printed anywhere unlike the directions which are shown at the start screen. So nuking them in the key remap table by assigning an unused key code is perfectly fine and fixes that.

Most ports won't be this simple. To reiterate again I've been _super_ lucky that the source program 'fits' into the destination memory map and doesn't do anything super funky. I'm doing a little dance now. BRB.

So with the game essentially playable I have some to realise that the sound will be less fun to work on. So I make an executive decision to ignore it for now and do some tidying up and look at the glitchy hen/ostrich/abomination bug.

#### Tidy up some rough edges.

Tidying up first I think I'd like my name in there. I changed the data in the high score table to say something like:
```
PORTED TO  1000
SORD M5    1000
BY CHARLIE 1000
2022       1000
...
```

While I thought I deserved the credit I also didn't like the vandalised look of it. I hate seeing people's names plastered over game hacks, etc. In a cracktro, sure. But in game, naah. Leave it alone. So with that in mind I just replaced the top entry of the high score table with my own name, and a score of 2022. I thought that was suitably subtle and was feeling much better about not being a hypocrite. I did however change the instruction screen by moving all the text up a line and adding `SORD M5 PORT BY CHARLIE ROBSON` in there right before the `press a key` text. Conscience salved I girded my loins for the graphics bug.

At this point in time I decided to map memory accesses by the code, to see if anything was writing data where it shouldn't - which on the M5 would be anywhere that wasn't program binary. $0000-$7fff and $c000-$ffff inclusive. With watchpoints set up in the MAME debugger I ran the game and just as the main game screen was shown I hit a watchpoint. And another and another. RAM was being written from $0000-$4000 and the offending code was duplicating the screen buffer. Aha, which makes sense. The TMS VDP has its own memory that you access via IO ports. You can't read or write it directly.

The game is building the character based screen image from the level description data and then copying the resulting 'map' back into RAM where it can be read and written at will. This explained the corrupted henostribominations. The enemies are character mapped so the game takes the background tile and renders a new tile that mixes in the heno.. bird image and pops it back into screen memory. BUT the character tile peeked from the map was random garbage because, well, ROM.

I'd have to move the screen copy and luckily I have $c000-$cfff so I just had to check if it was free by running with watchpoints there. And it was. So everywhere that the offscreen map was accessed got a patch. It wasn't trivial as the screen access addresses in vram mapped directly to the offscreen RAM copy. So any address that accessed RAM would have to have its top 2 bits set temporarily. Luckily there weren't too many places this happened and with this fix in place we had ungarbled enemies.

About this time I was wondering why the original author didn't use sprites. I suspect it's to do with player/enemy collision but I can't be sure. It would make sense but a hybrid approach would have been much less work and result in a nicer look, as the enemies suffer from attribute clash. Sigh. Perhaps the original Einy version was itself ported from another system? I'd love to find out.

The game is looking pretty sweet now. And I can't put it off any longer - it's sound time.

#### Do the sound.
