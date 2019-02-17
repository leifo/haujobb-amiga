AS = vasmm68k_mot

ASFLAGS = -Fhunk -m68020 -m68882 -I$(VBCC)/NDK39/Include/include_i 

all:	subdir wickedlink.o wickedquicklink.o wostest
	
subdir:
	(cd sub && $(MAKE))
	
clean:
	(cd sub && $(MAKE) clean)
	rm wostest
	rm wostest.o
	rm wickedlink.o
	rm wickedquicklink.o
	
wickedlink.o: wickedlink.s
	$(AS) wickedlink.s -o wickedlink.o $(ASFLAGS)

wickedquicklink.o: wickedquicklink.s
	$(AS) wickedquicklink.s -o wickedquicklink.o $(ASFLAGS)

wostest.o: wos_v1.63.s
	$(AS) wos_v1.63.s -o wostest.o $(ASFLAGS) -DWTEST 

wostest: wostest.o
	vlink wostest.o -o wostest
