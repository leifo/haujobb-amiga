#include "image.h"
#include "tga.h"
#include "../math/imath.h"
#include "../tools/memory.h"
#include "../tools/malloc.h"

static Image tempImage;
Image* imageTemp(unsigned char* data, int width, int height)
{
   tempImage.mData= data;
   tempImage.mWidth= width;
   tempImage.mHeight= height;
   tempImage.mPitch= width;
   return &tempImage;
}

Image* imageCreate()
{
   Image* image= (Image*)malloc( sizeof(Image) );
   imageInit(image);
   return image;
}

void imageInit(Image* image)
{
   image->mData= 0;
   image->mWidth= 0;
   image->mHeight= 0;
   image->mPitch= 0;
}

void imageRelease(Image* image)
{
   if (image->mData)
   {
      free(image->mData);
      image->mData= 0;
   }
   image->mWidth= 0;
   image->mHeight= 0;
   image->mPitch= 0;
}

void imageAlloc(Image* image, int width, int height, int pitch)
{
   if (width>0 && height>0)
   {
      image->mWidth= width;
      image->mHeight= height;
      if (pitch<=0)
         image->mPitch= (width+15)>>4<<4;
      else
         image->mPitch= pitch;
      image->mData= (unsigned char*)malloc(image->mPitch * image->mHeight);
   }
   else
   {
      image->mData= 0;
      image->mWidth= 0;
      image->mHeight= 0;
      image->mPitch= 0;
   }
}

int imageWidth(Image* image)
{
   return image->mWidth;
}

int imageHeight(Image* image)
{
   return image->mHeight;
}

void imageClear(Image* image, unsigned char colorIndex)
{
   int y;
   for (y=0; y<image->mHeight; y++)
   {
      unsigned int* dst= (unsigned int*)imageScanline(image, y);
      unsigned int fill= (colorIndex<<24)|(colorIndex<<16)|(colorIndex<<8)|(colorIndex);
      int width= imageWidth(image) >> 2;
      do {
         *dst++= fill;
      } while (--width);
   }
}

unsigned char* imageData(Image* image)
{
   return image->mData;
}

unsigned char* imageScanline(Image* image, int lineIndex)
{
   return image->mData + lineIndex * image->mPitch;
}

int imageLoad(Image* image, const char* filename, unsigned int* pal)
{
   int result= tgaLoad8(filename, (void**)&image->mData, &image->mWidth, &image->mHeight, pal);
   image->mPitch= image->mWidth;
   return result;
}

int imageLoad18(Image* image, const char* filename)
{
   int result= tgaLoad18(filename, (void**)&image->mData, &image->mWidth, &image->mHeight);
   image->mPitch= image->mWidth*4;
   return result;
}

int imageLoad30(Image* image, const char* filename)
{
   int result= tgaLoad30(filename, (void**)&image->mData, &image->mWidth, &image->mHeight);
   image->mPitch= image->mWidth*4;
   return result;
}

void imagePremultiply(Image* image, int alpha, int clamp)
{
   int y,x;
   const int w= imageWidth(image);
   const int h= imageHeight(image);
   for (y=0; y<h; y++)
   {
      unsigned char* dst= imageScanline(image, y);
      x= w;
      do
      {
         int col= (*dst);
         col= col * alpha >> 8;
         if (col > clamp) col= clamp;
         *dst++= col;
      } while (--x);
   }
}


// premultiply image pixels with a,r,g,b (0..255) -> image gets darker
void imagePremultiply32(Image* image, int argb)
{
   int x,y;

   const int w= image->mWidth;
   const int h= image->mHeight;

   const int fa= ALPHA(argb);
   const int fr= RED(argb);
   const int fg= GREEN(argb);
   const int fb= BLUE(argb);

   for (y=0; y<h; y++)
   {
      unsigned int* src32= (unsigned int*)imageScanline(image, y);
      x= w;
      do
      {
         const unsigned int col= *src32;
         int a= ALPHA(col) * fa >> 8;
         int r= RED(col) * fr >> 8;
         int g= GREEN(col) * fg >> 8;
         int b= BLUE(col) * fb >> 8;

         *src32++= ARGB32(a,r,g,b);
      } while (--x);
   }
}


