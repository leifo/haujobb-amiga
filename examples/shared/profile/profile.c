#include "profile.h"
#include "tools/malloc.h"
#include "math/imath.h"
#include <stdio.h>
#include <string.h>
#include <fcntl.h>

#define BUFFERSIZE 1024
static unsigned char buffer[BUFFERSIZE];
static int bufferPos= 0;
static unsigned int* parts;
static int partCount= 0;
// set as -DAMIGA in (see http://www.ibaug.de/vbcc/doc/vbcc.pdf, p.8) in makefile CFLAGS

#ifdef AMIGA

#include <unistd.h>
#include <stdio.h>
#include <exec/types.h>


//--- routines for actual effect profiling when system is off

void startHardwareTimer()
{
    __asm("		;//!!! hand-written inline assembly - startHardwareTimer");
	//__asm("	move.l	a5,-(sp)");
	__asm("		lea	$bfd000,a5");
	__asm("		move.b	#$00,$e00(a5)		; ciaCRA stoppe timer a");
	__asm("		move.b	#$00,$f00(a5)		; ciaCRB stoppe timer b");
	__asm("		move.b	#$07,$700(a5)		; ciaTBH");
	__asm("		move.b	#$ff,$600(a5)		; ciaTBL");
	__asm("		move.b	#$ff,$500(a5)		; ciaTAH");
	__asm("		move.b	#$ff,$400(a5)		; ciaTAL");
	__asm("		move.b	#$49,$f00(a5)		; ciaCRB a = 0 -> b--");
	__asm("		move.b	#$01,$e00(a5)		; ciaCRA e-clk d. 68000");
	__asm("		move.b	#$ff,$400(a5)		; ciaTAL");
	__asm("		move.b	#$ff,$500(a5)		; ciaTAH");
	//__asm("		move.l	(sp)+,a5");
	
}

// returns microseconds passed since calling start_hw_profile()

unsigned int readTimer_c()
{
   unsigned char* cia= (unsigned char*)0xbfd000;
   cia[0xe00]= 0x00;  // ciaCRA stoppe timer a
   cia[0xf00]= 0x00;  // ciaCRA stoppe timer b
   unsigned char d0= cia[0x700];
   unsigned char d1= cia[0x600];
   unsigned char d2= cia[0x500];
   unsigned char d3= cia[0x400];

   unsigned int result= 0x7ffffff - (d0<<24)|(d1<<16)|(d2<<8)|(d3);
   
//   result= result*1000/709;

   return result;
}

unsigned int MODIFIED("d1/d2/d3/a5") readTimer() = "\t"
"   ;//!!! hand-written inline assembly - readTimer \n\t"
"   movem.l	d1-d3/a5,-(sp)       \n\t"
"   lea	   $bfd000,a5           \n\t"
"   moveq	#0,d0                \n\t" // d0= 00.00.00.00
"   moveq	#0,d1                \n\t" // d1= 00.00.00.00
"   moveq	#0,d2                \n\t" // d2= 00.00.00.00
"   moveq	#0,d3                \n\t" // d3= 00.00.00.00

"   move.b	$700(a5),d0          \n\t" // d0= 00.00.00.AA
"   move.b	$600(a5),d1          \n\t" // d1= 00.00.00.BB
"   move.b	$500(a5),d2          \n\t" // d2= 00.00.00.CC
"   move.b	$400(a5),d3          \n\t" // d3= 00.00.00.DD

"   ror.l	#8,d0                \n\t" // d0= AA.00.00.00
"   swap	   d1                   \n\t" // d1= 00.BB.00.00
"   or.l	   d1,d0                \n\t" // d0= AA.BB.00.00
"   lsl	   #8,d2                \n\t" // d2= 00.00.CC.00
"   or.l	   d2,d0                \n\t" // d0= AA.BB.CC.00
"   or.b	   d3,d0                \n\t" // d0= AA.BB.CC.DD

"   neg.l	d0                   \n\t"
"   add.l	#$7ffffff,d0         \n\t" // d0= 0x7ffffff - d0
"   movem.l	(sp)+,d1-d3/a5       \n\t" // return value: d0
;


//--- added 15.10. for profiling when system is still on (init)
//#include <stdio.h>
#include <clib/timer_protos.h>
#include <clib/exec_protos.h>
struct Device* TimerBase;
static struct IORequest timereq;

