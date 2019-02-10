#include "wos/wos.h"
#include "screenmodeeffect.h"

#include "image/gif.h"
#include "image/tga.h"
#include "image/image.h"
#include "tools/mem32.h"
#include "tools/rand.h"
#include "math/imath.h"
#include "tools/malloc.h"

#include <stdio.h>
#include <math.h>

unsigned int dummypal[256];   

// old 320x200 style modes (16:9 on CRT TV)
unsigned char* mode1= 0;
unsigned int mode1pal[256];
unsigned char* mode2= 0;
unsigned int mode2pal[256];
unsigned char* mode3= 0;
unsigned int mode3pal[256];
unsigned char* mode4= 0;
unsigned int mode4pal[256];
unsigned char* mode5= 0;
unsigned int mode5pal[256];
unsigned char* mode6=0;
unsigned int mode6pal[256];
unsigned char* mode7=0;
unsigned int mode7pal[256];

// new 320x180 style (16:9 on flat screens & YouTube)
unsigned char* mode8=0; 
unsigned int mode8pal[256];
unsigned char* mode9=0;
unsigned int mode9pal[256];
unsigned char* mode10=0;
unsigned int mode10pal[256];
unsigned char* mode11=0;
unsigned char* mode12=0;
unsigned int mode12pal[256];
unsigned char* mode13=0;
unsigned int mode13pal[256];
unsigned char* mode14=0;
unsigned int mode14pal[256];
unsigned char* mode15=0;
unsigned int mode15pal[256];
unsigned char* mode16=0;
unsigned int mode16pal[256];
unsigned char* mode17=0;
unsigned char* mode18=0;
unsigned char* mode19=0;
unsigned char* mode20=0;
unsigned char* mode21=0;
unsigned char* mode22=0;
unsigned char* mode23=0;

// OCS
unsigned char* mode24=0;
unsigned int mode24pal[256];
unsigned char* mode25=0;
unsigned int mode25pal[256];

extern unsigned int* g_currentPal;

// this is called when the effect wasn't "on" in the previous frame
void screenmodeEffectOn(int id)
{
    xres=320; yres=180;
    
    switch (id)
    {
    case 1: 
       wosSetMode(1, screenBuffer, &mode1pal, 256);
       xres=320; yres=200;     
       g_currentPal = mode1pal;
       break;
    case 2: 
       wosSetMode(2, screenBuffer, &mode2pal, 256);
       xres=320; yres=100;     
       g_currentPal = mode2pal;
       break;
    case 3: 
       wosSetMode(3, screenBuffer, &mode3pal, 256);
       xres=160; yres=100;     
       g_currentPal = mode3pal;
       break;
    case 4: 
       wosSetMode(4, screenBuffer, &mode4pal, 256);
       xres=640; yres=200;     
       g_currentPal = mode4pal;
       break;
    case 5: 
       wosSetMode(5, screenBuffer, &mode5pal, 256);
       xres=640; yres=400;     
       g_currentPal = mode5pal;
       break;
    case 6: 
       wosSetMode(6, screenBuffer, &dummypal, 256);
       xres=160; yres=100;     
       g_currentPal = dummypal;
       break;
    case 7: 
       wosSetMode(7, screenBuffer, &mode7pal, 256);
       xres=320; yres=200;     
       g_currentPal = mode7pal;
       break;
    case 8: 
       wosSetMode(8, screenBuffer, &mode8pal, 256);
       xres=320; yres=180;     
       g_currentPal = mode8pal;
       break;
    case 9: 
       wosSetMode(9, screenBuffer, &mode9pal, 256);
       xres=320; yres=90;
       g_currentPal = mode9pal;
       break;
    case 10: 
       wosSetMode(10, screenBuffer, &mode10pal, 256); 
       xres=160; yres=90;
       g_currentPal = mode10pal;
       break;
    case 11: 
       wosSetMode(11, screenBuffer, &dummypal, 256);
       xres=160; yres=90;
       g_currentPal = dummypal;
       break;
    case 12: 
       wosSetMode(12, screenBuffer, &mode13pal, 256);
       xres=640; yres=180;
       g_currentPal = mode12pal;
       break;
    case 13: 
       wosSetMode(13, screenBuffer, &mode13pal, 256);
       xres=640; yres=360;
       g_currentPal = mode13pal; 
       break;
    case 14: 
       wosSetMode(14, screenBuffer, &mode14pal, 256);
       xres=320; yres=180;
       g_currentPal = mode14pal; 
       break;
    case 15: 
       wosSetMode(15, screenBuffer, &mode15pal, 256);
       xres=320; yres=180;
       g_currentPal = mode15pal;       
       break;
    case 16: 
       wosSetMode(16, screenBuffer, &mode16pal, 256);
       xres=320; yres=180;
       g_currentPal = mode16pal;       
       break;
    case 17: 
       wosSetMode(17, screenBuffer, &dummypal, 256);
       xres=220; yres=180;     
       g_currentPal = dummypal;       
       break;
    case 18: 
       wosSetMode(18, screenBuffer, &dummypal, 256);
       xres=220; yres=180;     
       g_currentPal = dummypal;
       break;
    case 19: 
       wosSetMode(19, screenBuffer, &dummypal, 256);
       xres=220; yres=90;     
       g_currentPal = dummypal;
       break;
    case 20: 
       wosSetMode(20, screenBuffer, &dummypal, 256);
       xres=220; yres=180;     
       g_currentPal = dummypal;
       break;
    case 21: 
       wosSetMode(21, screenBuffer, &dummypal, 256);
       xres=220; yres=180;     
       g_currentPal = dummypal;
       break;
    case 22: 
       wosSetMode(22, screenBuffer, &dummypal, 256);
       xres=220; yres=90;     
       g_currentPal = dummypal;
       break;
    case 23: 
       wosSetMode(23, screenBuffer, &dummypal, 256);
       xres=220; yres=180;     
       g_currentPal = dummypal;
       break;
    case 24: 
       wosSetMode(24, screenBuffer, &mode24pal, 256);
       xres=320; yres=180;     
       g_currentPal = mode24pal;
       break;
    case 25: 
       wosSetMode(25, screenBuffer, &mode25pal, 256);
       xres=320; yres=180;     
       g_currentPal = mode25pal;
       break;

    default: 
       wosSetMode(8, screenBuffer, &mode8pal, 256);
       xres=320; yres=180;     
       g_currentPal = mode8pal;
       break;
    };   
}

