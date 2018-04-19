; =============================================================================
; BareMetal -- a 64-bit OS written in Assembly for x86-64 systems
; Copyright (C) 2008-2018 Return Infinity -- see LICENSE.TXT
;
; Version 1.0
; =============================================================================

; Let nasm know that this is a 64-bit program.
BITS 64

; This is where Alloy loads applications.
ORG 0xFFFF800000000000

; Passed to the read function to indicate
; that the caller requests to read from the
; terminal input (or a redirected input file.)
STDIN equ 0

; Passed to the write function to indicate
; that the caller requests to write to the
; terminal output (or a directed output file.)
STDOUT equ 1

; Passed to the write function to indicate
; that the caller requests to write to the
; terminal error output (or a directed error file.)
STDERR equ 2

; _start is the function at the beginning
; of the binary, therefore the function that
; is called by alloy. A pointer to the app
; container is in RDI.
_start:
	; Check that a null pointer wasn't
	; passed by Alloy.
	cmp rdi, 0
	je .fail
	; Preserve registers
	push rdi
	push rsi
	push rdx
	; Assign the app host
	mov rsi, [rdi]
	mov [rel app_host], rsi
	add rdi, 8
	; Assign the argument count
	mov esi, [rdi]
	mov dword [rel argc], esi
	add rdi, 8
	; Assign the arguments pointer
	mov rsi, [rdi]
	mov qword [rel argv], rsi
	add rdi, 8
	; Assign the environment variables
	mov rsi, [rdi]
	mov qword [rel env], rsi
	add rdi, 8
	; Assign write callback
	mov rsi, [rdi]
	mov qword [rel write_callback], rsi
	add rdi, 8
	; Assign the read callback
	mov rsi, [rdi]
	mov qword [rel read_callback], rsi
	add rdi, 8
	; Assign the open callback
	mov rsi, [rdi]
	mov qword [rel open_callback], rsi
	add rdi, 8
	; Assign the close callback
	mov rsi, [rdi]
	mov qword [rel close_callback], rsi
	add rdi, 8
	; Assign the malloc callback
	mov rsi, [rdi]
	mov qword [rel malloc_callback], rsi
	add rdi, 8
	; Assign the realloc callback
	mov rsi, [rdi]
	mov qword [rel realloc_callback], rsi
	add rdi, 8
	; Assign the free callback
	mov rsi, [rdi]
	mov qword [rel free_callback], rsi
	add rdi, 8
	; Set the parameters for 'main'
	xor rdi, rdi
	mov edi, argc
	mov rsi, argv
	mov rdx, env
	; Call the main entry point.
	call main
	; Return to Alloy
	pop rdx
	pop rsi
	pop rdi
	ret
.fail:
	pop rdx
	pop rsi
	pop rdi
	mov rax, 1
	ret

; The number of arguments passed to the program.
; This does not include the null-terminating pointer
; in the argument array.
argc:
	dw 0

; A pointer to the null-terminated argument strings.
; The last string pointer is set to zero.
argv:
	dq 0

; A pointer to the environment variables.
; Currently, this is set to zero.
env:
	dq 0

; A pointer to the application host. In Alloy, this
; pointer connects the application to the terminal and
; the kernel.
app_host:
	dq 0

; Writes memory to a file descriptor.
;
; Inputs:
;   RDI - The file descriptor to write the data to.
;   RSI - The address of the data to write.
;   RDX - The number of bytes to write to the file.
; Outputs:
;   RAX - The number of bytes written on success, a negative one on failure.
write:
	; Ensure write pointer isn't NULL
	cmp qword [rel write_callback], 0
	je .fail
	; Ensure the app data pointer isn't NULL
	cmp qword [rel app_host], 0
	je .fail
	; Assign the 'app_host' argument.
	mov rcx, [rel app_host]
	call [rel write_callback]
	ret
.fail:
	mov rax, -1
	ret

; Writes memory to the standard output.
;
; Inputs:
;   RDI - The message to print.
; Outputs:
;   RAX - The number of bytes written on success, a negative one on failure.
output:
	xor rdx, rdi
.strlen:
	cmp byte [rdx], 0
	je .strlen_done
	inc rdx
	jmp .strlen
.strlen_done:
	sub rdx, rdi
	mov rsi, rdi
	mov rdi, STDOUT
	call write
	ret

; Reads memory from a file.
;
; Inputs:
;   RDI - The file descriptor to read from.
;   RSI - The buffer to put the data into.
;   RDX - The number of bytes to read.
; Outputs:
;   RAX - The number of bytes read from the file.
read:
	; Ensure read pointer isn't NULL
	cmp qword [rel read_callback], 0
	je .fail
	; Ensure that the app host pointer isn't NULL
	cmp qword [rel app_host], 0
	je .fail
	; Assign the 'app_host' argument and call the function.
	mov rcx, [rel app_host]
	call [rel read_callback]
	ret
.fail:
	mov rax, -1
	ret

