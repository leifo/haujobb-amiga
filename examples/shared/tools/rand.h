#ifndef RAND_H
#define RAND_H

void randSeed(unsigned int seed);

int irand();
float frand();

int generateRandom(int min, int max);
float generateRandomF(float min, float max);

int randomNonZero(int max);

#endif // RAND_H

