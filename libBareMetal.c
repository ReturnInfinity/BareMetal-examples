/* =============================================================================
 * BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
 * Copyright (C) 2008-2018 Return Infinity -- see LICENSE.TXT
 *
 * Version 1.0
 * =============================================================================
 * */

#include "libBareMetal.h"

struct container
{
	void *app_host;
	int argc;
	char **argv;
	char **env;
	int (*write)(int fd, const void *buf, unsigned int size, void *app_host);
};

#ifndef NULL
#define NULL ((void *) 0)
#endif

struct container *global_container = NULL;

int main(int argc, char **argv, char **env);

int _start(struct container *container)
{
	if (container == NULL)
		return -1;

	global_container = container;

	return main(container->argc, container->argv, container->env);
}

int write(int fd, const void *buf, unsigned int size)
{
	if (global_container == NULL)
		return -1;
	else if (global_container->write == NULL)
		return -1;

	return global_container->write(fd, buf, size, global_container->app_host);
}

int output(const char *str)
{
	unsigned int str_len = 0;

	for (unsigned int i = 0; str[i] != 0; i++)
		str_len++;

	return write(1, str, str_len);
}
