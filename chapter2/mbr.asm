app_lba_start equ 2

section mbr align=16 vstart=0x7c00

;��ʼ���ε�ַ
mov ax,[cs:phy_addr]
mov dx,[cs:phy_addr+0x02]

mov bx,0x10

div bx

mov ds,ax
mov es,ax

;��ʼ��ƫ����
xor si,si
xor di,di

;��ȡ����
mov si,app_lba_start
xor bx,bx
call read_hard_disk

mov ax,[0]		;��������С
mov dx,[2]

mov bx,512

div bx

cmp dx,0		;����δ��ȡ��
jnz blow_512b		;�ж�С��512�ֽ�����
dec ax

blow_512b:
cmp ax,0
jz execute

push ds

mov cx,ax	;ax=�� Ҳ���ǻ�ʣ���������û�ж�ȡ

resume_read:
mov ax,ds
add ax,0x20	;�õ���һ��512������ַ
mov ds,ax

xor bx,bx
inc si
call read_hard_disk
loop resume_read

pop ds ;�ָ�ds


execute:	;ִ��
mov ax,[0x06]
mov dx,[0x08]
call calc_segment_base
mov [0x06],ax

mov cx,[0x0a]
mov bx,0x0c

realloc:
mov ax,[bx]
mov dx,[bx+0x02]
call calc_segment_base
mov [bx],ax
add bx,4
loop realloc
jmp far [0x04] 

calc_segment_base:
push dx

add ax,[cs:phy_addr]
adc dx,[cs:phy_addr+0x02]
shr ax,4
ror dx,4
and dx,0xf000
or ax,dx

pop dx

read_hard_disk:
push ax
push bx
push cx
push dx

;��ȡӲ�̿�ʼ,���ö�ȡ������
mov dx,0x01f2
mov al,1
out dx,al

inc dx ;0x01f3~0x01f6

mov ax,si
out dx,al

inc dx ;0x01f4

mov al,0
out dx,al

inc dx ;0x01f5

mov al,0
out dx,al

inc dx ;0x01f6

mov al,0xe0 ;1 1 1 0 0 0 0 0 ��2λ��ʾӲ�̶�ȡģʽ0CHS��1LBA ��0λ��ʾ�Ǹ�Ӳ��0����1����
out dx,al

inc dx ;0x01f7 0λ��ʾ������ 3��ʾ�����Ѿ�׼�����˿��Ժ������������� 7��ʾӲ����æ

mov al,0x20	;��ȡӲ��
out dx,al

.waits:
in al,dx
and al,0x88 ;1 0 0 0 1 0 0 0 ->�ɹ�״̬
cmp al,0x08	;��ȡ�ɹ�
jnz .waits


mov cx,256 ;��ȡ����
mov dx,0x01f0 ;��ʼ��ȡ����

.readw:
in ax,dx
mov [bx],ax
add bx,2
loop .readw

pop dx
pop cx
pop bx
pop ax

ret

phy_addr dd 0x10000

times 510-($-$$) db 0
db 0x55,0xaa