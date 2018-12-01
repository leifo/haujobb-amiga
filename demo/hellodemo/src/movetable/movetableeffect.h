#ifndef MOVETABLEEFFECT_H
#define MOVETABLEEFFECT_H

void movetableEffectInit();
void movetableEffectOn(time);
void movetableEffectRender(int time, int xtab, int ytab);
void movetableEffectRelease();
unsigned int* movetablePalette();

#endif
