#ifndef MALLOC_H
#define MALLOC_H

#ifdef AMIGA
#include <libraries/dos.h>
#include <stdio.h>

#include <stdlib.h>

//int write(int handle, void* data, int size);

#else

// windows
#include <stdlib.h>
#include <malloc.h>

#endif

static unsigned char* memAlign16(unsigned char* ptr)
{
   return (unsigned char*) (((unsigned int)ptr + 15) & ~15);
}

void malloc_debug();
int malloc_totalSize();
int malloc_totalCalls();

#ifdef USE_MEM_DEBUG

void* myalloc(int size);
void myfree(void* data);
void malloc_debug();

#define malloc myalloc
#define free myfree

#endif

#define new(type, count) (type*)malloc(sizeof(type)*(int)count)

#endif
