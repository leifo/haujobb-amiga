#include "stream.h"
#include "malloc.h"
#include <string.h>

// diesen zeiger einfach auf den gelinkten datenblock zeigen lassen
// (archiv wird dann nicht mehr geladen)
unsigned char *mArchive= 0;
static unsigned int machineEndian= -1;

#define ARCHIVEFILE "prototype1.dat"

#define BUFFER_SIZE 16384

Stream* streamCreate(const char *filename)
{
   Stream *stream= malloc( sizeof(Stream) );
   streamInit(stream, filename);
   return stream;
}

void swapWord(unsigned short *dst)
{
   unsigned short w= *dst;
   *dst= (w<<8 & 0xff00) | (w>>8 & 0x00ff);
}

void swapDWord(unsigned int *dst)
{
   unsigned int d= *dst;
   *dst= (d>>24 & 0xff) | (d>>8 & 0xff00) | (d<<8 & 0xff0000) | (d<<24 & 0xff000000);
}


unsigned char* checkArchive(const char *filename, int *size)
{
   unsigned int i;
   unsigned int header;
   unsigned int length;
   unsigned int count;
   unsigned int toc;
   unsigned int *src= (unsigned int*)mArchive;

   if (!src)
      return 0;

   header= src[0];
   length= src[1];
   count= src[2];
   toc= src[3];

   if (machineEndian==0)
   {
      swapDWord(&header);
      swapDWord(&length);
      swapDWord(&count);
      swapDWord(&toc);
   }

   src= (unsigned int*) (mArchive + toc);

   for (i=0;i<count;i++)
   {
      unsigned int start;
      unsigned int length;
      unsigned int namepos;
      unsigned char *name;

      start= src[0];
      length= src[1];
      namepos= src[2];

      if (machineEndian==0)
      {
         swapDWord(&start);
         swapDWord(&length);
         swapDWord(&namepos);
      }

      name= mArchive + namepos;

      if (strcmp(name, filename)==0)
      {
         *size= length;
         return mArchive + start;
      }

      src+=4;
   }

   return 0;
}

int streamInit(Stream *stream, const char *filename)
{
   unsigned char *temp;
   int size;

   if (machineEndian==-1)
   {
      unsigned int data= 0x12345678;
      unsigned char* test= (unsigned char*)&data;
      if (test[0]==0x12 && test[1]==0x34 && test[2]==0x56 && test[3]==0x78)
         machineEndian= 1; // big endian
      else if (test[3]==0x12 && test[2]==0x34 && test[1]==0x56 && test[0]==0x78)
         machineEndian= 0; // little endian
      else
         machineEndian= 2; // error!
   }

   if (!mArchive)
   {
      int size;
      FILE *f= fopen(ARCHIVEFILE, "rb");
      if (f)
      {
         fseek(f, 0, SEEK_END);
         size= ftell(f);
         fseek(f,0,SEEK_SET);
         mArchive= malloc(size);
         fread(mArchive,1,size,f);
         fclose(f);
      }
   }

   temp= checkArchive(filename, &size);
   if (temp)
   {
      stream->mFile= 0;
      stream->position= 0;
      stream->buffer= temp;
      stream->source= temp;
      stream->capacity= size;
      stream->atEnd= 0;
      stream->endian= 0;

      return 1;
   }
   else
   {
      stream->mFile= fopen(filename, "rb");

      stream->position= 0;
      stream->buffer= malloc(BUFFER_SIZE);
      stream->source= 0;
      stream->capacity= 0;
      stream->atEnd= 0;
      stream->endian= 0;

      return (stream->mFile != 0);
   }

}

void streamRelease(Stream *stream)
{
   if (stream->mFile)
   {
      fclose(stream->mFile);

      if (stream->buffer)
      {
         free( stream->buffer );
         stream->buffer= 0;
      }
   }
}

unsigned char* streamBuffer(Stream* stream)
{
   return stream->source;
}

int streamCapacity(Stream* buffer)
{
   return buffer->capacity;
}

int streamAtEnd(Stream *stream)
{
   if (stream)
      return stream->atEnd;
   else
      return 1;
}

