#include <stdlib.h>
#include <stdio.h>

#ifdef malloc
#undef malloc
#endif

#ifdef free
#undef free
#endif

#define MAXALLOCSIZE 2048

static int totalHeap= 0;
static unsigned int totalMallocCalls= 0;
static unsigned int totalMallocSize= 0;
static unsigned int malloc_pos= -1;
static void* malloc_pointer[MAXALLOCSIZE];
static unsigned int malloc_size[MAXALLOCSIZE];

void* myalloc(int size)
{
   void* data= malloc(size);

   if (malloc_pos < 0)
   {
      int i;
      for (i=0; i<MAXALLOCSIZE; i++)
      {
         malloc_pointer[i]= 0;
         malloc_size[i]= 0;
         malloc_pos= 0;
      }
   }

   if (data)
   {
      totalMallocSize+= size;

      printf("  +%04d: (%08x) %d bytes \n", malloc_pos, data, size);
      malloc_pointer[malloc_pos]= data;
      malloc_size[malloc_pos]= size;
      do {
         malloc_pos++;
      } while (malloc_size[malloc_pos]>0);
   }
   totalMallocCalls++;
   return data;
}

void myfree(void* data)
{
   if (data)
   {
      unsigned int i;
      free(data);

      for (i=0; i<MAXALLOCSIZE; i++)
      {
         if (malloc_pointer[i] == data)
         {
            const int size= malloc_size[i];
            printf("  -%04d: (%08x) %d bytes \n", i, data, size);

            totalMallocSize-= size;

            malloc_pointer[i]= 0;
            malloc_size[i]= 0;
            if (i<malloc_pos)
               malloc_pos= i;  // reuse this index on next malloc!

            break;
         }
      }
   }
}

int malloc_totalSize()
{
   return totalMallocSize;
}

int malloc_totalCalls()
{
   return totalMallocCalls;
}

void malloc_debug()
{
   unsigned int i;
   unsigned int total= 0;
   printf("still allocated memory:\n");
   for (i=0; i<MAXALLOCSIZE; i++)
   {
      if (malloc_pointer[i] != 0)
      {
         printf("  %04d: %08x - %d bytes \n", i, malloc_pointer[i], malloc_size[i]);
         total += malloc_size[i];
      }
   }
   printf("total: %d bytes", total);
}
