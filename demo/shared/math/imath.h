#ifndef IMATH_H
#define IMATH_H

#ifndef AMIGA
   #define _INLINE_
   #define INPUT(x)
   #define MODIFIED(x)
   #define ASMCOMMENT(text);
   #define PUSH(text)
   #define POP(text)
#else
   #define _INLINE_ inline
   #define INPUT(x) __reg(x)
   #define MODIFIED(x) __regsused(x)
   #define ASMCOMMENT(text) __asm("; "text);
   #define PUSH(text) __asm("\tfmovem "text",-(a7)");
   #define POP(text) __asm("\tfmovem (a7)+,"text);
#endif

extern const short sinTable[];
extern const unsigned int logDivTable[];
extern const unsigned char clz_lkup[];
extern const unsigned int tanTable[];

float fsin(const float x);
float fcos(const float x);

// returns sin(x*M_PI/32768.0f) * 32768.0f;
// input range:  [0..2PI] -> [0..65536]
// output scale: [-1..+1] -> [-32768..+32768]
static _INLINE_ int isin(int x);

// returns cos(x*M_PI/32768.0f) * 32768.0f;
// input range:  [0..2PI] -> [0..65536]
// output scale: [-1..+1] -> [-32768..+32768]
static _INLINE_ int icos(int x);

// integer ceil with n bits fractional part
// round to next integer if fractional part is > zero:
// 4.0 -> 4
// 4.1 -> 5
static _INLINE_ int iceil4(int x);
static _INLINE_ int iceil8(int x);
static _INLINE_ int iceil16(int x);

// integer floor with n bits fractional part
// round to whole integer M= x
// 4.0 -> 4
// 4.1 -> 4
// 4.9 -> 4
static _INLINE_ int ifloor4(int x);
static _INLINE_ int ifloor8(int x);
static _INLINE_ int ifloor16(int x);

// returns the fractional part of an fixed point integer (last n bits)
static _INLINE_ int ifrac4(int x);
static _INLINE_ int ifrac8(int x);

// returns remainder to next whole integer
// 2.3 -> (3.0-2.3) = 0.7
// 2.0 -> (2.0-2.0) = 0.0
static _INLINE_ int iremain4(int x);
static _INLINE_ int iremain8(int x);
static _INLINE_ int iremain16(int x);

// several fixed point multiply helper functions
// does 32*32bit=64bit multiply and removes the given number of lower bits
static _INLINE_ int imul12(int a, int b);
static _INLINE_ int imul16(int a, int b);
static _INLINE_ int imul24(int a, int b);
static _INLINE_ int imul28(int a, int b);
static _INLINE_ int imul32(int a, int b);

// count leading zeros of a 32bit integer
// clz( 00000010111011010001000000001110b ) = 6
static _INLINE_ unsigned int clz(unsigned int x);

// approximates (1<<28)/x
static _INLINE_ unsigned int iinv28(unsigned int x);

static int iabs(int a)
{
   if (a<0)
      return -a;
   else
      return a;
}

// maximum of 2 unsigned integers
static int _INLINE_ max2(int a, int b)
{
   if (b>a)
      a= b;
   return a;
}

// minimum of 2 unsigned integers
static int _INLINE_ min2(int a, int b)
{
   if (b<a)
      a= b;
   return a;
}

// maximum of 2 unsigned integers
static unsigned int _INLINE_ max2u(unsigned int a, unsigned int b)
{
   if (b>a)
      a= b;
   return a;
}

// minimum of 2 unsigned integers
static unsigned int _INLINE_ min2u(unsigned int a, unsigned int b)
{
   if (b<a)
      a= b;
   return a;
}

// maximum of 3 signed integers
static int _INLINE_ max3(int a, int b, int c)
{
   if (a>=b)
   {
      // a || c
      if (a>c)
         return a;
      else
         return c;
   }
   else // b > a
   {
      // b || c
      if (b > c)
         return b;
      else
         return c;
   }
}

// minimum of 3 signed integers
static int _INLINE_ min3(int a, int b, int c)
{
   if (a<=b)
   {
      // a || c
      if (a<c)
         return a;
      else
         return c;
   }
   else // b < a
   {
      // b || c
      if (b < c)
         return b;
      else
         return c;
   }
}

static int imul12(int a, int b)
{
   ASMCOMMENT("imath imul12");
   return (int) ((long long)a * b >> 12);
}

static int sign(int a)
{
   if (a<0)
      return 1;
   else
      return 0;
}

static int imul16(int ia, int ib)
{
   unsigned int al,ah,bl,bh;
   unsigned int p0,p1,p2,p3;
   unsigned int a,b;
   int result;
   int s= 0;

   ASMCOMMENT("imath imul16");

   if (ia<0)
   {
      a= -ia;
      s++;
   }
   else
   {
      a= ia;
   }

   if (ib<0)
   {
      b= -ib;
      s++;
   }
   else
   {
      b= ib;
   }

   /*
   a = (ah << 16) + al;
   b = (bh << 16) + bl;

   a * b = ((ah << 16) + al) * ((bh << 16) + bl)
         = ((ah * bh) << 32) +
           ((ah * bl) << 16) +
           ((bh * al) << 16) +
             al * bl
   */

    // split operands into halves
    al = a & 0xffff;
    ah = a >> 16;
    bl = b & 0xffff;
    bh = b >> 16;

    // compute partial products
    p0 = al * bl;
    p1 = al * bh;
    p2 = ah * bl;
    p3 = ah * bh;

    // sum partial products
    result= (p3<<16) + p2 + p1 + (p0 >> 16);// + (((p1 & 0xffff) + (p2 & 0xffff))>>16);

    if (s==1) result=-(result);
    return result;
//   return (int) ((long long)a * b >> 16);
}


