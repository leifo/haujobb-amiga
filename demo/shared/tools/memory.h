#ifndef MEMORY_H
#define MEMORY_H

#ifdef AMIGA

void memset(void*,unsigned char val,int size);
void memcpy(void*,void*,int);

#else

#include <memory.h>

#endif

#endif
