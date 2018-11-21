# 21.09.18, Leif Oppermann, lop@gmx.de
# make WickedOS C2P plug-in binaries

SRCDIR= chunky

SOURCES = $(SRCDIR)/1x1x8_c5.s  \
          $(SRCDIR)/1x2x8_c5.s \
	  $(SRCDIR)/2x1x8_c5.s \
	  $(SRCDIR)/mode4.s \
	  $(SRCDIR)/mode5.s \
	  $(SRCDIR)/mode6-2016.s \
	  $(SRCDIR)/1x1x6_c5.s \
	  $(SRCDIR)/mode8_1x1_8_c5_040.s \
	  $(SRCDIR)/mode9_1x2x8_c5.s \
	  $(SRCDIR)/mode10_2x1x8_c5.s \
	  $(SRCDIR)/mode11_18bit-2016.s \
	  $(SRCDIR)/mode12_hires.s \
	  $(SRCDIR)/mode13_hiresinterlace.s \
	  $(SRCDIR)/mode14_1x1x6_c5.s \
	  $(SRCDIR)/mode15_1x1x5_c5.s \
	  $(SRCDIR)/mode16_1x1x8_c5.s \
	  $(SRCDIR)/mode17_c2p_15bit.s \
	  $(SRCDIR)/mode18_c2p_15bit.s \
	  $(SRCDIR)/mode19_c2p_15bit.s \
	  $(SRCDIR)/mode20_c2p_18bit.s \
	  $(SRCDIR)/mode21_c2p_18bit.s \
	  $(SRCDIR)/mode22_c2p_18bit.s \
	  $(SRCDIR)/mode23_c2p_12bit.s \
	  $(SRCDIR)/mode24_1x1x5.s \
	  $(SRCDIR)/mode25_1x1x5.s 

AS       = vasmm68k_mot
ASFLAGS  = -Fbin -no-opt -m68020


#
# lists
#

DELOBJ   := $(patsubst %.s, %.bin, $(SOURCES))
OBJASM   = $(patsubst %.s, %.bin, $(SOURCES))

all: $(OBJASM)


#
# assemble
#

%.bin : %.s
	$(AS) $(ASFLAGS) -o $@ $<
#	$(AS) $(ASFLAGS) -o $(DSTDIR)$(@F) $<
# c.f. https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html

#
# clean
#

clean:
	-rm -f $(DELOBJ)
#	echo "$(DELOBJ)"
#	$(foreach filename,$(DELOBJ),vrm -f "$(filename)")
