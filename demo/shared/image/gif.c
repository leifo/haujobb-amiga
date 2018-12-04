#include "tools/stream.h"
#include "tools/malloc.h"
#include "math/imath.h"

// Gif internal definitions:
#define LZ_MAX_CODE     4096    // Largest 12 bit code
#define LZ_BITS         12

#define FLUSH_OUTPUT    4096    // Impossible code = flush
#define FIRST_CODE      4097    // Impossible code = first
#define NO_SUCH_CODE    4098    // Impossible code = empty

typedef struct
{
    int            depth;
    int            clear_code;
    int            eof_code;
    int            running_code;
    int            running_bits;
    int            max_code;
    int            prev_code;
    int            current_code;
    int            stack_ptr;
    int            shift_state;
    unsigned int   shift_data;
    unsigned char* buf;
    unsigned char* end;
    unsigned char  stack[LZ_MAX_CODE];
    unsigned char  suffix[LZ_MAX_CODE];
    unsigned short prefix[LZ_MAX_CODE];
} GifDecoder;


// read the next byte from a Gif file.
static void gifRefill(Stream* file, GifDecoder *decoder)
{
   // skip current block
   int size;
   size= streamReadByte(file);
   if (size == 0)
   {
      decoder->end= 0;
   }
   else
   {
      if (streamCapacity(file) < size)
         streamRefill(file);
      decoder->buf= streamBuffer(file);
      decoder->end= decoder->buf + size;
      streamSkip(file, size);
   }
}

// read the next byte from a Gif file.
static unsigned int _INLINE_ gifReadByte(Stream* file, GifDecoder *decoder)
{
   unsigned int next;

   if (decoder->buf >= decoder->end)
   {
      gifRefill(file, decoder);
   }

   next= *(decoder->buf)++;

   return next;
}


// read to end of an image, including the zero block.
static void gifFinish(Stream* file, GifDecoder *decoder)
{
   while (decoder->end != 0)
   {
      gifRefill(file, decoder);
   }
}


// read gif palette
static void gifReadPalette(Stream* file, unsigned int* pal, int info)
{
   unsigned char temp[1024];
   if ((info & 0x80) == 0x80)  // has color map
   {
      unsigned char* src= temp;
      int color_res=   ((info & 0x70) >> 4) + 1; // always 8 bit
      int cmap_depth=  (info & 0x07)        + 1;
      int size= 1 << cmap_depth;

      streamRead(file, temp, size*3);
      while (size--)
      {
         int r= *src++;
         int g= *src++;
         int b= *src++;
         *pal++= (r<<16) | (g<<8) | b;
      }
   }
}

void gifResetDecoder(GifDecoder *decoder)
{
   int i;
   decoder->running_code= decoder->eof_code + 1;
   decoder->running_bits= decoder->depth + 1;
   decoder->max_code=     1 << decoder->running_bits;
   decoder->prev_code=    NO_SUCH_CODE;

   for (i= 0; i<LZ_MAX_CODE; i++)
      decoder->prefix[i]= NO_SUCH_CODE;
}

// init decoder
static void gifInitDecoder(Stream* file, GifDecoder *decoder)
{
   int depth;

   depth= streamReadByte(file);

   decoder->depth=        depth;
   decoder->clear_code=   (1 << depth);
   decoder->eof_code=     decoder->clear_code + 1;
   decoder->stack_ptr=    0;
   decoder->shift_state = 0;
   decoder->shift_data=   0;

   decoder->buf=          0;
   decoder->end=          0;

   gifResetDecoder(decoder);
}


// read the next Gif code word from the file.
static int _INLINE_ gifReadCode(Stream* file, GifDecoder *decoder)
{
   int code;
   unsigned int next_byte;

   while (decoder->shift_state < decoder->running_bits)
   {
      /* Need more bytes from input file for next code: */
      next_byte= gifReadByte(file, decoder);
      decoder->shift_data |= next_byte << decoder->shift_state;
      decoder->shift_state += 8;
   }

   code= decoder->shift_data & ((1 << decoder->running_bits)-1);

   decoder->shift_data >>= decoder->running_bits;
   decoder->shift_state -= decoder->running_bits;

   /* If code cannot fit into running_bits bits,
    * we must raise its size.
    * Note: codes above 4095 are used for signalling. */
   if (++decoder->running_code > decoder->max_code
      && decoder->running_bits < LZ_BITS)
   {
      decoder->max_code <<= 1;
      decoder->running_bits++;
   }
   return code;
}


// trace the prefix-linked-list until we get a prefix which is a pixel value
// return pixel value.
static int gifTracePrefix(unsigned short* prefix, int code, int clear_code)
{
   // If the picture is defective, we might loop here forever,
   // so we limit the loops to the maximum possible if the picture is okay, i.e. LZ_MAX_CODE times.
   while (code > clear_code)
   {
/*
	  if (code < 0 || code >= LZ_MAX_CODE)
	  { 
		  printf("out of range!");
	  }
*/
	  code = prefix[code];
   }

   return code;
}


