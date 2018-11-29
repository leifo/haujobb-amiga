#ifndef ADPCM_H
#define ADPCM_H

int adpcmLoad(const char* wavfilename, unsigned char** outLeft, unsigned char** outRight, int* outRate);

#endif // ADPCM_H
