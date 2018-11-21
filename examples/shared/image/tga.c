// basic tga loader

#include "tga.h"
#include "../tools/stream.h"
#include "../tools/malloc.h"
#include "../tools/mem32.h"
#include "../tools/memory.h"

typedef struct
{
   unsigned char  identsize;    // size of ID field that follows 18 byte header (0 usually)
   unsigned char  cmaptype;     // type of colour map 0=none, 1=has palette
   unsigned char  imagetype;    // type of image 0=none,1=indexed,2=rgb,3=grey,+8=rle packed

   short          cmapstart;    // first colour map entry in palette
   short          cmaplength;   // number of colours in palette
   unsigned char  cmapformat;   // number of bits per palette entry 15,16,24,32

   short          originx;      // image x origin
   short          originy;      // image y origin

   unsigned short width;
   unsigned short height;
   unsigned char  bpp;
   unsigned char  bpc;
} TGAHeader;

void tgaHeaderRead(Stream *stream, TGAHeader *header)
{
   // read header
   header->identsize= streamReadByte(stream);    // number of ident bytes after header, usually 0
   header->cmaptype= streamReadByte(stream);     // type of colour map 0=none, 1=has palette
   header->imagetype= streamReadByte(stream);    // type of image 0=none,1=indexed,2=rgb,3=grey,+8=rle packed

   header->cmapstart= streamReadWord(stream);    // first colour map entry in palette
   header->cmaplength= streamReadWord(stream);   // number of colours in palette
   header->cmapformat= streamReadByte(stream);   // number of bits per palette entry 15,16,24,32

   header->originx= streamReadWord(stream);      // image x origin
   header->originy= streamReadWord(stream);      // image y origin

   header->width= streamReadWord(stream);
   header->height= streamReadWord(stream);
   header->bpp= streamReadByte(stream);
   header->bpc= streamReadByte(stream);

   streamSkip(stream, header->identsize);
}

// TODO: this is identical to gif palette
void loadPal24(Stream *stream, unsigned int *dst, int size)
{
   unsigned char temp[1024];
   streamRead(stream, temp, size*3);

   if (dst)
   {
      unsigned char* src= temp;
      unsigned int r= 0;
      unsigned int g= 0;
      unsigned int b= 0;
      do
      {
         r= *src++;
         g= *src++;
         b= *src++;
         *dst++= (255<<24)+(b<<16)+(g<<8)+(r);
      } while (--size);
   }
}


void loadScanline8(Stream *stream, unsigned int *dst, int x, unsigned int *pal)
{
   int i;
   for (i=0;i<x;i++)
   {
      unsigned char index= streamReadByte(stream);
      *dst++= pal[index];
   }
}


void loadScanline16(Stream *stream, unsigned int *dst, int x, unsigned int *pal)
{
   int i;
   for (i=0;i<x;i++)
   {
      unsigned short rgb= streamReadWord(stream);

      unsigned char a= 255;
      unsigned char r= (rgb & 31)<<3;
      unsigned char g= (rgb >> 5 & 31)<<3;
      unsigned char b= (rgb >> 10 & 31)<<3;

      *dst++= (a<<24) + (b<<16) + (g<<8) + (r);
   }
}


void loadScanline24(Stream *stream, unsigned int *dst, int x, unsigned int *pal)
{
   int i;
   for (i=0;i<x;i++)
   {
      unsigned char a= 255;
      unsigned char r= streamReadByte(stream);
      unsigned char g= streamReadByte(stream);
      unsigned char b= streamReadByte(stream);

      *dst++= (a<<24) + (b<<16) + (g<<8) + (r);
   }
}

void loadScanline32(Stream *stream, unsigned int *dst, int x, unsigned int *pal)
{
   int i;
   for (i=0;i<x;i++)
   {
      unsigned char r= streamReadByte(stream);
      unsigned char g= streamReadByte(stream);
      unsigned char b= streamReadByte(stream);
      unsigned char a= streamReadByte(stream);

      *dst++= (a<<24) + (b<<16) + (g<<8) + (r);
   }
}


