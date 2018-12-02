#include "wos/wos.h"
#include "pictureeffect.h"

#include "image/gif.h"
#include "image/image.h"
#include "tools/mem32.h"
#include "tools/rand.h"
#include "math/imath.h"
#include "tools/malloc.h"

#include <stdio.h>
#include <math.h>

unsigned char* picture1= 0;
unsigned int picture1pal[256];

unsigned char* picture2= 0;
unsigned int picture2pal[256];

unsigned char* picture3= 0;
unsigned int picture3pal[256];

unsigned char* picture4= 0;
unsigned int picture4pal[256];

unsigned char* picture5= 0;
unsigned int picture5pal[256];

unsigned char* picture6=0;
unsigned int picture6pal[256];

unsigned char* picture7=0;
unsigned int picture7pal[256];

unsigned char* picture8=0;
unsigned int picture8pal[256];

unsigned char* picture9=0;
unsigned int picture9pal[256];

unsigned char* picture10=0;
unsigned int picture10pal[256];


extern unsigned int* g_currentPal;

// this is called when the effect wasn't "on" in the previous frame
void pictureEffectOn(int id)
{
    xres=320;
    yres=180;
    
    switch (id)
    {
    case 1: 
       wosSetMode(8, screenBuffer, &picture1pal, 0);  // 1
       g_currentPal = picture1pal;
       break;
    case 2: 
       wosSetMode(8, screenBuffer, &picture2pal, 0);  // 2
       g_currentPal = picture2pal;
       break;
    case 3: 
       wosSetMode(8, screenBuffer, &picture3pal, 0);  // 3
       g_currentPal = picture3pal;
       break;
    case 4: 
       wosSetMode(8, screenBuffer, &picture4pal, 0);  // 4
       g_currentPal = picture4pal;
       break;
    case 5: 
       wosSetMode(8, screenBuffer, &picture5pal, 0);  // 5
       g_currentPal = picture5pal;
       break;
    case 6: 
       wosSetMode(8, screenBuffer, &picture6pal, 0);  // 6
       g_currentPal = picture6pal;

    case 7: 
       wosSetMode(8, screenBuffer, &picture7pal, 0);  // 7
       g_currentPal = picture7pal;
    case 8: 
       wosSetMode(8, screenBuffer, &picture8pal, 0);  // 8
       g_currentPal = picture8pal;       break;
    case 9: 
       wosSetMode(8, screenBuffer, &picture9pal, 0);  // 9
       g_currentPal = picture9pal;       break;
    case 10: 
       wosSetMode(8, screenBuffer, &picture10pal, 0);  // 10
       
       g_currentPal = picture10pal;       break;

    default: break;
    };   
}

// this is called per frame (50hz)
void pictureEffectUpdate(int id)
{
}

void pictureEffectInit()
{
   int w,h;

   gifLoad("data/pictures/01.gif", (void**)&picture1, &w,&h, (unsigned int*)&picture1pal);
   gifLoad("data/pictures/02.gif", (void**)&picture2, &w,&h, (unsigned int*)&picture2pal);
   gifLoad("data/pictures/03.gif", (void**)&picture3, &w,&h, (unsigned int*)&picture3pal);
   gifLoad("data/pictures/04.gif", (void**)&picture4, &w,&h, (unsigned int*)&picture4pal);
   gifLoad("data/pictures/05.gif", (void**)&picture5, &w,&h, (unsigned int*)&picture5pal);
   gifLoad("data/pictures/06.gif", (void**)&picture6, &w,&h, (unsigned int*)&picture6pal);
   gifLoad("data/pictures/07.gif", (void**)&picture7, &w,&h, (unsigned int*)&picture7pal);
   gifLoad("data/pictures/08.gif", (void**)&picture8, &w,&h, (unsigned int*)&picture8pal);
   gifLoad("data/pictures/09.gif", (void**)&picture9, &w,&h, (unsigned int*)&picture9pal);
   gifLoad("data/pictures/helge-haujobb.gif", (void**)&picture10, &w,&h, (unsigned int*)&picture10pal);
 
   g_currentPal = picture1pal;
}


void pictureEffectRelease()
{
   free(picture1);
   free(picture2);
   free(picture3);
   free(picture4);
   free(picture5);
   free(picture6);
   free(picture7);
   free(picture8);
   free(picture9);
   free(picture10);
}


void pictureEffectRender(int id)
{     
   switch (id)
   {
   case 1: 
      memcpy(screenBuffer, picture1, 320*180);
      g_currentPal = picture1pal;
      break;
   case 2: 
      memcpy(screenBuffer, picture2, 320*180);
      g_currentPal = picture2pal;
      break;
   case 3: 
      memcpy(screenBuffer, picture3, 320*180);
      g_currentPal = picture3pal;
      break;
   case 4: 
      memcpy(screenBuffer, picture4, 320*180);
      g_currentPal = picture4pal;
      break;
   case 5: 
      memcpy(screenBuffer, picture5, 320*180);
      g_currentPal = picture5pal;
      break;
   case 6: 
      memcpy(screenBuffer, picture6, 320*180);
      g_currentPal = picture6pal;
      break;
   case 7: 
      memcpy(screenBuffer, picture7, 320*180);
      g_currentPal = picture7pal;
      break; 
   case 8: 
      memcpy(screenBuffer, picture8, 320*180);
      g_currentPal = picture8pal;
      break; 
   case 9: 
      memcpy(screenBuffer, picture9, 320*180);
      g_currentPal = picture9pal;
      break; 
   case 10: 
      memcpy(screenBuffer, picture10, 320*180);
      g_currentPal = picture10pal;
      break; 
   default: 
      memcpy(screenBuffer, picture1, 320*180);
      g_currentPal = picture1pal;
      break;
   };  
}