void streamRefill(Stream* stream)
{
   if (stream->capacity>0)
      memcpy(stream->buffer, stream->source, stream->capacity);

   stream->capacity += (int)fread(stream->buffer + stream->capacity, 1, BUFFER_SIZE-stream->capacity, stream->mFile);
   if (stream->capacity==0)
   {
      stream->capacity= BUFFER_SIZE;
      memset(stream->buffer, 0, BUFFER_SIZE);
      stream->atEnd= 1;
   }
   else
      stream->atEnd= 0;

   stream->source= stream->buffer;
}

void streamRead(Stream *stream, void *dst, int size)
{
   // noch genug im buffer
   if (size<=stream->capacity)
   {
      if (dst)
         memcpy(dst, stream->source, size);
      stream->source+=size;
      stream->capacity-=size;
      stream->position+=size;
   }
   else
   {
      char *tmp= (char*)dst;

      // copy rest of buffer
      if (stream->capacity)
      {
         if (tmp)
         {
            memcpy(tmp, stream->source, stream->capacity);
            tmp+=stream->capacity;
         }
         stream->position+=stream->capacity;
         size-=stream->capacity;
      }

      while (size)
      {
         int len= size;
         stream->capacity= (int)fread(stream->buffer, 1, BUFFER_SIZE, stream->mFile);
         if (stream->capacity==0)
         {
            stream->capacity= BUFFER_SIZE;
            memset(stream->buffer, 0, BUFFER_SIZE);
            stream->atEnd= 1;
         }
         else
            stream->atEnd= 0;
         stream->source= stream->buffer;
         if (len>stream->capacity)
            len= stream->capacity;
         if (tmp)
         {
            memcpy(tmp, stream->source, len);
            tmp+=len;
         }
         stream->capacity-=len;
         size-=len;
         stream->source+=len;
         stream->position+=len;
      }
   }
}

unsigned int streamPosition(Stream *stream)
{
   return stream->position;
}

char streamReadChar(Stream *stream)
{
   char c;
   streamRead(stream, &c, sizeof(char));
   return c;
}

unsigned char streamReadByte(Stream *stream)
{
   unsigned char c;
   if (stream->capacity > 0)
   {
      c= *stream->source++;
      stream->capacity--;
      stream->position++;
   }
   else
   {
      streamRead(stream, &c, sizeof(char));
   }
   return c;
}

unsigned short streamReadWord(Stream *stream)
{
   unsigned short w;
   streamRead(stream, &w, sizeof(short));
   if (stream->endian != machineEndian)
      swapWord(&w);
   return w;
}

short streamReadShort(Stream *stream)
{
   short w;
   streamRead(stream, &w, sizeof(short));
   if (stream->endian != machineEndian)
      swapWord(&w);
   return w;
}

float streamReadFloat(Stream *stream)
{
   float f;
   streamRead(stream, &f, sizeof(float));
   if (stream->endian != machineEndian)
      swapDWord((unsigned int*)&f);
   return f;
}

int streamReadInt(Stream *stream)
{
   int i;
   streamRead(stream, &i, sizeof(int));
   if (stream->endian != machineEndian)
      swapDWord(&i);
   return i;
}


int streamReadString(Stream *stream, char *dst)
{
   char c;
   int pos= 0;
   do {
      c= streamReadChar(stream);
      dst[pos++]= c;
   } while (c);
   return pos;
}

char* streamReadPascalString(Stream *stream)
{
   int i;
   int size= streamReadByte(stream);
   char* data= (char*)malloc(size);
   for (i=0; i<size; i++)
      data[i]= streamReadChar(stream);
   return data;
}

int streamReadLine(Stream *stream, char *dst)
{
   char c;
   int pos= 0;
   while (streamAtEnd(stream)==0)
   {
      c= streamReadChar(stream);
      if (c==0 || c==0xa || c==0xd)
         break;
      dst[pos++]= c;
   };
   dst[pos]= 0;
   return pos;
}

void streamSkip(Stream *stream, int size)
{
   if (size<=stream->capacity)
   {
      // if skipped position is still in the buffer:
      // just increase the pointers
      stream->source+=size;
      stream->capacity-=size;
      stream->position+=size;
   }
   else
   {
      streamRead(stream, 0, size);
   }
}


void streamSetEndian(Stream* stream, int big)
{
   stream->endian= big;
}

/*
int streamReadString(Stream* stream, char* text)
{
   int i;
   int len= streamReadByte(stream);
   for (i=0; i<len; i++)
      text[i]= streamReadByte(stream);
   return len;
}
*/

int streamBufferedSize(Stream* stream)
{
   return stream->capacity;
}
