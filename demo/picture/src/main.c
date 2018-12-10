#include "wos/wos.h"
#include "pictureeffect.h"

#include <stdlib.h>
#include <math.h>

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

// not called from wickedquicklink
// use wickedlink and assembly-bridge if you want to have this called each frame
void updateDemo(int time)
{

}

void drawDemo(int time)
{
   wosSetCols(g_currentPal, 160+sin(time/50.0)*160);
   pictureEffectRender();
   wosDisplay(2);
}

void mainDemo()
{
   int time= 0;

   wosSetMode(8, screenBuffer, g_currentPal, 0);
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

