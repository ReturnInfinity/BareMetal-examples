; System Information Program (v1.1 - November 14 2017)
; Written by Ian Seyler
;
; BareMetal compile:
; nasm sysinfo.asm -o sysinfo.app

%include "libBareMetal.asm"

main:					; Start of program label

	lea rdi, [rel startmessage]	; Load RSI with memory address of string
	call output			; Print the string that RSI points to

;Get processor brand string
	xor rax, rax
	lea rdi, [rel tstring]
	mov eax, 0x80000002
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	mov eax, 0x80000003
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	mov eax, 0x80000004
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	xor al, al
	stosb			; Terminate the string
	lea rdi, [rel cpustringmsg]
	call output
	lea rdi, [rel tstring]
check_for_space:		; Remove the leading spaces from the string
	cmp byte [rdi], ' '
	jne print_cpu_string
	add rdi, 1
	jmp check_for_space
print_cpu_string:
	call output

; Number of cores
	lea rdi, [rel numcoresmsg]
	call output
	xor rax, rax
	mov rsi, 0x5012
	lodsw
	lea rdi, [rel tstring]
	call int_to_string
	lea rdi, [rel tstring]
	call output

; Speed 
	lea rdi, [rel speedmsg]
	call output
	xor rax, rax
	mov rsi, 0x5010
	lodsw
	lea rdi, [rel tstring]
	call int_to_string
	lea rdi, [rel tstring]
	call output
	lea rdi, [rel mhzmsg]
	call output

; L1 code/data cache info
	mov eax, 0x80000005	; L1 cache info
	cpuid
	mov eax, edx		; EDX bits 31 - 24 store code L1 cache size in KBs
	shr eax, 24
	lea rdi, [rel tstring]
	call int_to_string
	lea rdi, [rel l1ccachemsg]
	call output
	lea rdi, [rel tstring]
	call output
	lea rdi, [rel kbmsg]
	call output
	mov eax, ecx		; ECX bits 31 - 24 store data L1 cache size in KBs
	shr eax, 24
	lea rdi, [rel tstring]
	call int_to_string
	lea rdi, [rel l1dcachemsg]
	call output
	lea rdi, [rel tstring]
	call output
	lea rdi, [rel kbmsg]
	call output

; L2/L3 cache info
	mov eax, 0x80000006	; L2/L3 cache info
	cpuid
	mov eax, ecx		; ecx bits 31 - 16 store unified L2 cache size in KBs
	shr eax, 16
	lea rdi, [rel tstring]
	call int_to_string
	lea rdi, [rel l2ucachemsg]
	call output
	lea rdi, [rel tstring]
	call output
	lea rdi, [rel kbmsg]
	call output

	mov eax, edx		; edx bits 31 - 18 store unified L3 cache size in 512 KB chunks
	shr eax, 18
	and eax, 0x3FFFF	; Clear bits 18 - 31
	shl eax, 9		; Convert the value for 512 KB chunks to KBs (Multiply by 512)
	lea rdi, [rel tstring]
	call int_to_string
	lea rdi, [rel l3ucachemsg]
	call output
	lea rdi, [rel tstring]
	call output
	lea rdi, [rel kbmsg]
	call output

;CPU features
	lea rdi, [rel cpufeatures]
	call output
	mov rax, 1
	cpuid

checksse:
	test edx, 00000010000000000000000000000000b
	jz checksse2
	lea rdi, [rel sse]
	call output

checksse2:
	test edx, 00000100000000000000000000000000b
	jz checksse3
	lea rdi, [rel sse2]
	call output

checksse3:
	test ecx, 00000000000000000000000000000001b
	jz checkssse3
	lea rdi, [rel sse3]
	call output

checkssse3:
	test ecx, 00000000000000000000001000000000b
	jz checksse41
	lea rdi, [rel ssse3]
	call output

checksse41:
	test ecx, 00000000000010000000000000000000b
	jz checksse42
	lea rdi, [rel sse41]
	call output

checksse42:
	test ecx, 00000000000100000000000000000000b
	jz checkaes
	lea rdi, [rel sse42]
	call output

checkaes:
	test ecx, 00000010000000000000000000000000b
	jz checkavx
	lea rdi, [rel aes]
	call output

checkavx:
	test ecx, 00010000000000000000000000000000b
	jz endit
	lea rdi, [rel avx]
	call output

endit:

;RAM
	lea rdi, [rel memmessage]
	call output
	xor rax, rax
	mov rsi, 0x5020
	lodsw
	lea rdi, [rel tstring]
	call int_to_string
	lea rdi, [rel tstring]
	call output
	lea rdi, [rel mbmsg]
	call output

;Disk
;	To be added

;Fin
	lea rdi, [rel newline]
	call output

ret				; Return to OS

; -----------------------------------------------------------------------------
; int_to_string -- Convert a binary interger into an string
;  IN:	RAX = binary integer
;	RDI = location to store string
; OUT:	RDI = points to end of string
;	All other registers preserved
; Min return value is 0 and max return value is 18446744073709551615 so your
; string needs to be able to store at least 21 characters (20 for the digits
; and 1 for the string terminator).
; Adapted from http://www.cs.usfca.edu/~cruse/cs210s09/rax2uint.s
int_to_string:
	push rdx
	push rcx
	push rbx
	push rax

	mov rbx, 10					; base of the decimal system
	xor ecx, ecx					; number of digits generated
int_to_string_next_divide:
	xor edx, edx					; RAX extended to (RDX,RAX)
	div rbx						; divide by the number-base
	push rdx					; save remainder on the stack
	inc rcx						; and count this remainder
	cmp rax, 0					; was the quotient zero?
	jne int_to_string_next_divide			; no, do another division

int_to_string_next_digit:
	pop rax						; else pop recent remainder
	add al, '0'					; and convert to a numeral
	stosb						; store to memory-buffer
	loop int_to_string_next_digit			; again for other remainders
	xor al, al
	stosb						; Store the null terminator at the end of the string

	pop rax
	pop rbx
	pop rcx
	pop rdx
	ret
; -----------------------------------------------------------------------------


startmessage: db 'System Information:' ; String falls through to newline
newline: db 10, 0
cpustringmsg: db 'CPU String: ', 0
numcoresmsg: db 10, 'Number of cores: ', 0
speedmsg: db 10, 'Detected speed: ', 0
l1ccachemsg: db 10, 'L1 code cache: ', 0
l1dcachemsg: db 10, 'L1 data cache: ', 0
l2ucachemsg: db 10, 'L2 unified cache: ', 0
l3ucachemsg: db 10, 'L3 unified cache: ', 0
cpufeatures: db 10, 'CPU features: ', 0
kbmsg: db ' KiB', 0
mbmsg: db ' MiB', 0
mhzmsg: db ' MHz', 0
sse: db 'SSE ', 0
sse2: db 'SSE2 ', 0
sse3: db 'SSE3 ', 0
ssse3: db 'SSSE3 ', 0
sse41: db 'SSE4.1 ', 0
sse42: db 'SSE4.2 ', 0
aes: db 'AES ', 0
avx: db 'AVX ', 0
memmessage: db 10, 'RAM: ', 0

tstring: times 50 db 0