int loadtga(const char *fname, unsigned int **buf, int *sizex, int *sizey)
{
   TGAHeader      info;
   int            i,j;
   unsigned int   pal[256];
   unsigned char* data;

   Stream stream;

   if (!streamInit(&stream, fname))
   {
      *sizex= 0;
      *sizey= 0;
      *buf= NULL;
      return 0;
   }

   tgaHeaderRead(&stream, &info);

   // post some debug infos
   //printf("load tga: %s (%dx%dx%d) pal:%d\n", name, info.width, info.height, info.bpp, info.cmaplength);


   data= (unsigned char*)malloc((int)info.width*(int)info.height*4);

   // get palette data
   if (info.imagetype==1) // indexed colors
   {
      // load palette
      if (info.cmaplength<=256)
      switch (info.cmapformat)
      {
         case 24: loadPal24(&stream, pal, info.cmaplength); break;
         default: break;
      }
   }
/*
   else
   if (info.imagetype==2) // rgb data
   {
      // there is no palette
   }
*/
   else
   if (info.imagetype==3) // grey-scale
   {
      // create grey palette, so we can handle greyscale just as 8bit data
      for (i=0;i<256;i++) pal[i]= (255<<24)+(i<<16)+(i<<8)+(i);
   }


   // load scanlines
   for (j=0;j<info.height;j++)
   {
      // tga is bottom up
      unsigned int *dst= (unsigned int *)data + (info.height-1-j) * info.width;

      switch(info.bpp)
      {
         case 8:  loadScanline8(&stream, dst, info.width, pal); break;
         case 16: loadScanline16(&stream, dst, info.width, NULL); break;
         case 24: loadScanline24(&stream, dst, info.width, NULL); break;
         case 32: loadScanline32(&stream, dst, info.width, NULL); break;
         default: break;
      }
   }

   // finish up
   *buf= (unsigned int*)data;
   if (sizex)
      *sizex= info.width;
   if (sizey)
      *sizey= info.height;

   streamRelease(&stream);

   return 32;
}

void tgaLoadPalette(Stream *stream, unsigned int *pal, int format, int size)
{
   switch (format)
   {
      case 24: 
         loadPal24(stream, pal, size); 
         break;
      default: 
         break;
   }
}

int tgaLoad8(const char *filename, void **buffer, int *width, int *height, unsigned int *pal)
{
   TGAHeader      info;
   int            y;
   int            rle;
   Stream         stream;
   unsigned char* data;

   //return 1;

	//printf(" tga load: %s\n", filename);
	
   if (!streamInit(&stream, filename))
   {
      // create default bitmap (256x256 cleared with white)
      if (height) *height= 1;
      if (width) *width= 1;
      if (buffer)
      {
         data= (unsigned char*)malloc(1);
         data[0]= 1;
         *buffer= data;
      }
      return 0;
   }
      
   tgaHeaderRead(&stream, &info);

   rle= info.imagetype >> 3 & 1;
   info.imagetype &= 7;

   // post some debug infos
   //printf("load tga: %s (%dx%dx%d) pal:%d\n", filename, info.width, info.height, info.bpp, info.cmaplength);

   if (info.imagetype!=1 && info.imagetype!=3) // indexed colors
      return 0;

   if (info.cmaplength>256)
      return 0;

   // load palette
   if (info.imagetype==1)
   {
      tgaLoadPalette(&stream, pal, info.cmapformat, info.cmaplength);
   }
   else if (info.imagetype==3) // grey-scale
   {
      // create grey palette, so we can handle greyscale just as 8bit data
      if (pal)
      {
         unsigned int color= 0xff000000;
         unsigned int size= 256;
         do {
            *pal++= color;
            color+= 0x010101;
         } while (--size);
      }
   }

   // buffer=0: es wird nur die palette geladen
   if (buffer)
   {
      unsigned char *dst;
      int pitch;

      data= (unsigned char*)malloc((int)info.width*(int)info.height);

      if (info.bpc & 0x20)  // top -> down
      {
         dst= data;
         pitch= info.width;
      }
      else
      {
         dst= data + (info.height-1) * info.width;
         pitch= -info.width;
      }

      if (rle)
      {
         int scan= 0;
         int count= 0;
         int col= 0;
         int len;
         unsigned char* scanline= dst;

         y= info.height;
         scan= info.width;
         while (y)
         {
            if (count==0)
            {
               count= streamReadByte(&stream) + 1;
               if (count>128)
               {
                  // repeat single pixel color
                  count-=128;
                  col= streamReadByte(&stream);
               }
               else
               {
                  col= -1;
               }
            }

            len= count;
            if (len > scan) len= scan;

            if (col>=0)
               memset32(dst, col, len);
            else
               streamRead(&stream, dst, len);

            dst+=len;
            count-=len;
            scan-=len;

            // next scanline?
            if (scan<=0)
            {
               scan= info.width;
               scanline += pitch;
               dst= scanline;
               y--;
            }
         }
      }
      else
      {
         // load scanlines
         for (y=info.height; y>0; y--)
         {
            // read uncompressed pixels
//            for (i=0; i<info.width; i++) dst[i]= streamReadByte(&stream);
            streamRead(&stream, dst, info.width);
            dst+=pitch;
         }
      }

      // finish up
      *buffer= data;
   }
   if (width) *width= info.width;
   if (height) *height= info.height;

   streamRelease(&stream);
   return 1;
}


