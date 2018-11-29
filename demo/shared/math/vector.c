#include "vector.h"
#include <math.h>

void vectorSet(Vector* dst, int x, int y, int z)
{
   dst->x= x;
   dst->y= y;
   dst->z= z;
}

void vectorAdd(Vector* dst, Vector* v1, Vector* v2)
{
   dst->x= v1->x + v2->x;
   dst->y= v1->y + v2->y;
   dst->z= v1->z + v2->z;
}

void vectorSub(Vector* dst, Vector* v1, Vector* v2)
{
   dst->x= v1->x - v2->x;
   dst->y= v1->y - v2->y;
   dst->z= v1->z - v2->z;
}

// todo: vectors have some fractional part which is not defined yet...
void vectorCross(Vector* dst, Vector* v1, Vector* v2)
{
   dst->x= (v1->y*v2->z - v1->z*v2->y);
   dst->y= (v1->z*v2->x - v1->x*v2->z);
   dst->z= (v1->x*v2->y - v1->y*v2->x);
}

// todo: vectors have some fractional part which is not defined yet...
void vectorCross8(Vector* dst, Vector* v1, Vector* v2)
{
   dst->x= (v1->y*v2->z - v1->z*v2->y)>>8;
   dst->y= (v1->z*v2->x - v1->x*v2->z)>>8;
   dst->z= (v1->x*v2->y - v1->y*v2->x)>>8;
}

int vectorDot(Vector* v1, Vector* v2)
{
   return (v1->x*v2->x + v1->y*v2->y + v1->z*v2->z);
}

void vectorNormalize(Vector* dst)
{
   int len2= vectorDot(dst,dst);
   if (len2>0)
   {
      double t= 1024.0 / sqrt((double)len2);
      dst->x= (int) (dst->x * t);
      dst->y= (int) (dst->y * t);
      dst->z= (int) (dst->z * t);
   }
   else
   {
      dst->x= 0;
      dst->y= 0;
      dst->z= 0;
   }
}


void vectorLinear(Vector* dst, Vector* v1, Vector* v2, int alpha)
{
   dst->x = v1->x + ((v2->x - v1->x)*alpha>>8);
   dst->y = v1->y + ((v2->y - v1->y)*alpha>>8);
   dst->z = v1->z + ((v2->z - v1->z)*alpha>>8);
}
