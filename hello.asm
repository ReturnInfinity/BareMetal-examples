; asmsyntax=nasm

%include 'libBareMetal.asm'

main:
	mov rdi, message
	call output
	ret

message:
	db "Hello, world!", 10, 0
