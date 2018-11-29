#ifndef TGA_H
#define TGA_H

#ifdef __cplusplus
extern "C" {
#endif

int loadtga(const char *fname, unsigned int **buf, int *sizex, int *sizey);
int tgaLoad8(const char *filename, void **buffer, int *width, int *height, unsigned int *pal);
int tgaLoad18(const char *filename, void **buffer, int *width, int *height);
int tgaLoad30(const char *filename, void **buffer, int *width, int *height);
int tgaLoad32(const char *filename, void **buffer, int *width, int *height);
int tgaSave8(const char *fname, unsigned char *data, int width, int height, unsigned int* pal);

#ifdef __cplusplus
};
#endif

#endif
