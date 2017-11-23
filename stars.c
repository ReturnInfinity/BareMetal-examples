/* Simple graphics test */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void putpixel(int x, int y, char red, char green, char blue);

unsigned char *frame_buffer;
uint16_t x_res, y_res;
uint8_t depth;

int main(void)
{
	// Gather video memory address, x & y resoultion, and BPP 
	frame_buffer = (unsigned char *)((uint64_t)(*(uint32_t *)(0x5080)));
	x_res = *(uint16_t *)(0x5084);
	y_res = *(uint16_t *)(0x5086);
	depth = *(uint8_t *)(0x5088);

	// Draw a diagonal line from the top left corner (0,0)
	int t;
	for (t=0; t<700; t++)
		putpixel(t, t, 0xFF, 0xFF, 0xFF);
}

void putpixel(int x, int y, char red, char green, char blue)
{
	int offset = ((y * x_res) + x) * (depth / 8);
	frame_buffer[offset+0] = blue;
	frame_buffer[offset+1] = green;
	frame_buffer[offset+2] = red;
}
