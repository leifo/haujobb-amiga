// movetable example, 25.11.18

#include "movetableeffect.h"

#include "wos/wos.h"
#include "tools/mem32.h"

#include "image/gif.h"
#include "math/imath.h"
#include "math.h"

#define pi   3.14159265358979323846

// table size
#define tabx 640
#define taby 360

char *tab1, *tab2;  // pointer to tabels with x- / y-values
char *tab3, *tab4;  
char *tab5, *tab6;  


unsigned char* texture= 0;
unsigned int texturepal[256];
extern unsigned int* g_currentPal;

int movetableEffect_startTime;

unsigned int* movetablePalette()
{
   return texturepal;
}

void build_sphere(char *xbuf, char *ybuf)
{
  int   x,y, w,z, w1,z1, w2,z2, w3,z3, q,p,xp,yp;
  float xmid,ymid;
  float tx,ty,d;
  float fak1,fak2;

  #define CAMDIST 100000

  xmid=tabx / 2.0 - 0.5;
  ymid=taby / 2.0 - 0.5;

  fak1= 128.0 / pi;
  fak2= pi / 32.0;

  for (p=0,y=0;y<taby;y++)    // alle pixel durchlaufen
  {
    for (x=0;x<tabx;x++,p++)
    {
      tx = x - xmid;
      ty = y - ymid;
      d  = CAMDIST / (tx*tx + ty*ty + CAMDIST*1.2);

      z1 = tx * d;
      w1 = ty * d;

      xbuf[p]= w1;
      ybuf[p]= z1;
    }

  }
}


void build_tunnel(char *xbuf, char *ybuf)
{
  int   x,y, w,z, w1,z1, w2,z2, w3,z3, q,p,xp,yp;
  float xmid,ymid;
  float tx,ty,d;
  float fak1,fak2;

  xmid=tabx / 2.0 - 0.5;
  ymid=taby / 2.0 - 0.5;

  fak1= 128.0 / pi;
  fak2= pi / 32.0;

  for (p=0,y=0;y<taby;y++)    // alle pixel durchlaufen
  {
    for (x=0;x<tabx;x++,p++)
    {
      tx = x - xmid;
      ty = y - ymid;

      w1= 128.0 + atan2(ty,tx)*fak1;  // winkel von akt. pixel zum mittelpunkt
      z1= sqrt (tx*tx + ty*ty);       // entfernung vom mittelpunkt
      z1 = 8192/(z1+1);               // perspektivische umwandlung

      xbuf[p]= w1;
      ybuf[p]= z1;
    }

  }
}


void build_water(char *xbuf, char *ybuf)
{
  int   x,y, w,z, w1,z1, w2,z2, w3,z3, q,p,xp,yp;
  float xmid,ymid;
  float tx,ty,d;
  float fak1,fak2;

  #define CAMDIST 100000

  xmid=tabx / 2.0 - 0.5;
  ymid=taby / 2.0 - 0.5;

  fak1= 128.0 / pi;
  fak2= pi / 32.0;

  for (p=0,y=0;y<taby;y++)    // alle pixel durchlaufen
  {
    for (x=0;x<tabx;x++,p++)
    {
      tx = x - xmid;
      ty = y - ymid;

      w1= 128.0 + atan2(ty,tx)*fak1;  // winkel von akt. pixel zum mittelpunkt
      z1= sqrt (tx*tx + ty*ty);       // entfernung vom mittelpunkt

      z1+= sin(z1/32.0*pi)*32.0;

      xbuf[p]= w1;
      ybuf[p]= z1;
    }

  }
}

// draw to "dst" with table "tab", using texture "tex"
void tableDraw(char *dst, char *tab1, char *tab2, char *tex, int move, int xp, int yp)
{
  int  p,t,x,y;

  if (xp<0) xp=0; if (xp>tabx/2) xp=tabx/2;
  if (yp<0) yp=0; if (yp>taby/2) yp=taby/2;

  for (y=0;y<yres;y++)
  {
    p= (y+yp)*tabx+xp;
    for (x=0;x<xres;x++,dst++,p++)
    {
      t= ((tab2[p]<<8)+tab1[p]+move) & 0xffff;
      *dst= tex[t];
    }
  }
}

void movetableEffectRelease()
{
   free(tab1);
   free(tab2);
   free(tab3);
   free(tab4);
   free(tab5);
   free(tab6);
   free(texture);
}


void movetableEffectOn(int startTime)
{
   movetableEffect_startTime=startTime;
   xres=320;
   yres=180;

   wosSetMode(8, screenBuffer, movetablePalette(), 0);
   g_currentPal = movetablePalette();

}

void movetableEffectInit()
{
   int tabsize;
   int w,h;

   gifLoad("data/movetable/texture.gif", (void**)&texture, &w,&h, (unsigned int*)&texturepal);
   g_currentPal = texturepal;

  
   // allocate memory
   tabsize= tabx*taby;  // table size
   tab1=   (char*)malloc(tabsize);
   tab2=   (char*)malloc(tabsize);
   tab3=   (char*)malloc(tabsize);
   tab4=   (char*)malloc(tabsize);
   tab5=   (char*)malloc(tabsize);
   tab6=   (char*)malloc(tabsize);

   // build tables   
   build_tunnel(tab1, tab2);
   build_water(tab3, tab4);
   build_sphere(tab5, tab6);
}

// draw all stars to screenbuffer, movement based on time
void movetableDraw(int time, int xtab, int ytab, unsigned char* screenBuffer)
{
   int  xp,yp,move,i;
   char *p1,*p2;
      
   move=time*0x01ff;
  
   xp= ( ((float)tabx/4.0) + fsin(time/48.0)*(tabx>>2) );
   yp= ( ((float)taby/4.0) + fcos(time/64.0)*(taby>>2) );
   
   if (xtab<1) xtab=1;
   if (xtab>6) xtab=6;
   if (ytab<1) ytab=1;
   if (ytab>6) ytab=6;
   
   switch (xtab) {
   case 1:
      p1=tab1;
      break;
   case 2:
      p1=tab2;
      break;
   case 3:
      p1=tab3;
      break;
   case 4:
      p1=tab4;
      break;
   case 5:
      p1=tab5;
      break;
   case 6:
      p1=tab6;
      break;
   default:
      p1=tab1;
      break;
   }
   switch (ytab) {
   case 1:
      p2=tab1;
      break;
   case 2:
      p2=tab2;
      break;
   case 3:
      p2=tab3;
      break;
   case 4:
      p2=tab4;
      break;
   case 5:
      p2=tab5;
      break;
   case 6:
      p2=tab6;
      break;
   default:
      p2=tab1;
      break;
   }
   tableDraw(screenBuffer, p1, p2, texture, move, xp, yp);

}

// render method called from main.c
void movetableEffectRender(int time, int xtab, int ytab)
{     
   // clear screen
   memset32(screenBuffer, 0, xres*yres);
   
   movetableDraw(time, xtab, ytab, screenBuffer);

}

