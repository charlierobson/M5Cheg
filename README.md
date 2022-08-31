# M5Cheg

### Porting Tatung Einstein Chuckie Egg to the Sord M5.

Well this was a thing I didn't think I'd end up doing but here we are. To be honest I thought it was going to be much harder than it turned out to be but that was just luck. A lot of features of the code were reasonably portable and that helped immensely. Don't get me wrong - it wasn't easy but it could have been way, way worse.

I chose Chuckie Egg ('CE') as a target because:

* I like it.
* Every system should have it.
* It's how I rank retro computer users. You're either a chuckiehacker or a chuckieegger.

I chose the Tatung version as the source because, most significantly, the two systems share a big part of their architecture. Both use Z80 and TMS99 video chips. I momentarily thought the M5 had an AY sound chip as well but I have a stupid short memory and didn't remember the absolute ball-ache I had converting the sound when I ported my own game BiggOil. D'oh.

So, porting. TL;DR: Modify an emulator to output interesting info, understand enough of the program using debugging and reverse engineering, and patch the binary until it works. There you go, you are now fully equipped to port something! Porting is fun. It's also pretty brain scrambling at times but it's one of those things you just have to persevere with. I'm not going to make this a beginners guide. I won't be explaining basic concepts, and it would take forever to go hard on detail so mostly I'm not going to. Sorry.