// this is called per frame (50hz)
void screenmodeEffectUpdate(int id)
{
}

void screenmodeEffectInit()
{
   int w,h;
   int i;

   gifLoad("data/mode01.gif", (void**)&mode1, &w,&h, (unsigned int*)&mode1pal);
   gifLoad("data/mode02.gif", (void**)&mode2, &w,&h, (unsigned int*)&mode2pal);
   gifLoad("data/mode03.gif", (void**)&mode3, &w,&h, (unsigned int*)&mode3pal);
   gifLoad("data/mode04.gif", (void**)&mode4, &w,&h, (unsigned int*)&mode4pal);
   gifLoad("data/mode05.gif", (void**)&mode5, &w,&h, (unsigned int*)&mode5pal);
   tgaLoad18("data/mode06.tga", (void**)&mode6, &w,&h);
   gifLoad("data/mode07.gif", (void**)&mode7, &w,&h, (unsigned int*)&mode7pal);

   
   gifLoad("data/mode08.gif", (void**)&mode8, &w,&h, (unsigned int*)&mode8pal);
   gifLoad("data/mode09.gif", (void**)&mode9, &w,&h, (unsigned int*)&mode9pal);
   gifLoad("data/mode10.gif", (void**)&mode10, &w,&h, (unsigned int*)&mode10pal);
   tgaLoad18("data/mode11.tga", (void**)&mode11, &w,&h);

   gifLoad("data/mode12.gif", (void**)&mode12, &w,&h, (unsigned int*)&mode12pal);
   gifLoad("data/mode13.gif", (void**)&mode13, &w,&h, (unsigned int*)&mode13pal);
   gifLoad("data/mode14.gif", (void**)&mode14, &w,&h, (unsigned int*)&mode14pal);
   gifLoad("data/mode15.gif", (void**)&mode15, &w,&h, (unsigned int*)&mode15pal);
   gifLoad("data/mode16.gif", (void**)&mode16, &w,&h, (unsigned int*)&mode16pal);
   tgaLoad32("data/mode17.tga", (void**)&mode17, &w,&h);
   tgaLoad18("data/mode18.tga", (void**)&mode18, &w,&h);
   tgaLoad18("data/mode19.tga", (void**)&mode19, &w,&h);
   tgaLoad32("data/mode20.tga", (void**)&mode20, &w,&h);
   tgaLoad18("data/mode21.tga", (void**)&mode21, &w,&h);
   tgaLoad18("data/mode22.tga", (void**)&mode22, &w,&h);
   tgaLoad18("data/mode23.tga", (void**)&mode23, &w,&h);

   gifLoad("data/mode24.gif", (void**)&mode24, &w,&h, (unsigned int*)&mode24pal);
   gifLoad("data/mode25.gif", (void**)&mode25, &w,&h, (unsigned int*)&mode25pal);

   // mode15 expects 32 colors in the upper 5 bits of each byte (lower 3 bits are additional precision for dithering etc)
   // these are copied to the lower 5 bitplanes, thus use color entries 0..31 of the palette.
   // fix the palette:
   for (i=0;i<32;i++) mode15pal[i]= mode15pal[i*8];

   g_currentPal = mode8pal;
}


