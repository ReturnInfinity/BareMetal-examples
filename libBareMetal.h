/* =============================================================================
 * BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
 * Copyright (C) 2008-2018 Return Infinity -- see LICENSE.TXT
 *
 * Version 1.0
 * =============================================================================
 * */

#ifndef libBareMetal_h
#define libBareMetal_h

#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0
#endif

#ifndef EXIT_FAILURE
#define EXIT_FAILURE 1
#endif

#ifdef __cplusplus
extern "C"
{
#endif

int write(int fd, const void *buf, unsigned int size);

int read(int fd, void *buf, unsigned int size);

int output(const char *str);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* libBareMetal_h */