void filterScanline(unsigned char* dst, unsigned char* src1, unsigned char* src2, int w, int dx, int py)
{
   int x;
   int px= 0;
   unsigned char suby= py >> 8 & 0xff;
   for (x=0;x<w;x++)
   {
      unsigned char subx= px >> 8 & 0xff;
      int p= px >> 16;
      unsigned char c1= src1[p] + ((src1[p+1] - src1[p]) * subx >> 8);
      unsigned char c2= src2[p] + ((src2[p+1] - src2[p]) * subx >> 8);
      *dst++= c1 + ((c2 - c1) * suby >> 8);
      px+=dx;
   }
}

void imageScale(Image* dstImage, Image* srcImage)
{
   int x,y;
   int dx,dy;
   int py;
   unsigned char *src1,*src2;
   unsigned char *dst= dstImage->mData;

   const int w= imageWidth(dstImage);
   const int h= imageHeight(dstImage);

   if (w>0)
      dx= (srcImage->mWidth<<16) / (w);
   else
      dx= 0;

   if (h>0)
      dy= (srcImage->mHeight<<16) / (h);
   else
      dy= 0;

   py= 0;
   for (y=0;y<h;y++)
   {
      int p= py >> 16;

      src1= imageScanline(srcImage, p);
      if (p>=srcImage->mHeight-1)
         src2= src1;
      else
         src2= src1 + srcImage->mPitch;

      filterScanline(dst, src1, src2, w, dx, py);
      for (x=w;x<dstImage->mPitch;x++)
         *dst++=0;
      py+=dy;
   }
}

void imageAddPreDither(Image* image, int alpha)
{
   int x,y;
   static unsigned char ditherMatrix[4*4]= {
       1, 9, 3,11,   // <- die reihenfolge der bytes pro zeile muessen bei big endian andersrum
      13, 5,15, 7,
       4,12, 2,10,
      16, 8,14, 6
   };

   const int w= imageWidth(image);
   const int h= imageHeight(image);

   for (y=0; y<h; y++)
   {
      unsigned char* matrix= ditherMatrix + ((y&3)<<2);
      unsigned char* dst= imageScanline(image, y);
      for (x=0; x<w; x++)
      {
         int col= dst[x] + (matrix[x & 3] * alpha >> 8);
         if (col>255) col=255;
         if (col<0) col=0;
         dst[x]= col;
      }
   }
}

void imagePitchX(Image* dstImage, Image* srcImage, unsigned char alpha)
{
   int x,y;
   const int w= imageWidth(srcImage);
   const int h= imageHeight(srcImage);
   for (y=0; y<h; y++)
   {
      unsigned char* dst= imageScanline(dstImage, y);
      unsigned char* src= imageScanline(srcImage, y);

      unsigned char c1= src[w-1];
      unsigned char c2;
      for (x=0;x<w;x++)
      {
         c2= src[x];
         dst[x]= c1 + ((c2 - c1) * alpha >> 8);
         c1= c2;
      }
   }
}

void imagePitchY(Image* dstImage, Image* srcImage, unsigned char alpha)
{
   int x,y;
   const int w= imageWidth(srcImage);
   const int h= imageHeight(srcImage);
   unsigned char* src1= imageScanline(srcImage, h-1);
   unsigned char* src2= imageScanline(srcImage, 0);
   unsigned char* dst= imageScanline(dstImage, 0);
   const int pitch= srcImage->mPitch;
   for (y=0; y<h; y++)
   {
      for (x=0;x<w;x++)
      {
         unsigned char c1= src1[x];
         unsigned char c2= src2[x];
         dst[x]= c1 + ((c2 - c1) * alpha >> 8);
      }
      src1= src2;
      src2+= pitch;
      dst+= pitch;
   }
}