int tgaLoad18(const char *filename, void **buffer, int *width, int *height)
{
   TGAHeader      info;
   int            i,j;
   Stream         stream;
   unsigned char *data;

   //return 1;

   //printf(" tga load: %s\n", filename);

   if (!streamInit(&stream, filename))
   {
      if (height) *height= 1;
      if (width) *width= 1;
      if (buffer)
      {
         unsigned int* data= (unsigned int*)malloc(4);
         data[0]= 1;
         *buffer= data;
      }
      return 0;
   }

   tgaHeaderRead(&stream, &info);

   // post some debug infos
   //printf("load tga: %s (%dx%dx%d) pal:%d\n", filename, info.width, info.height, info.bpp, info.cmaplength);

   if (info.imagetype!=2) // rgb colors
      return 0;

   data= (unsigned char*)malloc((int)info.width*(int)info.height*4);

   // load scanlines
   for (j=0;j<info.height;j++)
   {
      // tga is bottom up
      unsigned int *dst= (unsigned int*)data + (info.height-1-j) * info.width;

      for (i=0;i<info.width;i++)
      {
         unsigned char r,g,b;
         if (info.bpp==32) streamReadByte(&stream);
         r= streamReadByte(&stream) >> 2;
         g= streamReadByte(&stream) >> 2;
         b= streamReadByte(&stream) >> 2;
         dst[i]= (r<<24)|(b<<16)|(g<<8)|(r);
      }
   }

   // finish up
   *buffer= data;
   if (width)
      *width= info.width;
   if (height)
      *height= info.height;

   streamRelease(&stream);

   return 1;
}


int tgaLoad32(const char *filename, void **buffer, int *width, int *height)
{
   TGAHeader      info;
   int            i,j;
   Stream         stream;
   unsigned char *data;

   //return 1;

   //printf(" tga load: %s\n", filename);

   if (!streamInit(&stream, filename))
   {
      if (height) *height= 1;
      if (width) *width= 1;
      if (buffer)
      {
         unsigned int* data= (unsigned int*)malloc(4);
         data[0]= 1;
         *buffer= data;
      }
      return 0;
   }

   tgaHeaderRead(&stream, &info);

   // post some debug infos
   //printf("load tga: %s (%dx%dx%d) pal:%d\n", filename, info.width, info.height, info.bpp, info.cmaplength);

   if (info.imagetype!=2) // rgb colors
      return 0;

   data= (unsigned char*)malloc((int)info.width*(int)info.height*4);

   // load scanlines
   for (j=0;j<info.height;j++)
   {
      // tga is bottom up
      unsigned int *dst= (unsigned int*)data + (info.height-1-j) * info.width;

      for (i=0;i<info.width;i++)
      {
         unsigned char a,r,g,b;
         r= streamReadByte(&stream);
         g= streamReadByte(&stream);
         b= streamReadByte(&stream);
         if (info.bpp==32)
            a= streamReadByte(&stream);
         else
            a= 0;
         dst[i]= (a<<24)|(b<<16)|(g<<8)|(r);
      }
   }

   // finish up
   *buffer= data;
   if (width)
      *width= info.width;
   if (height)
      *height= info.height;

   streamRelease(&stream);

   return 1;
}

