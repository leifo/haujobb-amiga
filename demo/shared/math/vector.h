#ifndef VECTOR_H
#define VECTOR_H

typedef struct
{
  int x,y,z;
} Vector;

void vectorSet(Vector* dst, int x, int y, int z);
void vectorAdd(Vector* dst, Vector* src1, Vector* src2);
void vectorSub(Vector* dst, Vector* src1, Vector* src2);
void vectorCross(Vector* dst, Vector* src1, Vector* src2);
void vectorCross8(Vector* dst, Vector* v1, Vector* v2);
int vectorDot(Vector* src1, Vector* src2);
void vectorNormalize(Vector* dst);

#endif