// horizontal box blur
// dstImage and srcImage must have the same dimensions
void imageBlurHorizontal(Image* dstImage, Image* srcImage, int radius, int bright)
{
   int x,y;
   const int w= imageWidth(srcImage);
   const int h= imageHeight(srcImage);

   int count= radius*2+1;
   int scale= (bright << 7) / count;

   for (y=0; y<h; y++)
   {
      // left side (with read clipping!)
      unsigned char* src= imageScanline(srcImage, y);
      unsigned char* dst= imageScanline(dstImage, y);

      if (count>0)
      {
         int sum= 0;
         // wrap back into [-radius..-1]
         for (x=0;x<radius;x++) sum+= src[w-1-x];
         for (x=0;x<radius;x++) sum+= src[x];
         for (x=0;x<radius;x++)
         {
            sum+= src[radius+x];
            dst[x]= sum * scale >> 15;
            sum-= src[w-radius+x];
         }

         // center part (no clipping)
         for (x=radius;x<w-radius;x++)
         {
            // add one, remove last
            sum+= src[x+radius];
            dst[x]= sum * scale >> 15;
            sum-= src[x-radius];
         }

         // right side (with clipping)
         // wrap forth into [0..radius]
         for (x=0;x<radius;x++)
         {
            // assume next pixel as black -> just remove last
            dst[w-radius+x]= sum * scale >> 15;
            sum-= src[w-radius*2+x];
            sum+= src[x];
         }
         sum= 0;
      }
      else
      {
         for (x=0; x<w; x++)
         {
            dst[x]= src[x] * scale >> 15;
         }
      }
   }
}

void imageSubVerticalUp(Image* dstImage, Image* srcImage, int blend)
{
   unsigned char* dst;
   unsigned char* src1;
   unsigned char* src2;
   int w= srcImage->mWidth;
   int h= srcImage->mHeight;

   imageAlloc(dstImage, w,h,w);

   dst= dstImage->mData;
   src1= srcImage->mData;
   src2= src1 + w;

   while (h--)
   {
      int x= w;
      while (x--)
      {
         int s1= *src1++;
         int s2= *src2++;
         s1 += (s2-s1) * blend >> 8;
         *dst++= s1;
      }

      // at bottom: wrap back to top
      if (h==1) src2= srcImage->mData;
   }
}


void imageSubHorizontalLeft(Image* dstImage, Image* srcImage, int blend)
{
   unsigned char* dst;
   unsigned char* src;
   int w= srcImage->mWidth;
   int h= srcImage->mHeight;

   imageAlloc(dstImage, w,h,w);

   dst= dstImage->mData;
   src= srcImage->mData;

   while (h--)
   {
      int x= w-1;
      int s1= *src++;
      while (x--)
      {
         int s2= *src++;
         s1 += (s2-s1) * blend >> 8;
         *dst++= s1;
         s1= s2;
      }
      *dst++= s1;
   }
}


unsigned char* getScanline8(Image* image, int y)
{
   if (y<0)
      return imageScanline(image, 0);
   else if (y>=image->mHeight)
      return imageScanline(image, image->mHeight-1);
   else
      return imageScanline(image, y);
}

// linear interpolation between x..y with a=0..256
static int linear(int x, int y, int a)
{
   return x + ((y-x)*a>>8);
}

// scales "source" into the clipped rect (fx1,y1)-(fx2,fy2) of "image"
// coordinates have 8bits fractional part!
void imageResize8(Image* image, Image* source, int fx1, int fy1, int fx2, int fy2)
{
   int x,y;
   unsigned int c1,c2;
   unsigned int c3,c4;
   unsigned char* dst;
   unsigned char* src1;
   unsigned char* src2;
   int u,v,leftU;
   int du=0;
   int dv=0;
   int x1,y1, x2,y2;

   // fixed point deltas 16:8
   if (fx2 > fx1)
      du= ((source->mWidth-1) << 18) / (fx2 - fx1);

   if (fy2 > fy1)
      dv= ((source->mHeight-1) << 18) / (fy2 - fy1);

   x1= iceil8(fx1);
   y1= iceil8(fy1);
   x2= iceil8(fx2);
   y2= iceil8(fy2);

   if (x1<0) x1=0;
   if (y1<0) y1=0;
   if (x2>image->mWidth) x2=image->mWidth;
   if (y2>image->mHeight) y2=image->mHeight;

   u = du * ( (x1<<8) - fx1 ) >> 8;
   v = dv * ( (y1<<8) - fy1 ) >> 8;
   leftU = u; // start-u brauchen wir in jeder zeile wieder

   // clear empty area (top)
   for (y=0; y<y1; y++)
      memset( imageScanline(image,y), 0, image->mPitch );

   for (y=y1; y<y2; y++)
   {
      int sv = v >> 10;
      int subv = v >> 2 & 0xff;

      dst= imageScanline(image, y);
      src1= getScanline8(source, sv);
      src2= getScanline8(source, sv+1);

      for (x=0; x<x1; x++)
         dst[x] = 0;

      u = leftU;
      for( x = x1; x < x2; x++ )
      {
         int subu = u >> 2 & 0xff;
         int su = u >> 10;

         c1= src1[su];
         c2= src1[su+1];
         c3= src2[su];
         c4= src2[su+1];

         c1= linear(c1, c2, subu);
         c3= linear(c3, c4, subu);
         c1= linear(c1, c3, subv);

         dst[x]= c1;
         u += du;
      }

      for (x=x2; x<image->mPitch; x++)
         dst[x] = 0;

      v += dv;
   }

   for (y=y2; y<image->mHeight; y++)
      memset( imageScanline(image,y), 0, image->mPitch );
}


