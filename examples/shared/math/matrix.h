#ifndef MATRIX_H
#define MATRIX_H

// a simple 4x3 integer matrix
// all values are 5.10bit signed fixed point

#include "imath.h"
#include "vector.h"

#define MATRIX_FRAC_BITS 10

typedef struct
{
  int   xx, xy, xz, xw,
        yx, yy, yz, yw,
        zx, zy, zz, zw;
} Matrix;

static _INLINE_ void matrixSetIdentity(Matrix* matrix);
static _INLINE_ void matrixSet(Matrix* matrix, float* data);
static _INLINE_ void matrixSetScale(Matrix* matrix, int x, int y, int z);
static _INLINE_ void matrixMultiplyVector(Vector* matrix, Matrix* m, Vector* v);
static _INLINE_ void matrixMultiplyMatrix(Matrix* matrix, Matrix* m1, Matrix *m2);
static _INLINE_ void matrixSetRotateX(Matrix* matrix, const int a);
static _INLINE_ void matrixSetRotateY(Matrix* matrix, const int a);
static _INLINE_ void matrixSetRotateZ(Matrix* matrix, const int a);
//static _INLINE_ void matrixGet3x3(Matrix* matrix, Matrix *src);
static _INLINE_ void matrixSetTranspose3x3(Matrix* matrix, Matrix* src);
static _INLINE_ void matrixSetTranslation(Matrix* matrix, int x, int y, int z);


// identity matrix
static void matrixSetIdentity(Matrix* m)
{
   const int t= (1<<MATRIX_FRAC_BITS);
   m->xx= t; m->xy= 0; m->xz= 0; m->xw= 0;
   m->yx= 0; m->yy= t; m->yz= 0; m->yw= 0;
   m->zx= 0; m->zy= 0; m->zz= t; m->zw= 0;
}

static void matrixSet(Matrix* m, float* data)
{
   const float scale= (1<<MATRIX_FRAC_BITS);
   m->xx= (int) (data[0] * scale);
   m->xy= (int) (data[1] * scale);
   m->xz= (int) (data[2] * scale);
   m->xw= (int) (data[3] * scale);
   m->yx= (int) (data[4] * scale);
   m->yy= (int) (data[5] * scale);
   m->yz= (int) (data[6] * scale);
   m->yw= (int) (data[7] * scale);
   m->zx= (int) (data[8] * scale);
   m->zy= (int) (data[9] * scale);
   m->zz= (int) (data[10] * scale);
   m->zw= (int) (data[11] * scale);
}


// scale matrix x,y,z
static void matrixSetScale(Matrix* dst, int x, int y, int z)
{
   dst->xx= x; dst->xy= 0; dst->xz= 0; dst->xw= 0;
   dst->yx= 0; dst->yy= y; dst->yz= 0; dst->yw= 0;
   dst->zx= 0; dst->zy= 0; dst->zz= z; dst->zw= 0;
}


// matrix * vector
static void matrixMultiplyVector(Vector* dst, Matrix* m, Vector* v)
{
   dst->x= ((m->xx*v->x + m->xy*v->y + m->xz*v->z)>>MATRIX_FRAC_BITS) + m->xw;
   dst->y= ((m->yx*v->x + m->yy*v->y + m->yz*v->z)>>MATRIX_FRAC_BITS) + m->yw;
   dst->z= ((m->zx*v->x + m->zy*v->y + m->zz*v->z)>>MATRIX_FRAC_BITS) + m->zw;
}


