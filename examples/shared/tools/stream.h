#ifndef STREAM_H
#define STREAM_H

#include <stdio.h>

typedef struct
{
   FILE *mFile;
   unsigned int position;
   unsigned char *buffer;
   unsigned char *source;
   int capacity;
   int atEnd;
   int endian;
} Stream;

Stream* streamCreate(const char *filename);
int streamInit(Stream *stream, const char *filename);
void streamRelease(Stream *stream);

unsigned char* streamBuffer(Stream* stream);
int streamCapacity(Stream* buffer);
void streamRefill(Stream* stream);

void streamRead(Stream *stream, void *dst, int size);
float streamReadFloat(Stream *stream);
int streamReadInt(Stream *stream);
char streamReadChar(Stream *stream);
unsigned char streamReadByte(Stream *stream);
unsigned short streamReadWord(Stream *stream);
short streamReadShort(Stream *stream);
void streamSkip(Stream *stream, int size);
int streamReadString(Stream*, char*);
char* streamReadPascalString(Stream *stream);
int streamReadLine(Stream*, char*);
unsigned int streamPosition(Stream*);
void streamSetEndian(Stream* stream, int big);
int streamAtEnd(Stream *stream);
int streamBufferedSize(Stream* stream);

#endif
