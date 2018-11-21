#ifndef CLIP_H
#define CLIP_H

#include "vertex.h"

void clipResetScratch();
int clipTest2d(Vertex* v);
int clipLine2d(Vertex** out1, Vertex** out2);

#endif // CLIP_H