; Allocates memory on the programs heap.
;
; Inputs:
;   RDI - The number of bytes to allocate.
; Outputs:
;   RAX - The address of the memory region on success, zero on failure.
malloc:
	; Ensure that the 'malloc' pointer isn't NULL
	cmp qword [rel malloc_callback], 0
	je .fail
	; Ensure that the 'app_host' pointer isn't NULL
	cmp qword [rel app_host], 0
	je .fail
	; Call the function
	mov rsi, [rel app_host]
	call [rel malloc_callback]
	ret
.fail:
	xor rax, rax
	ret

; Resizes an existing memory region.
; May also be used to allocate memory if the
; input address is set to zero.
;
; Inputs:
;   RDI - The existing address to resize.
;   RSI - The number of bytes to resize the region to.
; Outputs:
;   RAX - The address of the new memory region.
realloc:
	; Ensure that the 'realloc' pointer isn't NULL
	cmp qword [rel realloc_callback], 0
	je .fail
	; Ensure that the 'app_host' pointer isn't NULL
	cmp qword [rel app_host], 0
	je .fail
	; Call the function
	mov rdx, [rel app_host]
	call [rel realloc_callback]
	ret
.fail:
	xor rax, rax
	ret

; Releases memory that was previously allocated.
; This function also accepts a memory address of
; zero, in which case it does nothing.
;
; Inputs
;   RDI - The address of the memory to free.
free:
	; Ensure that the 'realloc' pointer isn't NULL
	cmp qword [rel realloc_callback], 0
	je .fail
	; Ensure that the 'app_host' pointer isn't NULL
	cmp qword [rel app_host], 0
	je .fail
	; Call the function
	mov rsi, [rel app_host]
	call [rel realloc_callback]
	ret
.fail:
	ret

; Opens a file.
;
; Inputs:
;   RDI - A null-terminated path of the file to read.
;   RSI - The mode to open the file in.
; Outputs:
;   RAX - On success, the file descriptor of the opened
;         file. On failure, a negative one is returned.
open:
	; Not implemented.
	mov rax, -1
	ret

; Closes an open file.
;
; Inputs:
;   RDI - The file descriptor to close.
; Outputs:
;   RAX - Zero on success, a negative one on failure.
close:
	; Not implemented.
	mov rax, -1
	ret

write_callback:
	dq 0

read_callback:
	dq 0

open_callback:
	dq 0

close_callback:
	dq 0

malloc_callback:
	dq 0

realloc_callback:
	dq 0

free_callback:
	dq 0

; The following definitions are part of
; the first API. Since the new API isn't
; finished yet, this functions can still
; be used. The only exception is b_output,
; which still outputs to serial.

b_input          equ 0x0000000000100010 ; Scans keyboard for input. OUT: AL = 0 if no key pressed, otherwise ASCII code
b_output         equ 0x0000000000100018 ; Displays a number of characters. IN: RSI = message location, RCX = number of characters

b_smp_set        equ 0x0000000000100020 ; Set a CPU to run code. IN: RAX = Code address, RDX = Data address, RCX = CPU ID
b_smp_config     equ 0x0000000000100028 ; Stub

b_mem_allocate   equ 0x0000000000100030 ; Allocates the requested number of 2 MiB pages. IN: RCX = Number of pages to allocate. OUT: RAX = Starting address, RCX = Number of pages allocated (Set to the value asked for or 0 on failure)
b_mem_release    equ 0x0000000000100038 ; Frees the requested number of 2 MiB pages. IN: RAX = Starting address, RCX = Number of pages to free. OUT: RCX = Number of pages freed

b_ethernet_tx    equ 0x0000000000100040 ; Transmit a packet via Ethernet. IN: RSI = Memory location where data is stored, RDI = Pointer to 48 bit destination address, BX = Type of packet (If set to 0 then the EtherType will be set to the length of data), CX = Length of data
b_ethernet_rx    equ 0x0000000000100048 ; Polls the Ethernet card for received data. IN: RDI = Memory location where packet will be stored. OUT: RCX = Length of packet

b_disk_read      equ 0x0000000000100050 ; Read from the disk.
b_disk_write     equ 0x0000000000100058 ; Write to the disk.

b_system_config  equ 0x0000000000100060 ; View/modify system configuration. IN: RDX = Function #, RAX = Variable. OUT: RAX = Result
b_system_misc    equ 0x0000000000100068 ; Call a misc system function. IN: RDX = Function #, RAX = Variable 1, RCX = Variable 2. Out: RAX = Result 1, RCX = Result 2


; Index for b_system_config calls
timecounter          equ 0
config_argc          equ 1
config_argv          equ 2
networkcallback_get  equ 3
networkcallback_set  equ 4
clockcallback_get    equ 5
clockcallback_set    equ 6


; Index for b_system_misc calls
smp_get_id      equ 1
smp_lock        equ 2
smp_unlock      equ 3
debug_dump_mem  equ 4
debug_dump_rax  equ 5
get_argc        equ 6
get_argv        equ 7

; =============================================================================
; EOF
