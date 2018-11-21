#include "stars.h"

#define PERSFAK 8192
#define ZMAX STARFIELDDEPTH

static Vertex stars[NUMSTARS];

void starsInit()
{
    int i,z;

    for (i=0; i<NUMSTARS; i++)
    {
        stars[i].x = generateRandom(-STARFIELDSIZE,STARFIELDSIZE);
        stars[i].y = generateRandom(-STARFIELDSIZE,STARFIELDSIZE);
        stars[i].z = generateRandom(1, STARFIELDDEPTH-1);
    }
    i=101;
}

void starsDraw(int time, unsigned char* screenBuffer, int xres, int yres)
{

    int i,sx,sy;
    const int cx = xres<<3; // center with 4bit subpixel precision
    const int cy = yres<<3;
    const int maxx= (xres-2) << 4;
    const int maxy= (yres-2) << 4;
    int x,y,col;

    float fpersfak;
    int wz;

    for (i=0; i<NUMSTARS; i++)
    {
        wz = (stars[i].z - time) & (STARFIELDDEPTH-1);
        if( (wz>0) ) // && (wz<ZMAX))
        {
           fpersfak= (float)(PERSFAK>>8) / wz;
            x= cx + stars[i].x * fpersfak;
            y= cy + stars[i].y * fpersfak;

            //visible
            if ( (y>=0) && (y<maxy) && (x>=0) && (x<maxx))
            {
               unsigned char* dst;
               int sx,sy;

               col = 64 - wz * 64 / ZMAX; // TODO: ZMAX is pow2, this can be a shift
               sx= (x & 15)*col>>4; // sx is premultiplied with color (save 4x *col in the equations below)
               sy= y & 15;

               x>>=4;
               y>>=4;
               dst= screenBuffer + (y*xres) + x;

               dst[0] += (col-sx)*(15-sy)>>4; // >>4 kuerzt die 4bit von sy wieder raus
               dst[1] += (sx)*(15-sy)>>4;
               dst+= xres;

               dst[0] += (col-sx)*(sy)>>4;
               dst[1] += (sx)*(sy)>>4;
            }
        }
    }

}

void starsDeinit()
{

}