void initGetMicro()
{
	OpenDevice("timer.device", 0, &timereq, 0);
   TimerBase = timereq.io_Device;
}

void deinitGetMicro()
{
	 CloseDevice(&timereq);
}

/* usage:
  
  getMicro(); // init once

  for(int n = 2000; n--;)
    printf("%i ", n);

  ULONG t = getMicro();

  // 2000 loops ca. 1140 ms = 1 s = 1140000 microseconds
  printf("\n\n %u \n", t); //ms
  */

unsigned int getMicro()
{
	static struct timeval t;
   struct timeval a, b;
 
   GetSysTime(&a);
 
	b = a;
   SubTime(&b, &t);
   t = a;
 
   return b.tv_secs*1000000 + b.tv_micro;
	
	
}


#endif


typedef struct
{
    char*          name;
    int            startFrame;
    unsigned int   startTime;
    int            numFrames;
    unsigned int   time;
    unsigned int   running;
    unsigned int*  frameTime;
} ProfileTimer;

static ProfileTimer* currentTimer= 0;
static ProfileTimer* timers= 0;
static int maxTimers= 0;
static int numTimers= 0;
static int maxFrames= 0;
static int frameNumber= -1;

#ifndef AMIGA
static long long startTime= 0;

long long readTimerWin32()
{
    long long t= 0;

#ifdef _MSC_VER
   #ifdef WIN32
      _asm {
         lea edi,t
         rdtsc
         shrd eax, edx, 12
         mov [edi],eax
         mov [edi+4],edx
      };
   #endif
#endif

    return t;
}

unsigned int readTimer()
{
    unsigned int t= (unsigned int)((readTimerWin32() - startTime) * 709379.0 / 3100000.0 * 100.0);
  
    return (unsigned int)t;
}

void startHardwareTimer()
{
   startTime= readTimerWin32();
}

#endif

void profileInit(int timerCount, int frameCount)
{
    if (timerCount > 0)
    {
       maxTimers= timerCount;
       maxFrames= frameCount;
       timers= (ProfileTimer*)malloc(sizeof(ProfileTimer)*(maxTimers+1));
    }
    frameNumber= -1;

    parts= (int*)malloc( sizeof(int) * maxFrames*2 );
    parts[0]= 0;
    parts[1]= 0;
    partCount= 2;

    startHardwareTimer();
}

void profileDeinit()
{
   if (timers)
   {
      int i=0;
      for (i=0; i<numTimers; i++)
      {
         free(timers[i].name);
         free(timers[i].frameTime);
      }
      free(timers);
   }
   if (parts)
   {
      free(parts);
   }
}

int profileGet(const char* name)
{
    int i;

    // name already exists?
    for (i=0; i<numTimers; i++)
    {
        if ( strcmp(timers[i].name, name) == 0 )
            return i;
    }
    return -1;
}

int profileAdd(const char* name)
{
    ProfileTimer* timer= 0;
    int length;
    int id;

    // no free timers left?
    if (numTimers>=maxTimers)
        return -1;

    // null name?
    if (name==0)
        return -1;

    // name already exists?
    id= profileGet(name);
    if (id>=0)
        return id;

    // create new timer
    id= numTimers++;
    timer= &timers[id];
    length= strlen(name);
    timer->name= malloc(length+1);
    memcpy(timer->name, name, length+1);
    timer->startFrame= -1;
    timer->startTime= 0;
    timer->numFrames= 0;
    timer->time= 0;
    timer->running= 0;
    timer->frameTime= (int*)malloc( sizeof(int) * maxFrames );

    return id;
}


void profileStart(int id)
{
   ProfileTimer* timer= &timers[id];

   timer->startTime= readTimer();
   
   if (timer->startFrame<0)
       timer->startFrame= frameNumber;
   timer->running= 1;

   currentTimer= timer;
}

int profileGetFrame()
{
   return frameNumber;
}

int profileStop(int id)
{
   int delta= 0;
   ProfileTimer* timer= &timers[id];
   if (timer->running==1)
   {
//      startHardwareTimer();
      unsigned int time= readTimer();

      unsigned int start= timer->startTime;
      if (start < time)
         delta= (time - start);
      else
         delta= (start - time);
      timer->time += delta;
//      timer->startTime= time;
      timer->running= 0;
   }

   currentTimer= 0;
   return delta;
}

