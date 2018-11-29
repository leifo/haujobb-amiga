TARGET = hellomake

SOURCES = hello.c

# - add -k if you want to see the *.asm temporary output
CFLAGS = -O=1 -cpp-comments -cpu=68000 -fpu=none

CC       = vc

#
# lists
#

DELOBJ1   = $(patsubst %.c, %.asm, $(SOURCES))
DELOBJ1   := $(patsubst %.s, %.o, $(DELOBJ1))
DELOBJ2   = $(patsubst %.c, %.o, $(SOURCES))


all: $(TARGET)

#
# compile 
#

$(TARGET): $(SOURCES) 
	@echo "******* Compiling and linking $< to $@"
	$(CC) $(CFLAGS) -o $@ $<

#
# clean
#

clean:
	-rm -f $(TARGET)
	-rm -f $(DELOBJ1)
	-rm -f $(DELOBJ2)
            