void imageDownsample(Image* image)
{
   int x,y;
   const int w= image->mWidth >> 1;
   const int h= image->mHeight >> 1;
   for (y=0; y<h; y++)
   {
      unsigned char* dst=  imageScanline(image, y);
      unsigned char* src1= imageScanline(image, (y<<1));
      unsigned char* src2= imageScanline(image, (y<<1)+1);
      x=w;
      do
      {
         unsigned int c1= *src1++;
         unsigned int c2= *src1++;
         unsigned int c3= *src2++;
         unsigned int c4= *src2++;

         c1= (c1 + c2 + c3 + c4) >> 2;

         *dst++= c1;
      } while (--x);
      for (x= w; x<image->mWidth; x++) *dst++= 0;
   }

   // clear lower half of the map
   for (y=h; y<image->mHeight; y++)
   {
      unsigned char* dst= imageScanline(image, y);
      memset(dst, 0, image->mPitch);
   }

   image->mWidth= w;
   image->mHeight= h;
}


void imageDownsample32(Image* image)
{
   int x,y;
   const int w= image->mWidth >> 1;
   const int h= image->mHeight >> 1;
   for (y=0; y<h; y++)
   {
      unsigned int* dst=  (unsigned int*)imageScanline(image, y);
      unsigned int* src1= (unsigned int*)imageScanline(image, (y<<1));
      unsigned int* src2= (unsigned int*)imageScanline(image, (y<<1)+1);
      x=w;
      do
      {
         unsigned int c1= *src1++;
         unsigned int c2= *src1++;
         unsigned int c3= *src2++;
         unsigned int c4= *src2++;

         unsigned int a = ALPHA(c1) + ALPHA(c2) + ALPHA(c3) + ALPHA(c4);
         unsigned int r = RED(c1)   + RED(c2)   + RED(c3)   + RED(c4);
         unsigned int g = GREEN(c1) + GREEN(c2) + GREEN(c3) + GREEN(c4);
         unsigned int b = BLUE(c1) +  BLUE(c2) +  BLUE(c3) +  BLUE(c4);

         a>>=2;
         r>>=2;
         g>>=2;
         b>>=2;

         *dst++= ARGB32(a,r,g,b);
      } while (--x);
      for (x= w; x<image->mWidth; x++) *dst++= 0;
   }

   // clear lower half of the map
   for (y=h; y<image->mHeight; y++)
   {
      void* dst= imageScanline(image, y);
      memset(dst, 0, image->mPitch);
   }

   image->mWidth= w;
   image->mHeight= h;
}


static int testColumn(unsigned char* src, const int width, int height, unsigned char keyColor)
{
   while (height--)
   {
      if (*src != keyColor)
         return 0;
      src += width;
   }
   return 1;
}

int imageCropLeft(Image* image, int left, unsigned char keyColor)
{
   const int width= imageWidth(image);
   const int height= imageHeight(image);
   unsigned char* data= imageData(image);

   while (left < width)
   {
      if (testColumn(data+left, width, height, keyColor) == 0)
         break;
      left++;
   }

   return left;
}


int imageCropRight(Image* image, int right, unsigned char keyColor)
{
   const int width= imageWidth(image);
   const int height= imageHeight(image);
   unsigned char* data= imageData(image);
   if (right<0) right= width+right;

   while (right > 0)
   {
      if (testColumn(data+right, width, height, keyColor) == 0)
         break;
      right--;
   }

   return right;
}
