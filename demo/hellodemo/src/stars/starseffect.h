#ifndef STARSEFFECT_H
#define STARSEFFECT_H

void starsEffectInit();
void starsEffectOn(int startTime);
void starsEffectRender(int time, float persfak);
void starsEffectRelease();
unsigned int* starsPalette();

#endif
