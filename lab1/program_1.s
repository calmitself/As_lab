# №82 - (10А—12В^2)/C^3

.data
promptA: .ascii "A: "
lenA = . - promptA      #lenA = адрес после строки – адрес начала строки

promptB: .ascii "B: "
lenB = . - promptB

promptC: .ascii "C: "
lenC = . - promptC

newline: .ascii "\n"

.bss
A_buf: .space 32        #выделяет нужное кол-во байт нулями (32)
B_buf: .space 32
C_buf: .space 32
outbuf: .space 32

.text
.global _start

_start:

#Ввод A
mov $1, %rax        #вывод
mov $1, %rdi        #на консоль
mov $promptA, %rsi  #то, что в promptA
mov $lenA, %rdx     #длиною в lenA
syscall            

mov $0, %rax        #чтение
mov $0, %rdi        #введеннного
mov $A_buf, %rsi    #записать в A_buf
mov $32, %rdx       #сколько байт читать (32)
syscall

mov $A_buf, %rsi    #из A_buf в rsi
call parse_uint     #строку в число
mov %rax, %r8       #из rax в r8                        (r8 = A)

#Ввод B
mov $1, %rax
mov $1, %rdi
mov $promptB, %rsi
mov $lenB, %rdx
syscall

mov $0, %rax
mov $0, %rdi
mov $B_buf, %rsi
mov $32, %rdx
syscall

mov $B_buf, %rsi
call parse_uint
mov %rax, %r9                                           # r9 = B

#Ввод C
mov $1, %rax
mov $1, %rdi
mov $promptC, %rsi
mov $lenC, %rdx
syscall

mov $0, %rax
mov $0, %rdi
mov $C_buf, %rsi
mov $32, %rdx
syscall

mov $C_buf, %rsi
call parse_uint
mov %rax, %r10                                          # r10 = C

#Вычисления
# r8 = A
# r9 = B
# r10 = C

# 10A
mov %r8, %rax
mov $10, %rbx
mul %rbx              #rax * rbx, rax = 10A
mov %rax, %r11                                          # r11 = 10A

# 2B^2
mov %r9, %rax
mul %r9               #rax = B^2     
mov $12, %rbx
mul %rbx              #rax = 12*B^2     
mov %rax, %r12                                          # r12 = 12*B^2

#числитель = 10A - 12B^2
mov %r11, %r13
sub %r12, %r13                                          # r13 = числитель

# C^3
mov %r10, %rax        #rax = C
mul %r10              # C^2
mul %r10              # C^3 
mov %rax, %r14                                          #r14 = знаменатель

#деление
mov %r13, %rax        #rax = числитель
xor %rdx, %rdx        #(XOR = Exclusive OR, 1 xor 1 = 0)  rdx = 0 
div %r14              #(rdx_rax) / r14 -> (0_rax) / r14 норм короче

mov %rax, %r15                                          # r15 = частное
mov %rdx, %r12                                          # r12 = остаток


# Вывод частного
mov %r15, %rax
mov $outbuf, %rsi
call uint_to_string   #аргументы 2 и 3 (что выводить и длина) уже лежат в регистрах rsi, rdx

mov $1, %rax
mov $1, %rdi
syscall

# перевод строки
mov $1, %rax
mov $1, %rdi
mov $newline, %rsi
mov $1, %rdx
syscall

# Вывод остатка
mov %r12, %rax
mov $outbuf, %rsi
call uint_to_string  

mov $1, %rax
mov $1, %rdi
syscall


# перевод строки
mov $1, %rax
mov $1, %rdi
mov $newline, %rsi
mov $1, %rdx
syscall

# выход
mov $60, %rax
xor %rdi, %rdi
syscall

# parse_uint
parse_uint:
    xor %rax, %rax
.loop:
    movzbq (%rsi), %rbx     #Move Zero-extend Byte to Quadword для арифметических операций
    cmp $'0', %rbx          #Проверка цифра ли (rbx -0)
    jb .done                #jump below (если rbx < 0, Carry Flag = 1)
    cmp $'9', %rbx          #rbx -9
    ja .done                #jump above (если rbx > 9, Carry Flag = 0 и Zero Flag = 0)

    sub $'0', %rbx          #rbx = rbx - ASCII('0') -> "5" = 0x35 - 0x30 = 0x05
    mov $10, %rdx           
    mul %rdx             
    add %rbx, %rax          #rax = rax + rbx
    inc %rsi                #rsi++
    jmp .loop
.done:
    ret

#rax = выводимое число
#rsi = адрес буфера
#rcx = длина (указатель)

uint_to_string:
    mov %rsi, %rdi        #rdi = указатель на начало буфера
    add $31, %rdi         #rdi = указатель на конец буфера
    mov $0, %rcx          #длина = 0

.convert:
    xor %rdx, %rdx
    mov $10, %rbx
    div %rbx              #rax /= 10

    add $'0', %dl         # dl - младший байт rdx (RDX -> EDX -> DX -> DL)
    mov %dl, (%rdi)       #запись числа в outbuf (*rdi = dl)
    dec %rdi              #rdi--
    inc %rcx              #длина++

    test %rax, %rax       #rax AND rax (rax == 0 -> ZF = 1, rax != 0 -> ZF = 0 )
    jnz .convert

    inc %rdi              #rdi указывает на начало строки
    mov %rdi, %rsi        #rsi = адрес строки
    mov %rcx, %rdx        #rdx = длина строки

    ret
