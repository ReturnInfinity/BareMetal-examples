/* A 'Hello, world' example for C.
 * Written by Taylor Holberton
 *
 * Compile: 'gcc hello-c.c -o hello-c'
 * */

#include "libBareMetal.h"

int main(int argc, const char **argv)
{
	for (int i = 1; i < argc; i++)
	{
		output("arg -- ");
		output(argv[i]);
		output("\n");
	}

	return EXIT_SUCCESS;
}

