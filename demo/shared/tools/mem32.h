#ifndef MEM32_H
#define MEM32_H

#include "math/imath.h"

#if defined(WIN32) || defined(__APPLE__)
#include <memory.h>
#endif

// to accelerate memcpy
#ifdef AMIGA
#include <clib/exec_protos.h>
#include <inline/exec_protos.h>
extern void* SysBase;
#endif

//void memset(void* dst, unsigned char fill, unsigned int length);
//void memcpy(void* dst, const void* src, unsigned int length);

static _INLINE_ void memcpy32(void* dst, void* src, int length)
{
#ifdef AMIGA
    // #1 Winner!
    CopyMem(src, dst, length);

    // #0 Noch schneller, aber restriktiv mit Alignments -> Bild defekt
    //CopyMemQuick(src, dst, length);

    // #3 deutlich schneller als Standard memcpy
    //copy_linear(src,dst,length);

    // #4 Standard memcopy
    //memcpy(dst, src, length);

    // #5 generischer Byte-Loop
    /*unsigned char* src8= (unsigned char*)src;
    unsigned char* dst8= (unsigned char*)dst;
    //length>>=1;
    if (length<=0)
       return;
    do {
      *dst8++= *src8++;
    } while (--length);
    */
#else
    memcpy(dst, src, length);
#endif
}


static _INLINE_ void memset32(void* buffer, unsigned char val8, unsigned int length)
{
   unsigned char* dst8;
   unsigned short val16;

   ASMCOMMENT("memset32");

   if (length==0)
      return;

   // uneven address: store one byte to be 16bit aligned
   dst8= (unsigned char*)buffer;
   if ((unsigned int)dst8 & 1)
   {
      *dst8++= val8;
      length--;
   }

   // if we are not 32bit aligned and have two bytes to write: store 16bit
   val16= (val8<<8)|val8;
   if (length>1 && (unsigned int)dst8 & 2)
   {
      unsigned short* dst16= (unsigned short*)dst8;
      *dst16= val16;
      dst8+=2;
      length-=2;
   }

   // we are now 32bit aligned

   if (length>3)
   {
      unsigned int* dst32= (unsigned int*)dst8;
      unsigned int val32= (val16<<16)|(val16);
      int len16= length>>4;
      int len4;

      // if large areas are to be filled: unroll loop by 4
      if (len16)
      {
         do
         {
            *dst32++= val32;
            *dst32++= val32;
            *dst32++= val32;
            *dst32++= val32;
         } while (--len16);
         length &= 0xf;
      }

      // store the rest of 32bit value
      len4= length>>2;
      if (len4)
      {
         do
         {
            *dst32++= val32;
         } while (--len4);
         length&=3;
      }

      dst8= (unsigned char*)dst32;
   }

   // now there are 0-3 bytes left
   if (length>0)
   do {
      *dst8++= val8;
   } while (--length);
}


// dst must be 16byte aligned
static _INLINE_ void memsetAligned(unsigned int* dst32, unsigned int val32, unsigned int length)
{
   length>>=4;

   if (length==0)
      return;

   do
   {
      *dst32++= val32;
      *dst32++= val32;
      *dst32++= val32;
      *dst32++= val32;
   } while (--length);
}

#endif

