app_lba_start equ 2

section mbr align=16 vstart=0x7c00

;初始化段地址
mov ax,[cs:phy_addr]
mov dx,[cs:phy_addr+0x02]

mov bx,0x10

div bx

mov ds,ax
mov es,ax

;初始化偏移量
xor si,si
xor di,di

;读取磁盘
mov si,app_lba_start
xor bx,bx
call read_hard_disk

mov ax,[0]		;计算程序大小
mov dx,[2]

mov bx,512

div bx

cmp dx,0		;程序未读取完
jnz blow_512b		;判断小于512字节问题
dec ax

blow_512b:
cmp ax,0
jz execute

push ds

mov cx,ax	;ax=商 也就是还剩余多少扇区没有读取

resume_read:
mov ax,ds
add ax,0x20	;得到下一个512扇区地址
mov ds,ax

xor bx,bx
inc si
call read_hard_disk
loop resume_read

pop ds ;恢复ds


execute:	;执行
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

;读取硬盘开始,设置读取扇区数
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

mov al,0xe0 ;1 1 1 0 0 0 0 0 高2位表示硬盘读取模式0CHS，1LBA 高0位表示那个硬盘0主盘1从盘
out dx,al

inc dx ;0x01f7 0位表示错误码 3表示数据已经准备好了可以和主机交换数据 7表示硬盘在忙

mov al,0x20	;读取硬盘
out dx,al

.waits:
in al,dx
and al,0x88 ;1 0 0 0 1 0 0 0 ->成功状态
cmp al,0x08	;读取成功
jnz .waits


mov cx,256 ;读取次数
mov dx,0x01f0 ;开始读取数据

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