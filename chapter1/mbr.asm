;��A20��ַ����
;����gdt������
;��cr0 PE0ģʽ

;mov ax,cs
;mov ss,ax
;mov sp,0x7c00

mov ax,[cs:gdtr+0x7c00+0x02]
mov dx,[cs:gdtr+0x7c00+0x04]

mov bx,0x10

div bx

mov ds,ax	;����ַ
mov bx,dx	;ƫ�Ƶ�ַ

;CPUҪ��ĵ�0λ������
mov dword [bx+0x00],0x00000000
mov dword [bx+0x04],0x00000000

mov dword [bx+0x08],0x7c0001ff	;�����
mov dword [bx+0x0c],0x00409800	;G,D\B,L,AVL G����,0=��ʾ1Byte~1MB 1��ʾ4K��4GB D\BĬ�ϲ�������С 0 1 0 0=4 

mov dword [bx+0x10],0x8000ffff
mov dword [bx+0x14],0x0040920b   ;P DPL S 

mov dword [bx+0x18],0x00007a00
mov dword [bx+0x1c],0x00409600

mov word [cs:gdtr+0x7c00],31

lgdt [cs:gdtr+0x7c00]

;��A20��ַ
in al,0x92
or al,0x02
out 0x92,al

cli
;�򿪱���ģʽ
mov eax,cr0
or eax,1
mov cr0,eax

jmp 0x08:flush

[bits 32]

flush:
mov ax,0x10		;ST TI RPL 3 0 00
mov ds,ax

mov byte [0x00],'P'
mov byte [0x02],'o'
mov byte [0x04],'t'
mov byte [0x06],'e'
mov byte [0x08],'c'
mov byte [0x0a],'t'
mov byte [0x0c],' '
mov byte [0x0e],'m'
mov byte [0x10],'o'
mov byte [0x12],'d'
mov byte [0x14],'e'

hlt

gdtr:
	 dw 0		;16λ����������
	 dd 0x00007e00	;32λ����������ַ
times 510 - ($-$$) db 0
db 0x55,0xaa