// stars example, 21.11.18
// optimised for clarity, not speed or beauty

#include "starseffect.h"

#include "wos/wos.h"
#include "tools/mem32.h"
#include "tools/rand.h"
#include "common/vertex.h"

#define NUMSTARS 3000
#define STARFIELDSIZE 1024
#define STARFIELDDEPTH 512
#define PERSFAK 8192
#define ZMAX STARFIELDDEPTH
static Vertex stars[NUMSTARS];
static unsigned int pal[256];

void setPal(int index, int r, int g, int b)
{
   if (r>255) r=255;
   if (g>255) g=255;
   if (b>255) b=255;

   pal[index]= (r<<16)|(g<<8)|(b<<0);
}

unsigned int* starsPalette()
{
   return pal;
}

void starsRelease()
{
}


void starsInit()
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
void starsDraw(int time, unsigned char* screenBuffer, int xres, int yres)
{

    int i,sx,sy;
    int cx = xres/2;
    int cy = yres/2;
    int x,y,col;
    int iz;
    unsigned int zx;
    unsigned int zy;

    float fpersfak,wx,wy,wz;

    for (i=0; i<NUMSTARS; i++)
    {
        wz = (stars[i].z - time) & STARFIELDDEPTH-1;
        wx = stars[i].x;
        wy = stars[i].y;
        fpersfak=( 1 / wz*(PERSFAK/256) );
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
void starsRender(int time)
{ 
   // clear screen
   memset32(screenBuffer, 0, xres*yres);
   
   starsDraw(time,screenBuffer,xres,yres);
}

