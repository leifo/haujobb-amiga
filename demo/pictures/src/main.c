#include "wos/wos.h"
#include "pictureeffect.h"

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
   tempBuffer= (unsigned char*)malloc(xres*yres*3);
   screenBuffer= tempBuffer + xres*yres;
   
   pictureEffectInit();
}

void updateDemo(int time)
{
}

void drawDemo(int time)
{
   int pic = 1+(time/50.0);
   pictureEffectRender(pic);
   wosSetCols(g_currentPal,256);
   wosDisplay(1);
}

void mainDemo()
{
   int time= 0;

   wosSetMode(8, screenBuffer, g_currentPal, 256);
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
   pictureEffectRelease();
   free(tempBuffer);
}


int main()
{   
   initDemo();
   wosInit();

   deinitDemo();
   return 0;
}

