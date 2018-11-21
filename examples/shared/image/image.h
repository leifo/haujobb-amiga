#ifndef IMAGE_H
#define IMAGE_H

typedef struct
{
   unsigned char* mData;
   int            mWidth;
   int            mHeight;
   int            mPitch;
} Image;

#define RGB32(r,g,b) ((r<<16)|(g<<8)|(b))
#define ARGB32(a,r,g,b) ((a<<24)|(r<<16)|(g<<8)|(b))
#define ALPHA(col) (col>>24&255)
#define RED(col) (col>>16&255)
#define GREEN(col) (col>>8&255)
#define BLUE(col) (col&255)
#define GREY32(bright) ((bright<<24)|(bright<<16)|(bright<<8)|(bright))

Image* imageTemp(unsigned char* data, int width, int height);

// allocate one instance
Image* imageCreate();

// initialize image buffer to given width & height
void imageInit(Image* image);

// initialize image buffer to given width & height
void imageAlloc(Image* image, int widht, int height, int pitch);

// release image data
void imageRelease(Image* image);

// clear image with given color index
void imageClear(Image* image, unsigned char colorIndex);

int imageWidth(Image* image);
int imageHeight(Image* image);

// get pointer to image data
unsigned char* imageData(Image* image);

// get pointer to given scanline
unsigned char* imageScanline(Image* image, int lineIndex);

void imageAddDither(Image* image, int alpha);

// move image by 1/x pixel to the left
// 0= no change
// 128= half a pixel
// 255= almost one pixel
void imagePitchX(Image* dstImage, Image* srcImage, unsigned char x);
void imagePitchY(Image* dstImage, Image* srcImage, unsigned char y);

int imageLoad(Image* image, const char* filename, unsigned int* pal);
int imageLoad18(Image* image, const char* filename);
int imageLoad30(Image* image, const char* filename);

void imagePremultiply(Image* image, int bright, int clamp);
void imagePremultiply32(Image* image, int argb);

void imageDownsample(Image* image);
void imageDownsample32(Image* image);

void imageAddPreDither(Image* image, int shift);

void imageBlurHorizontal(Image* dstImage, Image* srcImage, int radius, int bright);

void imageSubVerticalUp(Image* dstImage, Image* srcImage, int blend);
void imageSubHorizontalLeft(Image* dstImage, Image* srcImage, int blend);

void imageResize8(Image* image, Image* source, int fx1, int fy1, int fx2, int fy2);

int imageCropLeft(Image* image, int left, unsigned char keyColor);
int imageCropRight(Image* image, int right, unsigned char keyColor);

#endif // IMAGE_H
