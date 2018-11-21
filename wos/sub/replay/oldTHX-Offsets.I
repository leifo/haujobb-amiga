;-------------------T-----------T-----------------T---------T---------------

othxInitCIA          = 0*4       ;now implemented, reference doc file for use!
othxInitPlayer       = 1*4
othxInitModule       = 2*4
othxInitSubSong      = 3*4
othxInterrupt        = 4*4
othxStopSong         = 5*4
othxKillPlayer       = 6*4
othxKillCIA	= 7*4
othxBSS_P            = 8*4       ;pointer to thx's public (fast) memory block
othxBSS_C            = 9*4       ;pointer to thx's explicit chip memory block
othxBSS_Psize        = 10*4      ;size of public memory (intern use only!)
othxBSS_Csize        = 11*4      ;size of chip memory (intern use only!)
othxModule           = 12*4      ;pointer to thxModule after InitModule

othx_pExternalTiming = 0         ;byte, offset to public memory block
othx_pMainVolume     = 1         ;byte, offset to public memory block
othx_pSubsongs       = 2         ;byte, offset to public memory block
othx_pSongEnd        = 3         ;flag, offset to public memory block
othx_pPlaying        = 4         ;flag, offset to public memory block