void screenmodeEffectRelease()
{
   free(mode1);
   free(mode2);
   free(mode3);
   free(mode4);
   free(mode5);
   free(mode6);
   free(mode7);
   free(mode8);
   free(mode9);
   free(mode10);
   free(mode11);
   free(mode12);
   free(mode13);
   free(mode14);
   free(mode15);
   free(mode16);
   free(mode17);
   free(mode18);
   free(mode19);
   free(mode20);
   free(mode21);
   free(mode22);
   free(mode23);
   free(mode24);
   free(mode25);
}


void screenmodeEffectRender(int id)
{     
   screenmodeEffectOn(id);

   switch (id)
   {
   case 1: 
      memcpy(screenBuffer, mode1, 320*200);
      g_currentPal = mode1pal;
      break;
   case 2: 
      memcpy(screenBuffer, mode2, 320*100);
      g_currentPal = mode2pal;
      break;
   case 3: 
      memcpy(screenBuffer, mode3, 160*100);
      g_currentPal = mode3pal;
      break;
   case 4: 
      memcpy(screenBuffer, mode4, 640*200);
      g_currentPal = mode4pal;
      break;
   case 5: 
      memcpy(screenBuffer, mode5, 640*400);
      g_currentPal = mode5pal;
      break;
   case 6: 
      memcpy(screenBuffer, mode6, 160*100*4);
      g_currentPal = mode6pal;
      break;
   case 7: 
      memcpy(screenBuffer, mode7, 320*200);
      g_currentPal = mode7pal;
      break; 
   case 8: 
      memcpy(screenBuffer, mode8, 320*180);
      g_currentPal = mode8pal;
      break; 
   case 9: 
      memcpy(screenBuffer, mode9, 320*90);
      g_currentPal = mode9pal;
      break; 
   case 10: 
      memcpy(screenBuffer, mode10, 160*90);
      g_currentPal = mode10pal;
      break; 
   case 11: 
      memcpy(screenBuffer, mode11, 160*90*4);
      g_currentPal = dummypal;
      break; 
   case 12: 
      memcpy(screenBuffer, mode12, 640*180);
      g_currentPal = mode12pal;
      break; 
   case 13: 
      memcpy(screenBuffer, mode13, 640*360);
      g_currentPal = mode13pal;
      break; 
   case 14: 
      memcpy(screenBuffer, mode14, 320*180);
      g_currentPal = mode14pal;
      break; 
   case 15: 
      memcpy(screenBuffer, mode15, 320*180);
      g_currentPal = mode15pal;
      break; 
   case 16: 
      memcpy(screenBuffer, mode16, 320*180);
      g_currentPal = mode16pal;
      break; 
   case 17: 
      memcpy(screenBuffer, mode17, 220*180*4);
      g_currentPal = dummypal;
      break; 
   case 18: 
      memcpy(screenBuffer, mode18, 220*180*4);
      g_currentPal = dummypal;
      break; 
   case 19: 
      memcpy(screenBuffer, mode19, 220*90*4);
      g_currentPal = dummypal;
      break; 
   case 20: 
      memcpy(screenBuffer, mode20, 220*180*4);
      g_currentPal = dummypal;
      break; 
   case 21: 
      memcpy(screenBuffer, mode21, 220*180*4);
      g_currentPal = dummypal;
      break; 
   case 22: 
      memcpy(screenBuffer, mode22, 220*90*4);
      g_currentPal = dummypal;
      break; 
   case 23: 
      memcpy(screenBuffer, mode23, 220*180*4);
      g_currentPal = dummypal;
      break; 
   case 24: 
      memcpy(screenBuffer, mode24, 320*180);
      g_currentPal = mode24pal;
      break;       
   case 25: 
      memcpy(screenBuffer, mode25, 320*180);
      g_currentPal = mode25pal;
      break;       
      
   default: 
      memcpy(screenBuffer, mode8, 320*180);
      g_currentPal = mode10pal;
      break; 
   };  
   
   
}

