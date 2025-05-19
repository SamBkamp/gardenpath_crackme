section .text
global _start:
_start:
	push 0x00000a3a
	push 0x656D6B63
	push 0x61726320
	push 0x796D2065
	push 0x766C6F53
	mov eax, 4		;4 is code for sys_write
	mov ebx, 1		;fd 1 is stdout
	mov ecx, esp		;get address of top of stack (lowest address)
	mov edx, 18		;the length of said message
	int 0x80		;call kernel

	call pdatamsg
	mov word [msg+5], 0x7274
	cmp byte [msg+11], 0x2f
	je print_flag
	xor byte [msg+7], 0x20
	call pdatamsg

	mov eax, 3		;sys_read
	mov ebx, 0		;fd 0 is stdin
	push 0x00000000
	push 0x00000000
	lea ecx, [esp]
	mov edx, 7
	int 0x80

	sub esp, 1		;allocate space on the stack for our flush
	
clear_buf:			;to flush stdin buffer
	mov eax, 3		;read opcode
	mov ebx, 0		;stdin
	lea ecx, [esp]		;bottom of the stack
	mov edx, 1		;read 1 byte at a time
	int 0x80		;syscall
	cmp byte [esp], 0xa	;check if byte read was \n
	jne clear_buf		;if no, reread stdin

	add esp, 1		;realign stack
	
	
	mov byte [esp+7], 0x0a
	mov eax, 4		;4 is code for sys_write
	mov ebx, 1		;fd 1 is stdout
	mov ecx, esp		;get address of top of stack (lowest address)
	mov edx, 8		;the length of said message
	int 0x80		;call kernel
	add esp, 8
	
	call print_flag
	
pdatamsg:
	mov eax, 4
	mov ebx, 1
	mov ecx, msg
	mov edx, len
	int 0x80
	ret
	
print_flag:
	mov eax, 1		;1 is code for sys_exit
	mov ebx, 0		;0 is successful exit
	int 0x80		;call kernel
	
section .data
	msg db "flag{y5a3_00t}", 0xa
	len equ $ -msg
