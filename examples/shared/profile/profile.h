#ifndef PROFILE_H
#define PROFILE_H

// the define is highlighted in the source and supports readability
#define PROFILESTART(x) profileStart(x);
#define PROFILESTOP(x) profileStop(x);

/*
usage:

profileInit(maxTimers, maxFrames);

int myTimer= profileAdd("myTimer");

while (...)
{
   profileNextFrame();

   profileStart(myTimer);
   myFunction(...);
   profileStop(myTimer);
}

profileSave("myProfile.dat");
*/

#ifdef AMIGA
//void start_hw_profile();
__regsused("a5") void start_hw_profile();

//__reg("d0") unsigned int end_hw_profile();
__regsused("d0/d1/d2/d3/a5") __reg("d0") unsigned int end_hw_profile();

//__reg("d0") unsigned int readTimer();
unsigned int __regsused("d0/d1/d2/d3/a5") readTimer();

void initGetMicro();
void deinitGetMicro();
unsigned int getAmiMicro();
#endif



void profileInit(int maxTimers, int maxFrames);
void profileDeinit();

void profileNextFrame();
int profileGetFrame();
void profileSetPart(int part, int frame, const char* name);

int profileAdd(const char* name);
int profileGet(const char* name);
void profileStart(int id);
int profileStop(int id);
void profileFake(int id, unsigned int time);

void profileSave(const char* filename);

// unsigned int readTimer();

#endif // PROFILE_H