// matrix * matrix
static void matrixMultiplyMatrix(Matrix* dst, Matrix* m1, Matrix *m2)
{
   dst->xx= ((m2->xx*m1->xx + m2->xy*m1->yx + m2->xz*m1->zx)>>MATRIX_FRAC_BITS);
   dst->xy= ((m2->xx*m1->xy + m2->xy*m1->yy + m2->xz*m1->zy)>>MATRIX_FRAC_BITS);
   dst->xz= ((m2->xx*m1->xz + m2->xy*m1->yz + m2->xz*m1->zz)>>MATRIX_FRAC_BITS);
   dst->xw= ((m2->xx*m1->xw + m2->xy*m1->yw + m2->xz*m1->zw)>>MATRIX_FRAC_BITS) + m2->xw;

   dst->yx= ((m2->yx*m1->xx + m2->yy*m1->yx + m2->yz*m1->zx)>>MATRIX_FRAC_BITS);
   dst->yy= ((m2->yx*m1->xy + m2->yy*m1->yy + m2->yz*m1->zy)>>MATRIX_FRAC_BITS);
   dst->yz= ((m2->yx*m1->xz + m2->yy*m1->yz + m2->yz*m1->zz)>>MATRIX_FRAC_BITS);
   dst->yw= ((m2->yx*m1->xw + m2->yy*m1->yw + m2->yz*m1->zw)>>MATRIX_FRAC_BITS) + m2->yw;

   dst->zx= ((m2->zx*m1->xx + m2->zy*m1->yx + m2->zz*m1->zx)>>MATRIX_FRAC_BITS);
   dst->zy= ((m2->zx*m1->xy + m2->zz*m1->zy + m2->zy*m1->yy)>>MATRIX_FRAC_BITS);
   dst->zz= ((m2->zx*m1->xz + m2->zy*m1->yz + m2->zz*m1->zz)>>MATRIX_FRAC_BITS);
   dst->zw= ((m2->zx*m1->xw + m2->zy*m1->yw + m2->zz*m1->zw)>>MATRIX_FRAC_BITS) + m2->zw;
}



static void matrixSetRotateX(Matrix* dst, const int a)
{
   const int c = icos(a) >> (15-MATRIX_FRAC_BITS);
   const int s = isin(a) >> (15-MATRIX_FRAC_BITS);
   const int t= (1<<MATRIX_FRAC_BITS);

   dst->xx = t; dst->xy = 0; dst->xz =  0; dst->xw = 0;
   dst->yx = 0; dst->yy = c; dst->yz =  s; dst->yw = 0;
   dst->zx = 0; dst->zy =-s; dst->zz =  c; dst->zw = 0;
}

static void matrixSetRotateY(Matrix* dst, const int a)
{
   const int c = icos(a) >> (15-MATRIX_FRAC_BITS);
   const int s = isin(a) >> (15-MATRIX_FRAC_BITS);
   const int t= (1<<MATRIX_FRAC_BITS);

   dst->xx =  c; dst->xy = 0; dst->xz = s; dst->xw = 0;
   dst->yx =  0; dst->yy = t; dst->yz = 0; dst->yw = 0;
   dst->zx = -s; dst->zy = 0; dst->zz = c; dst->zw = 0;
}

static void matrixSetRotateZ(Matrix* dst, const int a)
{
   const int c = icos(a) >> (15-MATRIX_FRAC_BITS);
   const int s = isin(a) >> (15-MATRIX_FRAC_BITS);
   const int t= (1<<MATRIX_FRAC_BITS);

   dst->xx = c;  dst->xy =-s; dst->xz = 0; dst->xw = 0;
   dst->yx = s;  dst->yy = c; dst->yz = 0; dst->yw = 0;
   dst->zx = 0;  dst->zy = 0; dst->zz = t; dst->zw = 0;
}

static void matrixSetTranspose3x3(Matrix* dst, Matrix* src)
{
   dst->xx = src->xx;
   dst->xy = src->yx;
   dst->xz = src->zx;
   dst->xw = 0;

   dst->yx = src->xy;
   dst->yy = src->yy;
   dst->yz = src->zy;
   dst->yw = 0;

   dst->zx = src->xz;
   dst->zy = src->yz;
   dst->zz = src->zz;
   dst->zw = 0;
}

static void matrixSetTranslation(Matrix* dst, int x, int y, int z)
{
   dst->xw= x;
   dst->yw= y;
   dst->zw= z;
}

#endif
