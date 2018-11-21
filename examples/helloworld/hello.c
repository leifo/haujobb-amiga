/* hello world, noname, 23.10.18
 
   compile with:
   - "vc hello.c" (compiles to file a.out)
   - or "vc +aos68k hello.c -o hello" (being more explicit about what we want)
   - or "vc +aos68k hello.c -o hello -v" (to see commands as called by vc)
   - or "make" (using makefile)
 */

#include <stdio.h>

int main(int argc, char **argv)
{
	int	i;
	if (argc==1)
	{
		/* no args */
		printf("Hello, world!\n");
		/* argv[0] is always the filename */
		printf("Called from filename: %s\n", argv[0]);
	}else{
		/* arguments given, start at argv[1] */
		printf("Hello");
		for (i=1; i<argc; i++) 
		{
			printf(", %s",argv[i]);
		}
		printf("!\n");
	}
	return 0;
}
