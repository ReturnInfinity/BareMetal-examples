// gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -o ethtoolc.o ethtoolc.c
// gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -o libBareMetal.o libBareMetal.c
// ld -T app.ld -o ethtoolc.app ethtoolc.o libBareMetal.o

#include <baremetal/syscalls.h>

#include <string.h>

void ethtool_send();
void ethtool_receive();

int main(void)
{
	int running = 1;
	char key;

	b_output("EthTool: S to send a packet, Q to quit.\nReceived packets will display automatically.\n");
	// Configure the network callback

	b_system_config(NETWORKCALLBACK_SET, (unsigned long int)ethtool_receive);

	while (running == 1)
	{
		key = b_input_key();
		if (key == 's')
		{
			ethtool_send();
		}
		else if (key == 'q')
		{
			running = 0;
		}
	}

	b_output("\n");
	// Clear the network callback
	b_system_config(NETWORKCALLBACK_SET, 0);

	return 0;
}

void ethtool_send()
{
	char packet[64];
	memset(packet, 0, sizeof(packet));
	strcpy(packet, "Hello, world!");
	b_output("\nSending packet, ");
	b_ethernet_tx(packet, sizeof(packet), 0);
	b_output("Sent!");
}

void ethtool_receive()
{
	char packet[128];
	b_output("\nReceived packet\n");
	int len = b_ethernet_rx(packet, 0);
	(void) len;
}
