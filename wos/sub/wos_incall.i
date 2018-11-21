	incdir	includes:

	WOSINCLUDE	includes/lvo.i

	include	exec/memory.i

	include "exec/types.i"
	include "exec/nodes.i"
	include "exec/ports.i"
	include "exec/lists.i"
	include "devices/input.i"
	include "devices/inputevent.i"
	include "graphics/gfxbase.i"
	include "dos/dosextens.i"


	ifd	ISREADY
		ifd	DK3D
			WOSINCLUDE	sub/dk3d/wos_dk3d_v1.32.i
		endc

		ifd	PROFILER
		ifd	WOSASSIGN
			include		wos:sub/misc/_pr_profiler.x
		else
			include		sub/misc/_pr_profiler.x
		endc
		endc

	endc
	
	ifd	WOSASSIGN
		include	wos:sub/wos_macros.i
	else
		include	sub/wos_macros.i
	endc
	
	ifd	WOSASSIGN
		include	wos:sub/wos_defines.i
	else
		include	sub/wos_defines.i
	endc

