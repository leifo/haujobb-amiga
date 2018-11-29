
static unsigned int sRandSeed= 1;
static const float sRandScale= 1.0f / 32768.0f;

void randSeed(unsigned int seed)
{
   sRandSeed= seed;
}

// returns random number 0..32767
int irand()
{
   sRandSeed= sRandSeed * 214013L + 2531011L;
   return sRandSeed >> 16 & 0x7fff;
}

// returns random number 0.0 .. 1.0
float frand()
{
   return irand() * sRandScale;
}

// a function to generate a random number between 2 values
float generateRandomF(float min, float max)
{
   return frand() * (max - min) + min;
}

// a function to generate a random number between 2 values
int generateRandom(int min, int max)
{
    return (irand() * (max - min) >> 15) + min;
}

int randomNonZero(int max)
{
   int x= generateRandom(0, max*2) - max;
   if (x>=0) x++;
   return x;
}