This doc is going to take the form of a monologue that accompanies [the source repo](https://github.com/charlierobson/M5Cheg/). I'll link to files where you can see what I'm talking about. You can unpick detail from the source, like I did for the code. It'll be fun!

There were a number of milestones which I had in my mind as roughly thus:

* See something on screen.
* Make the game respond to you.
* Do the sound.
* Tidy up some rough edges.

Another one popped into the list as I went along:

* Fix any original bugs that irritate me.

Tools I thought I'd need:

* A copy of MAME built locally so I can hack it to output helpful information
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

MAME is a different problem as the default M5 device only has the standard 4K. Looking at the slot devices there's talk of a 32k RAM cart but for the life of me I can't make it work. So a hack it is. I could have done all this with the standard non-VS build but I imagined that I'd need to use a debugger on MAME itself at some point, and the VS debugger is supreme (fight me), so VS build it is. It turned out I didn't really need to but eh. Hindsight. Coulda saved some pain.

**Yak shave 1: Make M5 look like an M5 with an M5Multi.**
* Get MAME source. Check out latest from GitHub.
* Get tools.
* Compile it. Man alive this cross platform build is slow.
* Build MAME with only the M5 and Einstein drivers. That's better but still super slow.
* Do the steps needed to generate the VS project files.
* Build with VS. Whoosh! Very quick. Multi core support - perhaps that could be enabled for other build too?
* A million errors! All related to some sound thing. No related info online.
* Start hacking erroring stuff out of MAME hoping it's not needed and won't be a rabbit hole.
* It's a rabbit hole. Eventually enough is hacked off though, and the thing builds.

Right. Now let's see how to add 32K RAM. The M5 source is littered with hacks for some weird homebrew setup that a (presumably) small number of people had but is of little interest to me. Hack most of that out leaving a bare M5 driver, apart from the code that puts 32k of RAM in the upper region. I'm trivialising this, it was one of the hardest parts of this process and took best part of a couple of hours to get working. Personally I don't think this machine hack belongs in mainstream MAME (look at the fuss that gets made about hacked software) but that's just my opinion. I digress.

With the `chuckie.com` file extracted from the disk image, using the [EinyDSK tools](https://github.com/charlierobson/einsdein-vitamins/tree/master/utils/dsktool) that I wrote, I lopped off the relocator code and saved the raw binary. The resulting code blob is less than 16k in size, which is great news for fitting into a 16K ROM image. I have some experience of putting M5 ROM carts together so I re-purposed the startup ASM code from BiggOil.

I love an assembler called [BRASS](https://benryves.com/bin/brass/), it's free, cross platform (via Mono) and works great. I've used it for years. It's TASM compatible - which for whatever reason is something people still use despite it not being free 🤷‍♂️. Rant over.

I included the CE binary in the startup code along with a relocator and assembled it as a cart image to the roms folder in the MAME directory. This will make running it easier. After a load of faffing about I added an entry in the hash/m5_cart.xml file, so I could start MAME from the commandline with the cart already inserted. While these things take effort to set up they are important to reduce friction in the future.

Speaking of which being able to reproduce the ROM from it constituent parts with a single command is important. It will save a lot of pain. A central part of this will be having a good 'build pipeline' so that was next. This is a grandiose way of saying I wrote a batch file to automate the build steps ha ha. [BUILD.BAT](https://github.com/charlierobson/M5Cheg/blob/master/build.bat). That'll do. Initially it only had one line in but as things progress it will become thicc.

Right. We have a ROM cart and we can load it into MAME. I set up the VS project of MAME to run with appropriate command line parameters which means I can hit a single key and have the emulator running with everything loaded as I need it: `m5p -debug -uimodekey HOME -cart1 cheg`. The cart1 parameter is a mapping to the cart I ~hacked up~ defined in xml earlier.

OK, run up MAME and let's go. Let's G 8000 to be precise.

#### Step 1. See something on screen.

The Einstein has its VDP on hardware ports $08 and $09. The M5 is $10 and $11. Easiest thing to do is a translation in the emulator. So off to the Z80 emulator code in MAME and find the IN and OUT handler. These take the IO address as a parameter, so a quick re-mapping in the routine will have something on screen.

Running the code I see the screen update, but it's junk. I need to know what's happening so off to the VDP code in MAME. There is already some debug code in there so that was enabled and the M5 and Einstein start-ups were run. It showed that the M5 was setting up a different display mode to the Einstein. Nothing surprising there, so I added code to the cart start-up to configure the VPD identically to that of the Einstein.

Re-running the cart showed the title screen! It's important to have some wins and this was a big one. It made me think I could do this. I initially thought that the program had crashed after displaying the title but it was just playing the title screen music to itself, happily writing to the wrong sound chip registers, natch, and when that finished I was excited to see the scrolling text appear, indicating that the code was still running happily! It's waiting for a key, so let's do that next.

#### Step 2. Make the game respond to you.

The M5 reads its keyboard in a somewhat similar way to the Einstein, but not quite. Like most machines of that day the keyboard is a matrix which gets scanned on a row-by-row basis, examining each row for any bits indicating a key press. The Einstein's matrix is connected via the PSG's IO capability wheras the M5 is directly mapped to an IO address. We need to know where this input biz is happening so logging to the rescue again. I decided to log all IN and OUT operations. I can't be logging blindly as there's so much ouput, so I added code to build a set of accessed addresses and only log the instruction doing the IO when it's first encountered. I filtered on the IO address also, so I was only seeing the addresses I was interested in at any one moment.

With a limited set of addresses showing some IN action I could start putting breakpoints in the debugger and seeing what they were doing. This will show something but it will only get you so far as code typically jumps around and keeping track of addresses in your head might be OK for rain man but I find it hard. I'm more of a misty drizzle man so it's time to bring in the big guns.

**Yak shave 2: Get to grips with Ghidra**

Ghidra is a reverse engineering tool. Free, unlike all its competitors, and the work of the NSA so I'm on their list now. I fumbled around for a while but to be honest far less than I was imagining. With the Einy Chuckie binary loaded it was a matter of selecting the correct CPU architecture and a couple of other parameters such as the loading offset. Z80 is natively supported, as are most processors. After a bit more fumbling I found the decompile option which went off and produced both an assembler listing and C code that approximated the code flow. That was useless however, as it's pure brute force and it was confused by the hand-crafted nature of the machine code. Assembler programming is, as you should know, a work of art in many cases. We all have our little tricks and optimisations, and any large scale assembler project inevitably develops ... quirks. Vestigial code. Self modifying sections. Routines that never return. Data sprinkled liberally thoughout code. On top of this every authour has their own unique fingerprint, accent if you will. So no C today thanks.

Ghidra allows you to comment the assembler, jump around the code using hyperlinks, see where code and data are referenced from (SO useful!) and rename the auto-generated labels once you start making sense of things. I love it. I couldn't have done this without it. Most commands have a single key shortcut and once you've learned these navigating and documenting is a brisk breeze.

Focussing on the input routine I could add labels and gradually untangle the flow. In fact I spent a couple of hours jumping around the place identifying unrelated functions and variables. It was like a brilliant puzzle and the time just flew. I highly recommend this as a rainy day activity. After a while I'd found the main game loop, the intro screen, keyboard remapper, music player, and a bunch of other stuff. A lot of the screen update is done with a custom print-string routine. There are a defined set of control codes for positioning and colouring the text. It's pretty nice. And it makes changing things easy too ;)

Back to the task at hand. Most microcomputer game input is based around a couple of ideas: get the raw bits from the matrix, provide mechanism for mapping these to a keycap representation.

With the parts of the code identified I had to work out how to change them. It would require a lot of poking of bytes and like I said before, we need to be able to reproduce this at any time from the ground up so no hex editing for me. We need to patch binaries. Search internet. Waste time. All the patching tools I found were too heavyweight. I have a very specific workflow here - replace bytes in-place.

**Yak shave 3: Write a patcher**

I needed something with as few steps as possible so came up with the following plan:

* Make patch file in the assembler.
* Apply this patch to the binary.

A simple data structure defining the patch offset and length followed by the patch bytes themselves seemed like a fine idea. So I wrote [a program](https://github.com/charlierobson/M5Cheg/tree/master/patcher) that would take the source binary, apply the patch binary and output the patched binary.

Like I said the patches are developed in assembler. I thought this was ideal because, well, most of the stuff I'd be patching was code so you may as well use the code-generating program to make the whole file. Patches look like this:
```
 .word <offset>
 .word <num bytes>
 code/data
 ...
 code/data
``` 
Simple!

The first patches were for the VDP IO addresses. Armed with the logging of IO accesses that I put in earlier I could define the [patch data](https://github.com/charlierobson/M5Cheg/blob/master/innout.asm) to modify them. With this in place the remapping hack can be removed from MAME. It's useful to add a warning in the emulator when a wrong IO address is accessed in case any remappings were missed. Some were, so that was a good investment.

BRASS isn't (as far as I know) able to define start addresses for each patch block so I had to use some tricks and a lot of mental math to calculate relative addresses, but this is easy enough if tedious. I'm sure I could come up with something if I thought hard enough. 

One thing I wish I'd done is work out a way to verify the correctness of each block because I got the byte count wrong _a lot_. It was, again, easy enough to correct but tedious. I considered having every patch block in its own separate asm file and then include all the binary output in one master asm file but many patches refer to one another so that would have been its own special pain. It was, however, a useful technique for a couple of patches that required generating offset tables, e.g. [key cap remapping](https://github.com/charlierobson/M5Cheg/blob/master/keycaptable.asm) which was assembled separately then included as a blob.

With the ability to patch the binary off I went! First thing was implementing keyboard reading code that fitted in the address space of the code that I was overwriting. For the most part this was OK, but some patches were larger than the space available to them so required finding a freed-up block of memory and relocating functions appropriately.

Most keyboard routines have a map of codes to keycap characters. For keycaps like SHIFT and ENTER there will be some extended value that represents the string. Setting the high bit of the character code is a common technique, with the low bits representing an index into a table of addresses pointing to the string data. I had to compromise on my chosen strings as the M5 has a lot more keys with extended representations so I had to be creative with descriptions and use techniques such as having a common string for things like SHIFT, which the M5 has 2 of.

From the title screen I could now press keys and have the game respond. I could get to instructions, the key remapper let me remap, and I could start the game. And what do you know, it worked! I was playing Chuckie Egg on the Sord! The graphics for the ducks (ostriches? hens? abominations?) were messed up, which led me onto another yakventure later, but it ran.

I'll assume that you don't believe that this all worked first time most of the time. It certainly didn't. It was a learning process.

I noticed that during keyboard remapping I wasn't allowed to use A or H as movement keys. This was tested in Einychuk, and yes it's a bug there too. It's because you can hold Esc + A or H during the game to abort or hold, respectively. The remap code checks which keys are already assigned and doesn't let you use them for multiple inputs, even though initially the game has QAOP as the character control keys so it's evidently not a problem. The Esc-keys aren't printed anywhere unlike the directions which are shown at the start screen. So nuking them in the key remap table by assigning an unused key code is perfectly fine and fixes that.

Most ports won't be this simple. To reiterate again I've been _super_ lucky that the source program 'fits' into the destination memory map and doesn't do anything super funky. I'm doing a little dance now. BRB.

So with the game essentially playable I have come to realise that the sound will be less than fun to work on. So I make an executive decision to ignore it for now and do some tidying up and look at the glitchy hen/ostrich/abomination bug.

#### Tidy up some rough edges.

First off I think I'd like my name in there. I changed the data in the high score table to say something like:
```
PORTED TO  1000
SORD M5    1000
BY CHARLIE 1000
2022       1000
...
```

While I thought I deserved the credit I also didn't like the vandalised look of it. I hate seeing people's names plastered over game hacks, etc. In a cracktro, sure. But in game, naah. Leave it alone. So with that in mind I just replaced the top entry of the high score table with my own name, and a score of 2022. I thought that was suitably subtle and was feeling much better about not being a hypocrite. I did however change the instruction screen by moving all the text up a line and adding `SORD M5 PORT BY CHARLIE ROBSON` in there right before the `PRESS A KEY` text. Conscience salved I girded my loins for the graphics bug.

It was obviously a memory issue. I decided to check memory accesses, to see if anything was writing data where it shouldn't - which on the M5 would be anywhere that wasn't program binary, $0000-$7fff and $c000-$ffff inclusive. With watchpoints set up in the MAME debugger I ran the game and just as the main game screen was shown I hit a watchpoint. And another and another. RAM was being written from $0000-$4000. The offending code was making a RAM copy of the VDP's screen buffer. Aha, this makes sense. The VDP has its own memory that you access via IO ports. You can't read or write it directly. If you want a fast way to check what's in front of the character, for example, you don't want to be making IO requests to do it.

The game is building the character based screen image from the level description data and then copying the resulting 'map' back into RAM where it can be read and written at will. This explained the corrupted henostribominations. The enemies are character mapped so the game gets the character code at the relevant position renders a new tile that mixes in the heno.. bird/enemy image. It's then popped back into screen memory. BUT the character peeked from the map was random garbage because, well, ROM at that address.

I'd have to move the screen copy and luckily I have $c000-$cfff so I just had to check if it was free by running the game with watchpoints there. And it was. So everywhere that the offscreen map was accessed got a patch. It wasn't trivial as the screen access addresses in vram mapped directly to the offscreen RAM copy. So any address that accessed the RAM map would have to have its top 2 bits set temporarily. Luckily there weren't too many places this happened and with this fix in place we had ungarbled enemies.

About this time I was wondering why the original author didn't use sprites. I suspect it's to do with player/enemy collision but I can't be sure. It would make sense but a hybrid approach would have been much less work and result in a nicer look, as the enemies suffer from attribute clash. Sigh. Perhaps the original Einy version was itself ported from another system? I'd love to find out.

The game is looking pretty sweet now. And I can't put it off any longer - it's sound time.

#### Do the sound.

The AY and SN are very different chips. The AY has some envelope generation capability and a wide pitch range with the ability to mix in noise to each channel. The SN has 4 basic voices, one of which is noise. The AY has 8 registers to tweak, accessed through 2 different IO ports. The SN is similar except register accesses are all through the same port.

There are literally dozens of different sound chip IO requests being made, My heart is sinking at this point. I thought I'd start off with getting the title tune working as it seemed to be fairly localised and had what looked like a very simple player. Most sound routines work in a similar way. Data defines register changes over time. Looking at the player code it looked something like this:

* Get note number.
* Map note to sound chip pitch value.
* Play tone.
* Apply a volume envelope over time.
* Repeat.

There's more to it in practice, but not much more - the tune is made up of segments and the main player plays these in sequence. Luckily all the sounds are played on a single channel and there is a single volume envelope using a table.

Step one was to work out where the tones were being produced and simply map the AY register update methods to the YM. With this done I was hearing a tune but it was all over the place. The tone table would need re-calculating so it's off to the Yak barber again.

**Yak shave 4: Calculate some tone tables**

For this I searched the internet for a spreadsheet of note -> frequency data. Fairly specific, sure, but it's the internet and anything that can exist [will exist](https://docs.google.com/spreadsheets/d/1pA92TLTJJFiT3A1J9LcigpUevuYeDMujeMDCEPJ63hc/edit). With spreadsheet in hand I worked out the sums required to map frequency to the required tone values for the chip. However this was proving difficult to export from the sheet so I got to [practice my Python](https://github.com/charlierobson/M5Cheg/blob/master/tonetable.py). I took the liberty of generating one for the AY too, using the same range. Comparing the AY table to the one in the code I saw - happily - that the note number -> tone table mapping was close enough to not worry about it. Which is a relief. It meant I can simply use the YM table that I generated and the tones should be close enough.

With the newly generated tone tables in place we get tunes! Sound effects are going to need to be understood a bit more as they're associated with game state.

There's lots of Ghidra-ing (I've used it so by the rules of the internet it now exists as a word) being done here. You do an inordinate amount of tracing program flow in reverse, starting where you see output to the sound chips and working back to where these routines are called from, working out what memory variables might be meaning as you go. Backtrack. Repeat. Oftentimes you're wrong but Ghidra makes updating the results of your thoughts in real time super easy.

That said it's never a case of just jump to some code, immediately understand it, write the patch and you're done. Oh no. Trying to work out someone's intent from a few lines of machine code where registers are being flung around like so much monkey poo in a cage of very excitable Macaques is akin to listening to 10 conversations simultaneously and being expected to parse the information from them reliably.

Fortunately like most difficult things you get better at them with practice.

Once you've understood which variables contain flags relating to whether the player is in the air or on a ladder, which contain the coordinates of your man, etc etc, then you're in a much better place to be able to craft something that does an acceptable job of replicating the intent of the sounds in the game - if not the sounds themselves. For example, the envelope generators of the AY are brought into play for the end of level bonus sound. You simply set up a repeating 'ting' sound and turn it off when done. This can't be replicated on the YM, so I'll be needing to find (relatively) big blocks of free memory to put the code that will do something similar.

Luckily the source binary is less than 16k, and once some bytes are allocated to the cartridge header and relocator there is still about 500 bytes free for me to use. Rather than pad the source binary I opted to create a little buffer file and concat that to the game binary as part of the build. Reproducible, remember? With some extra bytes available I can start adding improvements like the bonus ting. 

Around this time I found that collecting seed wasn't halting the bonus countdown like it was supposed to. So off we go again, looking to see how we can patch the code to make this happen. 

Most patches are in-place replacements but others are wedges - CALLs to routines you've crafted elsewhere in memory. These will contain the patched-out code, plus whatever else is required to make your thing work. This is what you need to do in order to add features or larger fixes. From the top of my head the major features I added were the seed/bonus interaction, bonus countdown tinger, and instruction screen credits.

I hope this has been a fun read even if you didn't get most of my stream of consciousness explanations. I'm a lover not a writer and so if there are any fatal mistakes don't blame me. Lover? Sorry, I meant Logger.

/Chuck
