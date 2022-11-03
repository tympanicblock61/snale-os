[org 0x7e00]

jmp EnterProtectedMode

jmp $

%include "GDT.asm"
%include "Print.asm"

EnterProtectedMode:
	call EnableA20
	cli
	lgdt [gdt_descriptor]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp codeseq:StartProtectedMode

EnableA20:
	in al, 0x92
	or al, 2
	out 0x92, al
	ret

[bits 32]

%include "CPUID.asm"
%include "SimplePaging.asm"

StartProtectedMode:
	
	mov ax, dataseq
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax


	call DetectCPUID
	call DetectLongMode
	call SetupIdentityPaging
	call EditGDT
	jmp codeseq:Start64Bit

[bits 64]

Start64Bit:
	mov edi, 0xb8000
	mov rax, 0x1f201f201f201f20
	mov ecx, 500
	rep stosq
	jmp $

times 2048-($-$$) db 0