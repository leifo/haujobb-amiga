;-------------------T-----------T-----------------T---------T---------------

;variables have moved! be sure to include THIS offsets.i !!!

thxInitCIA          = 0*4
thxInitPlayer       = 1*4
thxInitModule       = 2*4
thxInitSubSong      = 3*4
thxInterrupt        = 4*4
thxStopSong         = 5*4
thxKillPlayer       = 6*4
thxKillCIA	= 7*4
thxNextPattern	= 8*4
thxPrevPattern	= 9*4

;^^^ inserted next/prev-pattern, so bss_p etc. have MOVED!!!

thxBSS_P            = 10*4      ;pointer to thx's public (fast) memory block
thxBSS_C            = 11*4      ;pointer to thx's explicit chip memory block
thxBSS_Psize        = 12*4      ;size of public memory (intern use only!)
thxBSS_Csize        = 13*4      ;size of chip memory (intern use only!)
thxModule           = 14*4      ;pointer to thxModule after InitModule

thx_pExternalTiming = 0         ;byte, offset to public memory block
thx_pMainVolume     = 1         ;byte, offset to public memory block
thx_pSubsongs       = 2         ;byte, offset to public memory block
thx_pSongEnd        = 3         ;flag, offset to public memory block
thx_pPlaying        = 4         ;flag, offset to public memory block
thx_pMultiSpeed	= 6	;word, 0: single 1: double 2: triple 3: quad
thx_pPlayingTime	= 8	;long, playing-time in frames (1/50 secs)
		;divide by ((thx_pMultiSpeed.w+1)*50) to
		;get the seconds!