int tgaLoad30(const char *filename, void **buffer, int *width, int *height)
{
   TGAHeader      info;
   int            i,j;
   Stream         stream;
   unsigned char *data;

   //return 1;

   //printf(" tga load: %s\n", filename);

   if (!streamInit(&stream, filename))
   {
      if (height) *height= 1;
      if (width) *width= 1;
      if (buffer)
      {
         unsigned int* data= (unsigned int*)malloc(4);
         data[0]= 1;
         *buffer= data;
      }
      return 0;
   }

   tgaHeaderRead(&stream, &info);

   // post some debug infos
   //printf("load tga: %s (%dx%dx%d) pal:%d\n", filename, info.width, info.height, info.bpp, info.cmaplength);

   if (info.imagetype!=2) // rgb colors
      return 0;

   data= (unsigned char*)malloc((int)info.width*(int)info.height*4);

   // load scanlines
   for (j=0;j<info.height;j++)
   {
      // tga is bottom up
      unsigned int *dst= (unsigned int*)data + (info.height-1-j) * info.width;

      for (i=0;i<info.width;i++)
      {
         unsigned char r,g,b;
         r= streamReadByte(&stream);
         g= streamReadByte(&stream);
         b= streamReadByte(&stream);
         if (info.bpp==32)
            streamReadByte(&stream);
         dst[i]= (b<<20)|(g<<10)|(r);
      }
   }

   // finish up
   *buffer= data;
   if (width)
      *width= info.width;
   if (height)
      *height= info.height;

   streamRelease(&stream);

   return 1;
}

int tgaSave8(const char *fname, unsigned char *data, int width, int height, unsigned int* pal)
{
   FILE* f;
   int x,y;
   TGAHeader info;
   info.identsize= 0;
   info.cmaptype= 1;
   info.imagetype= 1; // indexed + no rle
   info.cmapstart= 0;
   info.cmaplength= 256;
   info.cmapformat= 24;
   info.originx= 0;
   info.originy= 0;
   info.width= width;
   info.height= height;
   info.bpp= 8;
   info.bpc= 0;

   f= fopen(fname, "wb");
   if (!f)
      return 0;

   fwrite(&info.identsize,1,1,f);
   fwrite(&info.cmaptype,1,1,f);
   fwrite(&info.imagetype,1,1,f);
   fwrite(&info.cmapstart,1,2,f);
   fwrite(&info.cmaplength,1,2,f);
   fwrite(&info.cmapformat,1,1,f);
   fwrite(&info.originx,1,2,f);
   fwrite(&info.originy,1,2,f);
   fwrite(&info.width,1,2,f);
   fwrite(&info.height,1,2,f);
   fwrite(&info.bpp,1,1,f);
   fwrite(&info.bpc,1,1,f);

   // write palette
   for (y=0; y<info.cmaplength; y++)
   {
      unsigned char r= pal[y] >> 16 & 255;
      unsigned char g= pal[y] >> 8 & 255;
      unsigned char b= pal[y] & 255;
      fwrite(&b,1,1,f);
      fwrite(&g,1,1,f);
      fwrite(&r,1,1,f);
   }

   // write data
   for (y=0; y<height; y++)
   {
      unsigned char *src= data + (height-1-y) * info.width;
      for (x=0; x<info.width; x++)
      {
         unsigned char c= src[x];

         fwrite(&c,1,1,f);
      }
   }

   fclose(f);

   return 8;
}

