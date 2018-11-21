vasmm68k_mot -Fhunk -m68020 -m68882 wos_v1.63.s -o wostest.o -Ic:/vbcc/NDK39/Include/include_i -DWTEST
vlink wostest.o -o wostest
