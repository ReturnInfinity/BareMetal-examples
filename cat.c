/* Concatenate files and print to standard output.
 * Written by Taylor Holberton
 *
 * Compile: 'gcc cat.c -o cat'
 * */

#include <stdio.h>
#include <stdlib.h>

static int cat(const char *filename);

int main(int argc, const char **argv)
{
	for (int i = 1; i < argc; i++) {
		cat(argv[i]);
	}
	return EXIT_SUCCESS;
}

static int cat(const char *filename)
{
	FILE *file = fopen(filename, "rb");
	if (file == NULL)
		return EXIT_FAILURE;

	char buffer[512];
	while (!feof(file))
	{
		size_t read_count = fread(buffer, 1, sizeof(buffer), file);
		fwrite(buffer, 1, read_count, stdout);
	}

	fclose(file);

	return EXIT_SUCCESS;
}