void profileFake(int id, unsigned int time)
{
   ProfileTimer* timer= &timers[id];
   if (timer->running==1)
   {
      time= (unsigned int)(time * 0.709379);
      timer->time += time;
      timer->running= 0;
   }
}

void profileSwitchToTimer(int id)
{
   ProfileTimer* timer= &timers[id];

   unsigned int time= readTimer();

   if (currentTimer && currentTimer->running==1)
   {
      unsigned int start= currentTimer->startTime;
      if (start < time)
         currentTimer->time += (time - start);
      else
         currentTimer->time += (start - time);
      currentTimer->startTime= time;
      currentTimer->running= 0;
   }

   if (timer->startFrame<0)
       timer->startFrame= frameNumber;
   timer->startTime= time;
   timer->running= 1;

   currentTimer= timer;
}

void profileSetPart(int part, int frame, const char* name)
{
   parts[partCount+0]= (frameNumber<<16) | (part);
   parts[partCount+1]= frame;
   partCount+=2;
}

void profileNextFrame()
{
    int i;
    ProfileTimer* timer;

    unsigned int time= readTimer();
    for (i=0; i<numTimers; i++)
    {
        timer= &timers[i];

        if (timer->numFrames < maxFrames)
            timer->frameTime[timer->numFrames++]= timer->time;
        timer->time= 0;
        if (timer->startFrame<0)
           timer->startFrame= frameNumber;
    }

    // record time axis
    if (frameNumber < maxFrames)
    {
//       timeAxis[frameNumber]= time;
    }

    frameNumber++;
}

static void flush(int f)
{
   int res;
/*
   int i;
   for (i=0; i<bufferPos; i++)
   {
      unsigned char c= buffer[i];
      res= write(f,&c,1);
   }
*/
   res= write(f,&buffer[0],bufferPos);
   bufferPos= 0;
}

static void writeByte(int f, unsigned char b)
{
   buffer[bufferPos]= b;
   bufferPos++;

   if (bufferPos >= BUFFERSIZE)
      flush(f);
}

static void writeInt(int f, int i, int endian)
{
   unsigned char a,b,c,d;
   a= i>>24 & 0xff;
   b= i>>16 & 0xff;
   c= i>>8 & 0xff;
   d= i & 0xff;

   writeByte(f,d);
   writeByte(f,c);
   writeByte(f,b);
   writeByte(f,a);
}

void profileSave(const char* filename)
{
   int i,j;
   int f;
   ProfileTimer* timer;
   unsigned int test=0x01020304;
   unsigned char *data= (unsigned char*)&test;
   unsigned char endian= 0;

   if (data[0]==4 && data[1]==3 && data[2]==2 && data[3]==1) endian=0; // little endian
   if (data[0]==1 && data[1]==2 && data[2]==3 && data[3]==4) endian=1; // big endian

   // printf("endian: %c \n", endian+48);

#ifdef WIN32
   f= open(filename, O_WRONLY|O_CREAT|O_BINARY|O_TRUNC);
#elif __linux
   f= open(
         filename,
         O_WRONLY|O_CREAT|O_TRUNC,
         S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH
      );
#else
   f= open(filename, O_WRONLY|O_CREAT|O_TRUNC);
#endif

   if (f<0)
   {
      // uh.
      printf("cannot write '%s'\n", filename);
      return;
   }

   writeInt(f, numTimers, endian);
   writeInt(f, 0, endian);  // timer rate
   for (i=0; i<numTimers; i++)
   {
      int len;
      timer= &timers[i];
      len= strlen(timer->name);
      for (j=0;j<len+1;j++)
         writeByte(f, timer->name[j]);

      writeInt(f, timer->startFrame, endian);
      writeInt(f, timer->numFrames, endian);
      for (j=0; j<timer->numFrames; j++)
      {
         int micro= (long long)timer->frameTime[j] * 1000 / 709;
         writeInt(f, micro, endian);
      }
   }

   // save time axis
   writeInt(f, partCount, endian);
   for (j=0; j<partCount; j+=2)
   {
      writeInt(f, parts[j], endian);
      writeInt(f, parts[j+1], endian);
      // dummy name
      writeByte(f, 20);
      for (i=0; i<20; i++)
         writeByte(f, 0);
   }

   flush(f);
   close(f);
}

