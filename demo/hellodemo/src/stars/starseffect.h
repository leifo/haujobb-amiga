#ifndef STARSEFFECT_H
#define STARSFFECT_H

void starsEffectInit();
void starsEffectOn(int startTime);
void starsEffectRender(int time, float persfak);
void starsEffectRelease();
unsigned int* starsPalette();

#endif
