#ifndef MOVETABLEEFFECT_H
#define MOVETABLEEFFECT_H

void movetableEffectInit();
void movetableEffectOn(time);
void movetableEffectRender(int time);
void movetableEffectRelease();
unsigned int* movetablePalette();

#endif