// the LZ decompression routine
// call this function once per scanline to fill in a picture.
static void gifReadLine(Stream* file, unsigned char* dst, GifDecoder* decoder, int length)
{
   int i= 0, j= 0;
   int current_code;
   int eof_code;
   int clear_code;
   int current_prefix;
   int prev_code;
   int stack_ptr;
   unsigned char* stack;
   unsigned char* suffix;
   unsigned short* prefix;

   prefix=     decoder->prefix;
   suffix=     decoder->suffix;
   stack=      decoder->stack;
   stack_ptr=  decoder->stack_ptr;
   eof_code=   decoder->eof_code;
   clear_code= decoder->clear_code;
   prev_code=  decoder->prev_code;

   if (stack_ptr != 0)
   {
      /* Pop the stack */
      while (stack_ptr != 0 && i < length)
         dst[i++]= stack[--stack_ptr];
   }

   while (i < length)
   {
      current_code= gifReadCode(file, decoder);

      if (current_code == eof_code)
      {
         /* unexpected EOF */
         if (i != length - 1)
            return;
         i++;
      }
      else if (current_code == clear_code)
      {
         gifResetDecoder(decoder);
         prev_code= NO_SUCH_CODE;
      }
      else
      {
         /* Regular code - if in pixel range
          * simply add it to output pixel stream,
          * otherwise trace code-linked-list until
          * the prefix is in pixel range. */
         if (current_code < clear_code)
         {
            /* Simple case. */
            dst[i++]= current_code;
         }
         else
         {
            /* This code needs to be traced:
             * trace the linked list until the prefix is a
             * pixel, while pushing the suffix pixels on
             * to the stack. If finished, pop the stack
             * to output the pixel values. */
            if ((current_code < 0) || (current_code >= LZ_MAX_CODE))
               return; /* image defect */
            if (prefix[current_code] == NO_SUCH_CODE)
            {
               /* Only allowed if current_code is exactly
                * the running code:
                * In that case current_code = XXXCode,
                * current_code or the prefix code is the
                * last code and the suffix char is
                * exactly the prefix of last code! */
               if (current_code == decoder->running_code - 2)
               {
                  current_prefix= prev_code;
                  suffix[decoder->running_code - 2]= stack[stack_ptr++]= gifTracePrefix(prefix, prev_code, clear_code);
               }
               else
               {
                  return; /* image defect */
               }
            }
            else
            {
               current_prefix= current_code;
            }

            /* Now (if picture is okay) we should get
             * no NO_SUCH_CODE during the trace.
             * As we might loop forever (if picture defect)
             * we count the number of loops we trace and
             * stop if we get LZ_MAX_CODE.
             * Obviously we cannot loop more than that. */
            while ( current_prefix > clear_code && current_prefix < LZ_MAX_CODE )
            {
                stack[stack_ptr++]= suffix[current_prefix];
                current_prefix= prefix[current_prefix];
            }
            if (j >= LZ_MAX_CODE || current_prefix >= LZ_MAX_CODE)
                return; /* image defect */

            /* Push the last character on stack: */
            stack[stack_ptr++]= current_prefix;

            /* Now pop the entire stack into output: */
            while (stack_ptr != 0 && i < length)
                dst[i++]= stack[--stack_ptr];
         }

         if (prev_code != NO_SUCH_CODE)
         {
            if (   decoder->running_code < 2
                || decoder->running_code > (LZ_MAX_CODE+1) )
               return; /* image defect */

            prefix[decoder->running_code - 2]= prev_code;

            if (current_code == decoder->running_code - 2)
            {
               /* Only allowed if current_code is exactly
                * the running code:
                * In that case current_code = XXXCode,
                * current_code or the prefix code is the
                * last code and the suffix char is
                * exactly the prefix of the last code! */
               suffix[decoder->running_code - 2]= gifTracePrefix(prefix, prev_code, clear_code);
            }
            else
            {
               suffix[decoder->running_code - 2]= gifTracePrefix(prefix, current_code, clear_code);
            }
         }
         prev_code= current_code;
      }
   }

   decoder->prev_code= prev_code;
   decoder->stack_ptr= stack_ptr;
}


// read gif file
int gifLoad(const char* filename, void** buffer, int* outWidth, int* outHeight, unsigned int* pal)
{
   Stream file;
   char header[6];
   int w,h;
   int res;
   int bgColor;
   int aspect;
   unsigned char info;
   unsigned char* data= 0;
   GifDecoder decoder;

   res= streamInit(&file, filename);

   streamRead(&file, header, 6);

   if (   header[0]!='G'
       || header[1]!='I'
       || header[2]!='F')
      return 0;

   w= streamReadWord(&file);
   h= streamReadWord(&file);

   info=     streamReadByte(&file);
   bgColor=  streamReadByte(&file);
   aspect=   streamReadByte(&file);

   gifReadPalette(&file, pal, info);

   if (buffer) // if buffer is 0, only the global palette is loaded!
   {
   while (1)
   {
      int blockId= streamReadByte(&file);
      if (blockId == 0x2C)
      {
         // image block
         int left=   streamReadWord(&file);
         int top=    streamReadWord(&file);
         int width=  streamReadWord(&file);
         int height= streamReadWord(&file);

         info= streamReadByte(&file);
         gifReadPalette(&file, pal, info);

         data= (unsigned char*)malloc(width * height);
         *buffer= data;

         gifInitDecoder(&file, &decoder);

         while (height--)
         {
            gifReadLine(&file, data, &decoder, w);
            data+=w;
         }
         gifFinish(&file, &decoder);
      }
      else if (blockId == 0x21)
      {
         // extension block
         int size;
         unsigned char marker= streamReadByte(&file);

         do {
            size= streamReadByte(&file);
            streamSkip(&file, size);
         } while (size>0);
      }
      else // terminator
      {
         break;
      }
   }
   }

   if (outWidth) *outWidth= w;
   if (outHeight) *outHeight= h;

   streamRelease(&file);
   return 1;
}