static int imul24(int a, int b)
{
   ASMCOMMENT("imath imul24");
   return (int) ((long long)a * b >> 24);
}

static int imul28(int a, int b)
{
   ASMCOMMENT("imath imul28");
   return (int) ((long long)a * b >> 28);
}

static int imul32(int a, int b)
{
   ASMCOMMENT("imath imul32");
   return (int) ((long long)a * b >> 32);
}



static int iceil4(int x)
{
   ASMCOMMENT("imath iceil4");
   return (x + 0xf) >> 4;
}

static int iceil8(int x)
{
   ASMCOMMENT("imath iceil8");
   return (x + 0xff) >> 8;
}

static int iceil16(int x)
{
   ASMCOMMENT("imath iceil16");
   return (x + 0xffff) >> 16;
}



static int ifloor4(int x)
{
   ASMCOMMENT("imath ifloor4");
   return x >> 4;
}

static int ifloor8(int x)
{
   ASMCOMMENT("imath ifloor8");
   return x >> 8;
}

static int ifloor16(int x)
{
   ASMCOMMENT("imath ifloor16");
   return x >> 16;
}



static int ifrac4(int x)
{
   ASMCOMMENT("imath ifrac4");
   return x & 15;
}

static int ifrac8(int x)
{
   ASMCOMMENT("imath ifrac8");
   return x & 255;
}

static int ifrac16(int x)
{
   ASMCOMMENT("imath ifrac16");
    return x & 65535;
}



static int iremain4(int x)
{
   ASMCOMMENT("imath iremain4");
   return (-x) & 15;
}

static int iremain8(int x)
{
   ASMCOMMENT("imath iremain8");
   return (-x) & 255;
}

static int iremain16(int x)
{
   ASMCOMMENT("imath iremain16");
   return (-x) & 65535;
}



// count leading zero bits
static unsigned int clz(unsigned int x)
{
   unsigned int n;
   if (x >= (1 << 16)) {
      if (x >= (1 << 24))
         n = 24;
      else
         n = 16;
   } else {
      if (x >= (1 << 8))
         n = 8;
      else
         n = 0;
   }
   ASMCOMMENT("imath clz");
   return (unsigned int)clz_lkup[x >> n] - n;
}



// approximate (1<<28) / v
// "v" is expected to be 4-bit fractional
static unsigned int iinv28(unsigned int v)
{
   // 1st aproximation from logarithmic table
   unsigned int l2= clz(v);
   unsigned int x= logDivTable[ l2 ] >> 4;
//   unsigned int x= ((1<<20) / v)<<8;

   x= imul28(x, (0x20000000 - (v*x)));
   x= imul28(x, (0x20000000 - (v*x)));
   x= imul28(x, (0x20000000 - (v*x)));
//   x= imul28(x, (0x20000000 - (v*x)));
   
   ASMCOMMENT("imath iinv28");
   return x;
}


// linear interpolation from sine table
// this default version is basically isin15
// isin(x) = sin(x*PI/32768)*32768
static int isin(int x)
{
   signed short s1, s2;
   int ip;

   // table only stores the psoitive half of the sine (0..PI)
   // as we scale 0..2PI -> 0..65535, the second half of the sine is 32768..65535
   // so if bit15 is set, we return the negative value
   int neg= x >> 15 & 1;

   // extract fractional part for interpolation
   // value: 0..32767
   // table: 0..512
   // -> 6 bit of fractional part
   int fract= x & 63;

   // get two adjacent values from the table
   x= x >> 6 & 511;
   s1= sinTable[x];
   s2= sinTable[x+1];

   // linear interpolation
   ip= s1 + ( (s2-s1) * fract >> 6 );

   // negative
   if (neg)
      ip= -ip;

   ASMCOMMENT("imath isin");
   return ip;
}

static int itan(int x)
{
   int s1, s2;
   int ip,fract,d;

   // table only stores the psoitive half of the sine (0..PI)
   // as we scale 0..2PI -> 0..65535, the second half of the sine is 32768..65535
   // so if bit15 is set, we return the negative value
   d= (iabs(x) + 16384) & 32767;

   // extract fractional part for interpolation
   // value: 0..32767
   // table: 0..512
   // -> 6 bit of fractional part
   fract= d & 63;

   // get two adjacent values from the table
   d= d >> 6 & 511;
   s1= tanTable[d];
   s2= tanTable[d+1];

   // linear interpolation
   ip= s1 + ( (s2-s1) * fract >> 6 );

   if (x<0)
      ip= -ip;

   ASMCOMMENT("imath itan");
   return ip;
}


// integer cosine
// using phase shifted sine
static int icos(int x)
{
   ASMCOMMENT("imath icos");
   return isin(x+16384);
}


// returns 10bits of precision (-1024..+1024)
static int isin10(int x)
{
   signed short s1, s2;
   int ip;

   // table only stores the psoitive half of the sine (0..PI)
   // as we scale 0..2PI -> 0..65535, the second half of the sine is 32768..65535
   // so if bit15 is set, we return the negative value
   int neg= x >> 15 & 1;

   // extract fractional part for interpolation
   // value: 0..32767
   // table: 0..512
   // -> 6 bit of fractional part
   int fract= x & 63;

   // get two adjacent values from the table
   x= x >> 6 & 511;
   s1= sinTable[x];
   s2= sinTable[x+1];

   // linear interpolation
   ip= s1 + ( (s2-s1) * fract >> 11 );

   // negative
   if (neg)
      ip= -ip;

   ASMCOMMENT("imath isin10");
   return ip;
}


// integer cosine
// using phase shifted sine
static int icos10(int x)
{
   ASMCOMMENT("imath icos");
   return isin10(x+16384);
}


#endif
