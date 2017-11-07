/* Looks for PCI devices.
 *
 * TODO : print vendor name, device name, .. etc
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef unsigned short uint16_t;

uint16_t pciCheckVendor(uint8_t bus, uint8_t slot);

int main(void)
{
	puts("scanning...");
	// scan for PCI devices using the
	// brute force method
	for (uint8_t bus = 0; bus < 255; bus++)
	{
		for (uint8_t slot = 0; slot < 255; slot++)
		{
			uint16_t vendor = pciCheckVendor(bus, slot);
			if (vendor == 0xffff)
				break;
		}
	}
	puts("done.");

	return EXIT_SUCCESS;
}

static void sysOut32(uint32_t port, uint32_t data)
{
	asm volatile("outl %0, %w1" : : "a" (data), "Nd" (port));
}

static uint32_t sysIn32(uint32_t port)
{
	uint32_t data;
	asm volatile("inl %w1, %0" : "=a" (data) : "Nd" (port));
	return data;
}

 uint16_t pciConfigReadWord(uint8_t bus, uint8_t slot,
                            uint8_t func, uint8_t offset)
{
	uint32_t address;
	uint32_t lbus  = (uint32_t)bus;
	uint32_t lslot = (uint32_t)slot;
	uint32_t lfunc = (uint32_t)func;
	uint16_t tmp = 0;
 
	// create configuration address
	address = (uint32_t)((lbus << 16) | (lslot << 11) |
	          (lfunc << 8) | (offset & 0xfc) | ((uint32_t)0x80000000));
 
	// write out the address
	sysOut32 (0xCF8, address);
	// read in the data
	// (offset & 2) * 8) = 0 will choose the first word of the 32 bits register
	tmp = (uint16_t)((sysIn32 (0xCFC) >> ((offset & 2) * 8)) & 0xffff);

	return tmp;
}

 uint16_t pciCheckVendor(uint8_t bus, uint8_t slot)
{
	uint16_t vendor, device;
	if ((vendor = pciConfigReadWord(bus, slot, 0, 0)) != 0xffff) {
		// found a device
		device = pciConfigReadWord(bus, slot, 0, 2);
		(void) device;
		puts("Found a device!");
	}
	return vendor;
}

