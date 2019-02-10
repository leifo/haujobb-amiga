#include "wos/wos.h"
#include "screenmodeeffect.h"
#include "tools/rand.h"

#include <stdio.h>
#include <stdlib.h>

unsigned int* g_currentPal;
unsigned char* tempBuffer;
unsigned char* screenBuffer;
int            xres,yres;

void initDemo()
{
   // global variables  
   xres= 320;
   yres= 180;
   
   // get buffer with safety margin before and after
   tempBuffer= (unsigned char*)malloc(xres*yres*3*4);
   screenBuffer= tempBuffer + xres*yres;
   
   screenmodeEffectInit();
}

void updateDemo(int time)
{
}

/*
 * MODE | Amiga |  PC  | Dimensions, Notes
 * -----------------------------------------
 *   1  |   Y   |   N   | 320x200x8 (PC: horizontal stripes)
 *   2  |   Y   |   N   | 320x100x8 (PC: horizontal stripes)
 *   3  |   Y   |   N   | 160x100x8 (PC: horizontal stripes)
 *   4  |   N   |   N   | 640x200x8, looks scrambled (PC: horizontal stripes)
 *   5  |   N   |   N   | 640x200x8, looks random (PC: horizontal stripes)
 *   6  |   Y   |   N   | 160x100x18 (PC: black)
 *   7  |   Y   |   N   | 320x200x6, (Amiga: few pixel errors, stemming from GIF?) (PC: horizontal stripes)
 *   8  |   Y   |   Y   | 320x180x8
 *   9  |   Y   |   Y   | 320x90x8
 *  10  |   Y   |   N   | 160x90x8 (Y/2 on PC)
 *  11  |   Y   |   Y   | 160x90x18
 *  12  |   Y   |   N   | 640x180x8 (just horizontal stripes on PC)
 *  13  |   Y   |   N   | 640x360x8 (just vertical striped on PC)
 *  14  |   Y   |   Y   | 320x180x6 w. saturation
 *  15  |   N   |   N   | 320x180x5 (upper bits), wrong colours (due to GIF?)
 *  16  |   Y   |   Y   | 320x180x8 w. copper colours (small black spots on Amiga due to non-init)
 *  17  |   Y   |  red  | 220x180x15 from 24-bit
 *  18  |   Y   |  red  | 220x180x15 from 18-bit
 *  19  |   Y   |  red  | 220x90x15 from 18-bit
 *  20  |   Y   |  red  | 220x180x18 from 24-bit
 *  21  |   Y   |   Y   | 220x180x18 from 18-bit
 *  22  |   Y   |   Y   | 220x90x18 from 18-bit
 *  23  |   Y   |  red  | 220x180x12 from 18-bit
 *  24  |   N   |   N   | 320x180x5 OCS, wrong colours (due to GIF?)
 *  25  |   N   |   Y?  | 320x180x5 OCS w. copper colours, wrong colours (due to GIF?, black spots on Amiga due to non-init)
 * 
 * */

// working perfectly on Amiga and PC: 8, 9, 11, 14, 16, 21, 22
// 7 out of 25

int oldpart= -1;
int pic= 8;

void drawDemo(int time)
{
   int newpart = (time/25);

   if (newpart != oldpart)
   {
      // pick random image
      pic= (irand() % 17) + 8;
      oldpart= newpart;
   }
   
   // todo: change here (range 8..25)
   screenmodeEffectRender(pic);   // 17-20 similar modes, 21 & 22 working
   
   wosSetCols(g_currentPal,256);
   wosDisplay(2);
}

void mainDemo()
{
   int time= 0;

   //wosSetMode(8, screenBuffer, g_currentPal, 256);
#ifndef WIN32
   while (wosCheckExit()==0)
   {
      time= g_vbitimer;

      drawDemo(time);
   }
#endif
}


void deinitDemo()
{
   screenmodeEffectRelease();
   free(tempBuffer);
}


int main()
{   
   initDemo();
   wosInit();

   deinitDemo();
   return 0;
}

