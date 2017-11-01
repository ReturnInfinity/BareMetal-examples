/* Print a file in hexidecimal.
 *
 * Written by Taylor Holberton
 *
 * Compile: 'gcc xxd.c -o xxd'
 * */

/* TODO:
 * - When itoa becomes supported (or similar), print
 *   the file offset add the beginning of the (like GNU xxd).
 * - When fwrite() is supported, the program
 *   should write the output to the file specified
 *   by the second argument.
 * - When fgetc(stdin) is supported, read from standard
 *   input when no input file is specified.
 * - Support '-reverse' option, which reverts the program
 *   output back into a normal file.
 * */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

static int xxd(const char *filename);

int main(int argc, const char **argv)
{
	if (argc <= 1) {
		puts("Usage: xxd.app <input>\n");
		return EXIT_FAILURE;
	}

	return xxd(argv[1]);
}

static int xxd(const char *filename)
{
	FILE *file = fopen(filename, "rb");
	if (file == NULL)
		return EXIT_FAILURE;

	char buffer[16];
	char hexchars[] = "0123456789abcdef";
	size_t byte_index = 0;
	size_t column = 1;

	while (!feof(file))
	{
		size_t read_count = fread(buffer, 1, sizeof(buffer), file);
		if (read_count == 0)
			break;

		for (size_t i = 0; i < 16; i++) {

			if (i < read_count) {
				uint8_t byte = buffer[i];
				fwrite(&hexchars[(byte & 0xf0) >> 4], 1, 1, stdout);
				fwrite(&hexchars[(byte & 0x0f) >> 0], 1, 1, stdout);
			} else {
				fwrite("  ", 2, 1, stdout);
			}

			column++;
			byte_index++;
			if ((byte_index % 2) == 0) {
				/* space */
				fwrite(" ", 1, 1, stdout);
				column++;
			}
		}

		/* print extra space */
		fwrite(" ", 1, 1, stdout);

		for (size_t i = 0; i < read_count; i++) {
			char c = buffer[i];
			/* check if character is printable */
			if (((c < 32) && (c != '\t')) || (c >= 127))
				fwrite(".", 1, 1, stdout);
			else
				fwrite(&c, 1, 1, stdout);
		}

		fwrite("\n", 1, 1, stdout);
	}

	fclose(file);

	return EXIT_SUCCESS;
}

