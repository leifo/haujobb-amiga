#include "clip2d.h"
#include "math/imath.h"

#define CLIP_LEFT    1
#define CLIP_RIGHT   2
#define CLIP_TOP     4
#define CLIP_BOTTOM  8

static Vertex vtxScratch[16];
static int vtxScratchNum= 0;

extern int xres, yres;

void clipResetScratch()
{
   vtxScratchNum= 0;
}

// get next free vertex from scratch buffer
static Vertex* getScratchVertex()
{
   Vertex* v= &vtxScratch[vtxScratchNum++];
   return v;
}

static _INLINE_ int clipTestLeft(Vertex* v)
{
   if (v->x < 0)
      return CLIP_LEFT;
   else
      return 0;
}

static _INLINE_ int clipTestRight(Vertex* v)
{
   const int right= (xres-1)<<4;
   if (v->x > right)
      return CLIP_RIGHT;
   else
      return 0;
}

static _INLINE_ int clipTestTop(Vertex* v)
{
   if (v->y < 0)
      return CLIP_TOP;
   else
      return 0;
}

static _INLINE_ int clipTestBottom(Vertex* v)
{
   const int bottom= (yres)<<4;
   if (v->y > bottom)
      return CLIP_BOTTOM;
   else
      return 0;
}

int clipTest2d(Vertex* v)
{
   int clip= 0;
   clip |= clipTestLeft(v);
   clip |= clipTestRight(v);
   clip |= clipTestTop(v);
   clip |= clipTestBottom(v);
   return clip;
}


static int clipLeft(Vertex** out, Vertex* v1, Vertex* v2)
{
   int count= 0;
   int c1= clipTestLeft(v1);
   int c2= clipTestLeft(v2);

   if (c1 & c2) return 0;

   if (c1 == 0)
      out[count++]= v1;

   if (c1 != c2)
   {
      // v1->x + t*(v2->x - v1->x) == 0
      Vertex* dst= getScratchVertex();
      float t= v1->x / (float)(v1->x - v2->x);
      dst->x= 0;
      dst->y= v1->y + (v2->y - v1->y)*t;
      dst->z= v1->z + (v2->z - v1->z)*t;
      out[count++]= dst;
   }

   if (c2 == 0)
      out[count++]= v2;

   return count;
}

static int clipRight(Vertex** out, Vertex* v1, Vertex* v2)
{
   int count= 0;
   int c1= clipTestRight(v1);
   int c2= clipTestRight(v2);

   if (c1 & c2) return 0;

   if (c1 == 0)
      out[count++]= v1;

   if (c1 != c2)
   {
      // v1->x + t*(v2->x - v1->x) == right
      const int right= (xres-1)<<4;
      Vertex* dst= getScratchVertex();
      float t= (right - v1->x) / (float)(v2->x - v1->x);
      dst->x= right;
      dst->y= v1->y + (v2->y - v1->y)*t;
      dst->z= v1->z + (v2->z - v1->z)*t;
      out[count++]= dst;
   }

   if (c2 == 0)
      out[count++]= v2;

   return count;
}

static int clipTop(Vertex** out, Vertex* v1, Vertex* v2)
{
   int count= 0;
   int c1= clipTestTop(v1);
   int c2= clipTestTop(v2);

   if (c1 & c2) return 0;

   if (c1 == 0)
      out[count++]= v1;

   if (c1 != c2)
   {
      // v1->y + t*(v2->y - v1->y) == 0
      // t= (0-v1->y) /
      Vertex* dst= getScratchVertex();
      float t= -v1->y / (float)(v2->y - v1->y);
      dst->x= v1->x + (v2->x - v1->x)*t;
      dst->y= 0;
      dst->z= v1->z + (v2->z - v1->z)*t;
      out[count++]= dst;
   }

   if (c2 == 0)
      out[count++]= v2;

   return count;
}

static int clipBottom(Vertex** out, Vertex* v1, Vertex* v2)
{
   int count= 0;
   int c1= clipTestBottom(v1);
   int c2= clipTestBottom(v2);

   if (c1 & c2) return 0;

   if (c1 == 0)
      out[count++]= v1;

   if (c1 != c2)
   {
      // v1->y + t*(v2->y - v1->y) == bottom
      Vertex* dst= getScratchVertex();
      const int bottom= (yres)<<4;
      float t= (bottom - v1->y) / (float)(v2->y - v1->y);
      dst->x= v1->x + (v2->x - v1->x)*t;
      dst->y= bottom;
      dst->z= v1->z + (v2->z - v1->z)*t;
      out[count++]= dst;
   }

   if (c2 == 0)
      out[count++]= v2;

   return count;
}

int clipLine2d(Vertex** out1, Vertex** out2)
{
   int count;
   Vertex* v1= *out1;
   Vertex* v2= *out2;
   Vertex* line[2];

   count= clipLeft(line, v1, v2);
   if (count==0) return 0;
   v1= line[0]; v2= line[1];

   count= clipRight(line, v1, v2);
   if (count==0) return 0;
   v1= line[0]; v2= line[1];

   count= clipTop(line, v1, v2);
   if (count==0) return 0;
   v1= line[0]; v2= line[1];

   count= clipBottom(line, v1, v2);
   if (count==0) return 0;
   v1= line[0]; v2= line[1];

   *out1= v1;
   *out2= v2;
   return 2;
}
