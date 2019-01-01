# The Haujobb Amiga Framework, Happy New Year release, 01.01.19

## What is this about?
C/Asm framework, targeted at Amiga AGA/060, integrated with Rocket,
working natively on Windows, with full source and docs.

This is the framework that we came up with to develop our demos, like Beam Riders (http://www.pouet.net/prod.php?which=71976).

## Why should I care?
* Did you ever wanted to code an Amiga demo?
* Are you a coder that doesn't know the Amiga, yet?
* Do you also think that not everything should be coded in Assembler?
* Want to know how we do our demos in Haujobb?
* C sounds interesting?

Then this release should be of interest to you! We are giving you all the details of how to do it.

## Documentation
Yes, quite a bit of it, and including a quickstart section.
* HTML-Version: http://www.dig-id.de/amiga/framework/
* PDF-Version: http://www.dig-id.de/amiga/framework/haf.pdf

Read it, it will take you through:
* required tool setup PC and Amiga (optional)
* compiling and cross-compiling a hello-world.c
* 3 example effects (stars, picture, movetable)
* 1 integrated demo project (with 3 effects, ADPCM sound, and using Rocket for syncing)

## Dependencies
* vasm/vbcc/vlink/GNU Make for cross-compiling to the Amiga
* a native C-compiler for your host platform
    * tested on Windows with Visual Studio (any Community or Pro version)
* Qt Creator
    * using Qt5 (default) or Qt4 at your choice (depending on your compiler)
* Rocket from https://github.com/rocket/rocket

The dependencies, including download links are covered in detail in the documentation.

## Other
Check out our talk about Modern Amiga Demo Cross-Development from Evoke 2018 at
https://www.youtube.com/watch?v=s1lVS4tW33g



