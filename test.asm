section .text
global _start:
holy:
	push 0x0a736579		;"yes\n"
	mov eax, 4		;sys_write
	mov ebx, 1		;stdout
	lea ecx, [esp]
	mov edx, 4
	int 0x80

	mov eax, 1		;sys_exit
	mov ebx, 1
	int 0x80
	
_start:
	push 0x00000a3a		;"solve my crackme"
	push 0x656D6B63
	push 0x61726320
	push 0x796D2065
	push 0x766C6F53
	mov eax, 4		;4 is code for sys_write
	mov ebx, 1		;fd 1 is stdout
	mov ecx, esp		;get address of top of stack (lowest address)
	mov edx, 18		;the length of said message
	int 0x80		;call kernel
		
	
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
	cmp eax, edx		;check if buffer was not filled (does edx always get preseved after syscall?)
	jl post_flush
	mov byte [esp+19], 0xa	;set the last byte of the buffer to \n (15th byte + 4 for push)
	
	sub esp, 1		;make 1byte space on stack for flush_buf
	call flush_buf
	
post_flush:
	cmp dword [esp+4], 0x67414c66 ;fLAg
	jne wrong_flag
	movzx eax, byte [esp+9]
	xor eax, 0xc5		;this needs to result in 0xa4 (0xc5 ^ 0xa4 = 0x61 'a')
	mov ebx, $
	sub ebx, eax		;current  offset from start of binary is 0xa4
	jmp ebx			;WARNING: offset from start of binary will change should earlier lines be added or deleted
	jmp exit
	
flush_buf:
	mov eax, 3		;sys_read
	mov ebx, 0		;stdin
	lea ecx, [esp]		;stack
	mov edx, 1		;read 1 byte
	int 0x80
	cmp byte [esp], 0x0a	;compare to \n
	jne flush_buf
	add esp, 1		;remove buffer, realign stack
	ret
	
wrong_flag:
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
