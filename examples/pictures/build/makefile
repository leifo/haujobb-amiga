# 04.01.12, Leif Oppermann, lop@gmx.de
# Dieses Makefile repraesentiert eigentlich den von mir gewuenschten Ansatz, 
# aber leider ist VPATH auf dem Amiga GNU Make 3.74 defekt und verhaelt sich anders als das PC GNU Make 3.81.

# angedacht: alle SOURCES einfach auflisten, TARGET setzen, fertig. Laeuft so auch auf PC,
# aber der Amiga findet die Quellen nicht ueber  VPATH.

SOURCES = main.c \
   pictureeffect.c \
   ../../shared/tools/mem32.c \
   ../../shared/tools/rand.c \
   ../../shared/tools/stream.c \
   ../../shared/image/gif.c 

	
TARGET = pictures

# PC oder Amiga Source-Dir relativ zum aktuellen Dir.
# - muesste man eigentlich auch automatisch an die Platform anpassen,
#   aber leider ist das noch so ein Thema, was nicht wie dokumentiert funktioniert
#   (ifdef COMSPEC[..], siehe http://www.makelinux.net/make3/make3-CHP-3-SECT-7)
#   weshalb es hier erstmal von Hand fuer den Amiga einkommentiert werden kann.
SRCDIR = ../src
#SRCDIR = /src

### 
### ab hier sollte dann aber nichts mehr geaendert werden muessen
###

VPATH = $(SRCDIR)
#vpath %.c src
#vpath %.asm src

CFLAGS = -O=23999 -cpu=68060 -fpu=68060 -DAMIGA -speed -k
ASFLAGS =
LDFLAGS =

INCDIR = ../../shared
#LIBDIR =

# m040 m881
LIBS = posix amiga vc

#
# include $(VBCC)/targets/build.m68k
# copied in below (only small modifications in %o and clean targets and renamed a variable)

#CC       = vbccm68k
CC       = vc
AS       = vasmm68k
LD       = vlink

# Add includes and libraries.
#INCDIR   := $(INCDIR) ./ "$(VBCC)/posix/include" "$(VBCC)/targets/m68k-amigaos/include"
#LIBDIR   := $(LIBDIR) ./ "$(VBCC)/targets/m68k-amigaos/lib"
INCDIR   := $(VBCC)/posix/include $(VBCC)/targets/m68k-amigaos/include $(INCDIR) ./ 
LIBDIR   := C:\\VBCC/targets/m68k-amigaos/lib

# Strip everything if there's no debug infos
ifeq ($(findstring -g, $(CFLAGS)), -g)
else
 LDFLAGS  := $(LDFLAGS) -s
endif

# Set the math library to use
ifeq ($(findstring -fpu=68881, $(CFLAGS)), -fpu=68881)
 LDFLAGS  := $(LDFLAGS) -lm881
else
 ifeq ($(findstring -fpu=68040, $(CFLAGS)), -fpu=68040)
  LDFLAGS  := $(LDFLAGS) -lm040
 else
  ifeq ($(findstring -fpu=68060, $(CFLAGS)), -fpu=68060)
   LDFLAGS  := $(LDFLAGS) -lm881
  else
   LDFLAGS  := $(LDFLAGS) -lmieee
  endif
 endif
endif

# cflags:
# - temporarily removed: -quiet		
# - add -k if you want to see the *.asm temporary output
# - removed -c99 and -hunkdebug to remove double-definition warnings (already defined elsewhere, maybe through vc)
# - 01.03.2015 - removed -c (reported as " Unknown Flag <-c>", maybe due to newer tools?)
# profiling with -prof (https://github.com/kusma/vbcc/blob/master/doc/vprof.texi)
CFLAGS   := -DAMIGA -c -maxoptpasses=100 -inline-depth=100 -inline-size=30 $(addprefix -I, $(INCDIR)) -D__VBCC__ $(CFLAGS) -notmpfile

ASFLAGS  := -quiet -Fhunk -devpac $(ASFLAGS)

#            -lamiga \
#            -lvc \

LDFLAGS  := $(addprefix -L,$(LIBDIR)) \
            "$(VBCC)/targets/m68k-amigaos/lib/startup.o" \
            $(addprefix -l,$(LIBS)) \
            -Bstatic -bamigahunk -Cvbcc $(LDFLAGS)


#
# lists
#

LINKOBJ   = $(patsubst %.c, %.o, $(SOURCES))
LINKOBJ   := $(patsubst %.s, %.o, $(LINKOBJ))

DELOBJ1   = $(patsubst %.c, %.asm, $(SOURCES))
DELOBJ1   := $(patsubst %.s, %.o, $(DELOBJ1))
DELOBJ2   = $(patsubst %.c, %.o, $(SOURCES))
DELOBJ2   := $(patsubst %.s, , $(DELOBJ2))

OBJC     = $(patsubst %.c, %.o, $(SOURCES))
OBJASM   = $(patsubst %.s, %.o, $(SOURCES))

all: $(TARGET)

#
# link	
#

$(TARGET): $(OBJC) $(OBJASM)
	@echo "******* Linking: $(TARGET)"
	@echo $(LDFLAGS)
	@echo " " 
	$(LD) $(LDFLAGS) -o $(TARGET) $(LINKOBJ) ../../../wos/wickedquicklink.o
	@echo " " 

#
# compile 
#

%.o : $(SRCDIR)/%.c
	@echo "******* Compiling $< to $@"
#	$(CC) $(CFLAGS) -o $(notdir $@) $<
	$(CC) $(CFLAGS) -o $@ $<
#	$(CC) $(CFLAGS) -o $@ $(SRCDIR)/$<
	@echo " "

%.o : %.s
	$(AS) $(ASFLAGS) -o $@ $<

#
# clean
#

clean:
	-rm -f $(TARGET)
#	-rm -f $(DELOBJ1)
	-rm -f $(DELOBJ2)
            

            

