# Quick guide to install and use the Haujobb Amiga Framework on macOS

## Download:

### To Crosscompile with makefiles you need 3 files:
* (1) VBCC Binary for macOS and (2) the target m68k-amigaos
    * http://sun.hasenbraten.de/vbcc/
* (3) the NDK 3.9
    * http://www.haage-partner.de/download/AmigaOS/NDK39.lha

### Misc utilities:
* To easily decompress lha files and tons of other archives, you can use Keka
    * https://www.keka.io/en/

## Install:
* Choose a directory for the toolchain
* Extract the VBCC binaries, target and NDK39 there, the layout should be:
```
./toolchain
├── bin
│   └── ...
├── config
│   ├── aos68k
│   ├── aos68km
│   ├── aos68kr
│   └── vc.config (<<< see below)
├── NDK39
│   ├── Documentation
│   ├── Examples
│   ├── Include
│   └── ...
└── targets
    └── m68k-amigaos
        └── ...
```
* make a `config/vc.config` by copying the `aos68k` file and replace all occurences of:
    * `vincludeos3:` by `$VBCC/targets/m68k-amigaos/include`
    * `vlibos3:` by `$VBCC/targets/m68k-amigaos/lib/`
    * the `-rm=delete quiet %s` line by `-rm=rm -f %s`
    * the `-rmv=delete %s` line by `-rmv=rm %s`

* setup the `$VBCC` environment variable, pointing to your chosen toolchain folder, in your user profile (`.profile` or `.bashrc` or `.zshrc` or whatever your shell is)
```
export VBCC=[PATH TO YOUR VBCC TOOLCHAIN FOLDER OF CHOICE]
```

You should now be able to compile any example by running `make` in their respective "build" folder

For the rest of the usages, please refer to the main documentation
