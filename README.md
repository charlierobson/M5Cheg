# M5Cheg

### Porting Tatung Einstein Chuckie Egg to the Sord M5.

Well this was a thing I didn't think I'd end up doing but here we are. To be honest I thought it was going to be much harder than it turned out to be but that was just luck. A lot of features of the code were totally flukey and helped the port immensely. I chose Chuckie Egg as a target because:

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
* Some way of patching the source binary

I hadn't used Ghidra before, and all the binary patching solutions I was aware of didn't fit my requirements so there's ahother task. Building MAME is something I'm used to so that shouldn't be hard, right..?

But I'm getting ahead of myself. We should see what we're up against. 

#### Step 0. See what we're up against.

Get MAME, all the bits required to run Tatung and Sord. Chuckie Egg disk image in `roms\einstein\chuckie\chuckie.dsk`. Tatung DOS is based off CPM and loads binaries at $100. So start MAME in debug mode, and when the debugger appears set a breakpoint at $100. Boot chuckie and see what happens.

`> MAME Einstein -debug -uimodekey HOME chuckie`



#### Step 1. See something.

