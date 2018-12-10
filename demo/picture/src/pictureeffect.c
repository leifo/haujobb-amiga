#include "wos/wos.h"

#include "pictureeffect.h"
#include "image/gif.h"

unsigned char* picture= 0;
unsigned int picturepal[256];

extern unsigned int* g_currentPal;
extern unsigned char* screenBuffer;

void pictureEffectInit()
{
   int w,h;

   gifLoad("data/helge-haujobb.gif", (void**)&picture, &w,&h, (unsigned int*)&picturepal);
   g_currentPal = picturepal;
}

void pictureEffectRelease()
{
   free(picture);
}

void pictureEffectRender(int id)
{     
   memcpy(screenBuffer, picture, 320*180);
   g_currentPal = picturepal;
}

