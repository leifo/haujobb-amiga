#ifndef STARS_H
#define STARS_H

#include "common/vertex.h"
#include "tools/rand.h"

#define NUMSTARS 1600
#define STARFIELDSIZE 8192
#define STARFIELDDEPTH 512

void starsInit();
void starsDraw(int time, unsigned char* screenBuffer, int xres, int yres);
void starsDeinit();


#endif // STARS_H
