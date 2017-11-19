/* Looks for PCI devices.
 *
 * TODO : print vendor name, device name, .. etc
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <baremetal/syscalls.h>

typedef unsigned short uint16_t;

struct pci_entry {
	uint8_t bus;
	uint8_t slot;
	uint16_t vendor;
	uint16_t device;
};

int iterate_pci(void *fdata, int (*f)(void *fdata, const struct pci_entry *entry));

uint16_t pciCheckVendor(uint8_t bus, uint8_t slot);

static void print_u8(uint8_t n);

static void print_u16(uint16_t n);

struct pci_vendor
{
	uint16_t id;
	const char name[32];
};

const struct pci_vendor pci_vendor_list[] =
{
	{ 0x8086, "Intel Corporation" }
};

const unsigned int pci_vendor_count = sizeof(pci_vendor_list) / sizeof(pci_vendor_list[0]);

static const char *lookup_vendor(const struct pci_vendor *vendor_list,
                                 unsigned int vendor_count,
                                 uint16_t id);

static int print_pci_entry(void *unused, const struct pci_entry *entry);

int main(void)
{
	iterate_pci(NULL, print_pci_entry);

	return EXIT_SUCCESS;
}

static int print_pci_entry(void *unused, const struct pci_entry *entry)
{
	(void) unused;

	print_u8(entry->bus);
	b_output_chars(":", 1);

	print_u8(entry->slot);
	b_output_chars(":", 1);

	/* TODO : function */
	b_output_chars("x ", 2);

	b_output("(device class): ");

	const char *vendor_name = lookup_vendor(pci_vendor_list, pci_vendor_count, entry->vendor);
	if (vendor_name == NULL)
	{
		b_output("(unknown vendor, id=");
		print_u16(entry->vendor);
		b_output(")");
	}
	else
		b_output(vendor_name);

	b_output_chars("\n", 1);

	return 0;
}

static const char *lookup_vendor(const struct pci_vendor *vendor_list,
                                 unsigned int vendor_count,
                                 uint16_t id)
{

	for (unsigned int i = 0; i < vendor_count; i++)
	{
		if (vendor_list[i].id == id)
			return vendor_list[i].name;
	}

	return NULL;
}

static void print_u8(uint8_t n)
{
	const char hexchars[16] = "0123456789abcdef";
	uint8_t value = n & 0xff;
	b_output_chars(&hexchars[(value >> 4) & 0x0f], 1);
	b_output_chars(&hexchars[(value >> 0) & 0x0f], 1);
}

static void print_u16(uint16_t n)
{
	print_u8((n >> 0x08) & 0xff);
	print_u8((n >> 0x00) & 0xff);
}

int iterate_pci(void *fdata, int (*f)(void *fdata, const struct pci_entry *entry))
{
	struct pci_entry entry;

	for (uint8_t bus = 0; bus < 255; bus++)
	{
		for (uint8_t slot = 0; slot < 255; slot++)
		{
			entry.vendor = b_pci_read_config(bus, slot, 0, 0);
			if (entry.vendor == 0xffff)
				continue;
			entry.bus = bus;
			entry.slot = slot;
			entry.device = b_pci_read_config(bus, slot, 0, 2);
			int err = f(fdata, &entry);
			if (err != 0)
				return err;
		}
	}

	return 0;
}

