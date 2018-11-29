#ifndef CACHESIM_H
#define CACHESIM_H

// 68060 data cache:
// 512 lines a 16 byte = 8192 bytes

#ifndef AMIGA
#define CACHESIM_ENABLED 1
#endif

#define CACHE_BLOCKSIZEBITS 4
#define CACHE_BLOCKSPERSETBITS   2
#define CACHE_BLOCKS    256

void cacheInit();
int cacheAddProfile(const char* name);
void cacheSetProfile(int id);

unsigned char cacheReadByte(void* data, int offset);
void cacheWriteByte(void* data, int offset, unsigned char v);
int cacheTest(void* data, int offset);

void cacheProfileClear(int id);
int cacheProfileGetHit(int id);
int cacheProfileGetMiss(int id);

void cachePrint();
void cacheProfilePrint();

#ifdef CACHESIM_ENABLED
   #define CACHE_READBYTE(p, o) cacheReadByte(p, o)
   #define CACHE_WRITEBYTE(p, o, v) cacheWriteByte(p, o, v)
   #define CACHE_TEST(p, o) cacheTest(p, o)
   #define CACHE_SETPROFILE(id) cacheSetProfile(id)
   #define CACHE_TOUCH(p) cacheReadByte(p, 0)

#else
   #define CACHE_READBYTE(p, o) p[o]
   #define CACHE_WRITEBYTE(p, o, v) p[o]= v
   #define CACHE_TEST(p, o) 0
   #define CACHE_SETPROFILE(id)
   #define CACHE_TOUCH(p)

#endif

#endif // CACHESIM_H
