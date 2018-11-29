// stars example, 21.11.18
// adopted for hellodemo with rocket controls, 28.11.18

#include "starseffect.h"

#include "wos/wos.h"
#include "tools/mem32.h"
#include "tools/rand.h"
#include "common/vertex.h"

#define NUMSTARS 7000
#define STARFIELDSIZE 2048
#define STARFIELDDEPTH 512
#define ZMAX STARFIELDDEPTH

static Vertex stars[NUMSTARS];
static unsigned int pal[256];

// rocket additions
extern unsigned int* g_currentPal;
extern unsigned char* screenBuffer;
int starsEffect_startTime;

void setPal(int index, int r, int g, int b)
{
   if (r>255) r=255;
   if (g>255) g=255;
   if (b>255) b=255;

   if (r<0) r=0;
   if (g<0) g=0;
   if (b<0) b=0;
      
   pal[index]= (r<<16)|(g<<8)|(b<<0);
}

unsigned int* starsPalette()
{
   return pal;
}

void starsEffectRelease()
{
}

void starsEffectOn(int startTime)
{
   starsEffect_startTime=startTime;
   xres=320;
   yres=180;

   wosSetMode(8, screenBuffer, starsPalette(), 0);
   g_currentPal = starsPalette();

}
void starsEffectInit()
{
   int i,z;

   // create star-coordinates
   for (i=0; i<NUMSTARS; i++)
   {
       z = 0;
       while (z==0)
       {
           z = generateRandom(1, STARFIELDDEPTH+1);
       }
       stars[i].x = generateRandom(-STARFIELDSIZE/2,STARFIELDSIZE/2);
       stars[i].y = generateRandom(-STARFIELDSIZE/2,STARFIELDSIZE/2);
       stars[i].z = z;
   }

   // setup palette
   for (i=0;i<64;i++)
   {
      setPal(i,    0+i*4, 0+i*5,  0+i*7); 
      setPal(i+64, 255, 255,  255);
      setPal(i+128, 255, 255,  255);
      setPal(i+192, 255, 255,  255);
   }
   
}

// draw all stars to screenbuffer, movement based on time
void starsDraw(int time, float persfak, unsigned char* screenBuffer, int xres, int yres)
{

    int i,x,y,col;
    
    float fpersfak,wx,wy,wz;
   
    for (i=0; i<NUMSTARS; i++)
    {
        wz = (stars[i].z - time) & STARFIELDDEPTH-1;
        wx = stars[i].x;
        wy = stars[i].y;
        fpersfak=( 1 / wz*persfak );
        x=xres/2+wx*fpersfak;
        y=yres/2+wy*fpersfak;
        if( (wz>0) & (wz<ZMAX)){
            //visible
            if ( (y>=0) & (y<yres) & (x>=0) & (x<xres))
            {
                col = 64-wz*64/ZMAX;
                screenBuffer[y*xres+x] += col;
            }
        }
    }

}

// render method called from main.c
void starsEffectRender(int time, float persfak)
{ 
   // clear screen
   memset32(screenBuffer, 0, xres*yres);
   
   starsDraw(time, persfak, screenBuffer,xres,yres);
}

