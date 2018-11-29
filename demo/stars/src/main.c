#include "wos/wos.h"
#include "starseffect.h"

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
   
   starsInit();
}

void updateDemo(int time)
{
}

void drawDemo(int time)
{
   starsRender(time);
   wosDisplay(2);
}

void mainDemo()
{
   int time= 0;

   wosSetMode(8, screenBuffer, starsPalette(), 256);

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
   starsRelease();
   free(tempBuffer);
}


int main()
{   
   initDemo();
   wosInit();

   deinitDemo();

   if (g_vbitimer > 0)
   {
      printf("  rendered %d frames in %d ticks (%d fps)\n\n", g_renderedFrames,g_vbitimer,50*g_renderedFrames/g_vbitimer);
   }

   return 0;
}

