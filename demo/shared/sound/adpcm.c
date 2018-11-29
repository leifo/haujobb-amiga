#include "tools/stream.h"
#include "tools/malloc.h"

#define WAV_RIFF   0x46464952   // "RIFF"
#define WAV_WAVE   0x45564157   // "WAVE"
#define WAV_FORMAT 0x20746d66   // "fmt "
#define WAV_IMA    0x11         // format id for IMA ADPCM

static void convertNibbleOrderMono(unsigned int* dst, unsigned int* src, int count)
{
   unsigned int l;

   do
   {
      l= *src++;

      // flip upper/lower nibbles
      l= (l<<4&0xf0f0f0f0) | (l>>4&0x0f0f0f0f);

      // store separate bitstreams
      *dst++= l;
   } while (--count);
}

static void convertNibbleOrderStereo(unsigned int* dstL, unsigned int* dstR, unsigned int* src, int count)
{
   unsigned int l;
   unsigned int r;

   do
   {
      l= *src++; // always 32bit (8 samples) left
      r= *src++; // ...and 32bit (8 samples) right

      // flip upper/lower nibbles
      l= (l<<4&0xf0f0f0f0) | (l>>4&0x0f0f0f0f);
      r= (r<<4&0xf0f0f0f0) | (r>>4&0x0f0f0f0f);

      // store separate bitstreams
      *dstL++= l;
      *dstR++= r;
   } while (--count);
}

int adpcmLoad(const char* filename, unsigned char** outLeft, unsigned char** outRight, int* outRate)
{
   Stream stream;
   unsigned int   riff;
   unsigned int   filesize;
   unsigned int   wave;
   unsigned int   fmt;
   unsigned int   fmtSize;
   unsigned short format;
   unsigned short channels;
   unsigned int   rate;
   unsigned int   bps;
   unsigned short align;
   unsigned short bits;
   unsigned short cbSize;
   unsigned int   data;
   unsigned int   datasize;
   unsigned char* left= 0;
   unsigned char* right= 0;
   unsigned char* start= 0;

   if (streamInit(&stream, filename) == 1)
   {
//      streamSetEndian(&stream, 1);

      // read wave header
      riff= streamReadInt(&stream);
      filesize= streamReadInt(&stream);
      wave= streamReadInt(&stream);
      fmt= streamReadInt(&stream);

      if ( riff==WAV_RIFF && wave==WAV_WAVE && fmt==WAV_FORMAT )
      {
         fmtSize= streamReadInt(&stream);
         format= streamReadWord(&stream);
         channels= streamReadWord(&stream);
         rate= streamReadInt(&stream);
         bps= streamReadInt(&stream);
         align= streamReadWord(&stream);
         bits= streamReadWord(&stream);

         // ima adpcm 4bit delta
         if ( format==WAV_IMA && bits==4 )
         {
            if (fmtSize > 16)
            {
               cbSize= streamReadWord(&stream);
               streamSkip(&stream, cbSize);
            }
            data= streamReadInt(&stream);
            datasize= streamReadInt(&stream);

            if (channels == 2)
            {
               const int blocksize= (align-8)>>1;
               left= (unsigned char*)malloc(datasize>>1);
               right= (unsigned char*)malloc(datasize>>1);
               start= left;

               if (outLeft) *outLeft= left;
               if (outRight) *outRight= right;

               while (datasize >= align)
               {
                  unsigned char* src;
                  if (streamCapacity(&stream) < align)
                     streamRefill(&stream);

                  src= streamBuffer(&stream);

                  convertNibbleOrderStereo(
                           (unsigned int*)left,
                           (unsigned int*)right,
                           (unsigned int*)(src+8),
                           blocksize>>2
                  );
                  left+= blocksize;
                  right+= blocksize;

                  streamSkip(&stream, align);

                  datasize -= align;
               }
            }
         }
      }

      streamRelease(&stream);
   }

   if (outRate) *outRate= rate;

   return left - start;
}

