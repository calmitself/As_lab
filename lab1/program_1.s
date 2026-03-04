# №82 - (10А—12В^2)/C^3

.data
promptA: .ascii "A: "
lenA = . - promptA

promptB: .ascii "B: "
lenB = . - promptB

promptC: .ascii "C: "
lenC = . - promptC

newline: .ascii "\n"

.bss
A_buf: .space 32
B_buf: .space 32
C_buf: .space 32
outbuf: .space 32

.text
.global _start

_start:

# Ввод A
mov $1, %rax
mov $1, %rdi
mov $promptA, %rsi   # адрес строки "A: "
mov $lenA, %rdx      # длина строки
syscall

mov $0, %rax
mov $0, %rdi
mov $A_buf, %rsi     # буфер для ввода
mov $32, %rdx        # макс. длина
syscall

mov $A_buf, %rsi
call parse_uint
mov %rax, %r8        # r8 = A

# Ввод B

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
mov %rax, %r9        # r9 = B

# Ввод C
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
mov %rax, %r10       # r10 = C

# Вычисления

# r8 = A
# r9 = B
# r10 = C

# 10A
mov %r8, %rax
mov $10, %rbx
mul %rbx              # rax = 10A
mov %rax, %r11        # r11 = 10A

# 12B^2
mov %r9, %rax
mul %r9               # rax = B^2
mov %rax, %r12       
mov $12, %rbx
mul %rbx              # rax = 12*B^2     
mov %rax, %r12        # r12 = 12*B^2

# числитель = 10A - 12B^2
mov %r11, %rax
sub %r12, %rax
mov %rax, %r13      

# C^3
mov %r10, %rax      # rax = C
mul %r10            # C^2
mul %r10            # C^3 
mov %rax, %r14      # r14 = знаменатель

# деление
mov %r13, %rax      # rax = числитель
xor %rdx, %rdx      # rdx = 0 
div %r14            # (RDX:RAX) / r14 -> (0:RAX) / r14 норм короче

mov %rax, %r15      # r15 = частное
mov %rdx, %r12      # r12 = остаток


# Вывод частного
mov %r15, %rax
mov $outbuf, %rsi
call uint_to_string   # rsi = адрес строки, rdx = длина

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
call uint_to_string    # rsi = адрес строки, rdx = длина

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
    movzbq (%rsi), %rbx
    cmp $'0', %rbx
    jb .done
    cmp $'9', %rbx
    ja .done

    sub $'0', %rbx       # rbx = цифры 0–9
    mov $10, %rdx        # rdx = "*10"
    mul %rdx             # rax *= 10
    add %rbx, %rax       # rax += цифры
    inc %rsi             # следующий симв
    jmp .loop
.done:
    ret

# uint_to_string
# rax = число
# rsi = буфер
# rcx = длина

uint_to_string:
    mov %rsi, %rdi        # rdi = начало буфера
    add $31, %rdi         # rdi = конец буфера
    mov $0, %rcx          # длина = 0

.convert:
    xor %rdx, %rdx
    mov $10, %rbx
    div %rbx              # rax /= 10

    add $'0', %dl
    mov %dl, (%rdi)
    dec %rdi              # сдвиг назад
    inc %rcx              # длина++

    test %rax, %rax
    jnz .convert

    inc %rdi              # rdi указывает на начало строки
    mov %rdi, %rsi        # rsi = адрес строки
    mov %rcx, %rdx        # rdx = длина

    ret

.loop2:
    xor %rdx, %rdx
    mov $10, %rbx
    div %rbx
    add $'0', %dl
    mov %dl, (%rdi)
    dec %rdi
    inc %rcx
    test %rax, %rax
    jnz .loop2

    inc %rdi
    mov %rdi, %rsi
    ret
