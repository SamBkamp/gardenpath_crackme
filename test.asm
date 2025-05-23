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

	mov word [msg+5], 0x7274
	cmp byte [msg+11], 0x2f
	je exit
	xor byte [msg+7], 0x20
	
;print question
	mov eax, 4
	mov ebx, 1
	mov ecx, qu
	mov edx, ql
	int 0x80
	
	sub esp, 16		;make 16 bytes of space on stack
	mov eax, 3		;sys_read	
	mov ebx, 0		;stdin
	lea ecx, [esp]		;stack
	mov edx, 16		;16 bytes to sys_read
	int 0x80

	push eax		;amount of bytes read to the stack
	cmp eax, edx		;check if buffer was not filled
	jl skip_flush
	mov byte [esp+19], 0xa	;set the last byte of the buffer to \n (15th byte + 4 for push)
	
	sub esp, 1		;make 1byte space on stack	
flush_buf:			;empty stdin buffer
	mov eax, 3		;sys_read
	mov ebx, 0		;stdin
	lea ecx, [esp]		;stack
	mov edx, 1		;read 1 byte
	int 0x80
	cmp byte [esp], 0x0a	;compare to \n
	jne flush_buf
	add esp, 1		;remove buffer, realign stack
	
skip_flush:
	cmp dword [esp+4], 0x67414c66
	jne flag
	call pdatamsg
	jmp exit
	
pdatamsg:
	mov eax, 4
	mov ebx, 1
	mov ecx, msg
	mov edx, len
	int 0x80
	ret

flag:
	mov eax, 4
	mov ebx, 1
	push 0xa
	push 0x65706f6e
	lea ecx, [esp]
	mov edx, 5
	int 0x80
	add esp, 5
	
exit:
	mov eax, 1		;1 is code for sys_exit
	mov ebx, 0		;0 is successful exit
	int 0x80		;call2 kernel
	
section .data
	msg db "flag{y5a3_00t}", 0xa
	len equ $ -msg
	qu db "Whats the password?: "
	ql equ $-qu
