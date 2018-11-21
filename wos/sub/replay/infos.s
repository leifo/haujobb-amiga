*----------------------------- ASM-One only ----*
        ifd	asmone

        ifd     makebin
        printt  ""
        printt  "Binary AUTO-save mode enabled !!!"
        else
        ifne    example
        printt  ""
        printt  "Example-Mode enabled !!!"
        endc
        endc
        
        printt  ""
        printt  "Player 6.104 Options used:"
        printt  "--------------------------"
        ifd     start
        printt  "Starting from position"
        printv  start
        endc
        ifne    fade
        printt  "Mastervolume on"
        else
        printt  "Mastervolume off"
        endc
        ifne    system
        printt  "System friendly"
        else
        printt  "System killer"
        endc
        ifne    CIA
        printt  "CIA-tempo on"
        else
        printt  "CIA-tempo off"
        endc
        ifne    exec
        printt  "ExecBase valid"
        else
        printt  "ExecBase invalid"
        endc
        ifne    lev6
        printt  "Level 6 IRQ on"
        else
        printt  "Non-lev6 NOT IMPLEMENTED!"
        if2
        fail
        endc
        endc
        ifne    opt020
        printt  "MC68020 optimizations"
        else
        printt  "Normal MC68000 code"
        endc
        printt  "Channels:"
        printv  channels
        ifgt    channels-4
        printt  "NO MORE THAN 4 CHANNELS!"
        if2
        fail
        endc
        endc
        ifeq    channels
        printt  "MUST HAVE AT LEAST 1 CHANNEL!"
        if2
        fail
        endc
        endc

        printt  "UseCode:"
        printv  use

	printt	""
	printt	"Size of Player (full-featured size is 6706 bytes):"
	printv	P61_etu-P61_motuuli
	printt	"Bytes gained:"
	printv	6706-(P61_etu-P61_motuuli)
	printt	""
        endc
*-----------------------------------------------*
