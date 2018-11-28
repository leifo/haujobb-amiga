#include "cachesim.h"
#include "tools/malloc.h"
#include "string.h"
#include <stdio.h>

#define CACHE_BLOCKSIZE (1<<CACHE_BLOCKSIZEBITS)
#define CACHE_BLOCKMASK (CACHE_BLOCKSIZE-1)
#define CACHE_BLOCKSPERSET (1<<CACHE_BLOCKSPERSETBITS)
#define CACHE_SETS (CACHE_BLOCKS>>CACHE_BLOCKSPERSETBITS)
#define CACHE_SETMASK (CACHE_SETS-1)

typedef struct
{
   unsigned int total;
   unsigned int miss;
   char* name;
} CacheProfile;


static unsigned int accessCounter= 0;
static int profileCount= 0;
static CacheProfile* cacheProfiles[32];
static CacheProfile* currentProfile= 0;

typedef struct
{
//   unsigned char data[CACHE_BLOCKSIZE];
   unsigned int address;
   unsigned int access;
} CacheBlock;

typedef struct
{
   CacheBlock block[CACHE_BLOCKSPERSET];
} CacheSet;

static CacheSet* cacheSets= 0;

void cacheInit()
{
   int i,j;
   cacheSets= new(CacheSet, CACHE_SETS);
   for (i=0; i<CACHE_SETS; i++)
   {
      CacheSet* set= &cacheSets[i];
      for (j=0; j<CACHE_BLOCKSPERSET; j++)
      {
         CacheBlock* block= &set->block[j];
         block->address= 0; // invalid
         block->access= 0;
      }
   }

   // clear profiles
   for (i=0; i<32; i++)
      cacheProfiles[i]= 0;
   currentProfile= 0;
   profileCount= 0;
}

void cacheRelease()
{
   // TODO
}

int cacheAddProfile(const char* name)
{
   int id,length;
   CacheProfile* profile= 0;

   if (profileCount >= 32)
      return -1;

   length= strlen(name);
   profile= (CacheProfile*)malloc( sizeof(CacheProfile) );
   profile->total= 0;
   profile->miss= 0;
   profile->name= malloc(length+1);
   strcpy(profile->name, name);

   id= profileCount;
   cacheProfiles[id]= profile;
   profileCount++;

   return id;
}

void cacheProfileClear(int id)
{
   CacheProfile* profile= cacheProfiles[id];
   profile->miss= 0;
   profile->total= 0;
}

int cacheProfileGetHit(int id)
{
   CacheProfile* profile= cacheProfiles[id];
   return profile->total - profile->miss;
}

int cacheProfileGetMiss(int id)
{
   CacheProfile* profile= cacheProfiles[id];
   return profile->miss;
}

void cacheSetProfile(int id)
{
   currentProfile= cacheProfiles[id];
}

void cachePrint()
{
   int i,j;
   for (i=0; i<CACHE_SETS; i++)
   {
      CacheSet* set= &cacheSets[i];
      printf("%d: ", i);
      for (j=0; j<CACHE_BLOCKSPERSET; j++)
      {
         CacheBlock* block= &set->block[j];
         printf("%8x ", block->address);
      }
      printf("\n");
   }
}

void cacheProfilePrint()
{
   int i;
   for (i=0; i<profileCount; i++)
   {
      CacheProfile* profile= cacheProfiles[i];
      double ratio= (double)profile->total / (double)profile->miss;
//      fprintf(stderr, "%s: %d / %d \n", profile->name, profile->miss, profile->total);
//      fflush(stderr);
   }
}

CacheBlock* cacheFindBlock(CacheSet* set, unsigned int address)
{
   int i;
   unsigned int blockStart= address & ~CACHE_BLOCKMASK; // zero out offset bits

   if (currentProfile)
      currentProfile->total++;

   // block in cache?
   for (i=0; i<CACHE_BLOCKSPERSET; i++)
   {
      CacheBlock* block= &set->block[i];
      if (block->address == blockStart)
      {
         return block;
      }
   }

   if (currentProfile)
      currentProfile->miss++;

   return 0;
}

CacheBlock* cacheGetBlock(CacheSet* set, unsigned int address)
{
   int i;
   CacheBlock* bestBlock= 0;
   unsigned int oldestAccess= 0;

   unsigned int blockStart= address & ~CACHE_BLOCKMASK; // zero out offset bits

   // block in cache?
   bestBlock= cacheFindBlock(set, address);
   if (bestBlock)
      return bestBlock;

   // not in cache. find oldest block
   for (i=0; i<CACHE_BLOCKSPERSET; i++)
   {
      CacheBlock* block= &set->block[i];
      unsigned int old= 0;
      if (accessCounter >= block->access)
         old= accessCounter - block->access;
      else
         old= block->access - accessCounter;

      if (old >= oldestAccess)
      {
         oldestAccess= old;
         bestBlock= block;
      }
   }

   // write block back into memory
   if (bestBlock->address) // valid block
   {
      // simualtor is transparent, data is already in memory
   }

   // read new block from memory
   bestBlock->address= blockStart;
   return bestBlock;
}

unsigned char blockReadByte(CacheBlock* block, unsigned int address)
{
   int offset= address & CACHE_BLOCKMASK;
   unsigned char* data= (unsigned char*)block->address;
   block->access= accessCounter++;
   return data[offset];
}

void blockWriteByte(CacheBlock* block, unsigned int address, unsigned char value)
{
   int offset= address & CACHE_BLOCKMASK;
   unsigned char* data= (unsigned char*)block->address;
   block->access= accessCounter++;
   data[offset]= value;
}

int cacheTest(void* data, int offset)
{
   unsigned int address= (unsigned int)data + offset;
   int setId= address >> CACHE_BLOCKSIZEBITS & CACHE_SETMASK;
   CacheSet* set= &cacheSets[setId];
   CacheBlock* block= cacheFindBlock(set, address);
   if (block)
      return 1;
   else
      return 0;
}

unsigned char cacheReadByte(void* data, int offset)
{
   unsigned int address= (unsigned int)data + offset;
   int setId= address >> CACHE_BLOCKSIZEBITS & CACHE_SETMASK;
   CacheSet* set= &cacheSets[setId];
   CacheBlock* block= cacheGetBlock(set, address);
   return blockReadByte(block, address);
}


void cacheWriteByte(void* data, int offset, unsigned char value)
{
   unsigned int address= (unsigned int)data + offset;
   int setId= address >> CACHE_BLOCKSIZEBITS & CACHE_SETMASK;
   CacheSet* set= &cacheSets[setId];
   CacheBlock* block= cacheGetBlock(set, address);
   blockWriteByte(block, address, value);
}

