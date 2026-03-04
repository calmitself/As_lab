#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 1cm),
  numbering: none,
  footer: context {
    let p = counter(page).get().first()
    if p > 1 {
      align(center)[#p]
    }
  }
)

#set text(
  lang: "ru",
  font: "Times New Roman",
  size: 12pt
)

//Рамка для блока с кодом
#show raw: block.with(
  fill: luma(245),
  inset: 10pt,
  radius: 5pt,
  stroke: luma(200),
)

//Для таблиц - подпись сверху
#show figure.where(kind: table): set figure.caption(position: top)

#align(center)[
  #upper[ГУАП]
  #v(0.5cm)
  #upper[КАФЕДРА № 14]
  #v(2cm)
]

#grid(
  columns: (2fr),
  align(left)[
    #upper[ОТЧЕТ]\
    #upper[ЗАЩИЩЕН С ОЦЕНКОЙ]\
    #upper[]\
    #upper[ПРЕПОДАВАТЕЛЬ]
  ],
  align(center)[
    #v(0.5cm)
    #grid(
      columns: (2fr, 1fr, 2fr),
      gutter: 0.3em,
      [Старший преподаватель],
      [05.03.2026],
      [Н.И. Синёв],
      line(length: 100%),
      line(length: 100%),
      line(length: 100%),
      [должность, уч. степень, звание],
      [подпись, дата],
      [инициалы, фамилия]
    )
  ]
)

#align(center)[
  #v(2cm)
  #upper[ОТЧЕТ О ЛАБОРАТОРНОЙ РАБОТЕ]
  #v(0.8cm)
  #text[Вычисление для беззнаковых целых чисел]
  #v(0.8cm)
  #text[по курсу:]
  #text[Программирование на языках Ассемблера]
  #v(4cm)
]

#grid(
  columns: (2fr),
  align(left)[
    #upper[РАБОТУ ВЫПОЛНИЛ]
  ],
  align(center)[
    #v(0.5cm)
    #grid(
      columns: (1fr, 1fr, 1fr, 1.5fr),
      gutter: 0.3em,
      align(left)[#upper[СТУДЕНТ гр. №]],
      [1445],
      [05.03.2026],
      [А.А. Фёдорова],
      line(length: 0%),
      line(length: 100%),
      line(length: 100%),
      line(length: 100%),
      [],
      [],
      [подпись, дата],
      [инициалы, фамилия]
    )

    #v(4cm)

    Санкт-Петербург 2026
]
)

= Описание задачи
Необходимо реализовать программу на ассемблере GAS, которая принимает с консоли три беззнаковых числа A, B,C и вычисляет выражение: $ (10А—12В^2)/C^3 $
Программа должна вывести частное и остаток от деления. Все операции выполняются только беззнаковыми инструкциями (mul, div). Ввод и вывод осуществляются через системные вызовы Linux.

= Формализация
Программа работает с тремя входными параметрами A, B и C, которые пользователь вводит в текстовом виде. Каждое значение преобразуется в беззнаковое целое число функцией, последовательно формирующей число из ASCII-цифр. Все вычисления выполняются в 64‑битных регистрах и только беззнаковыми операциями: умножение выполняется инструкцией mul, деление — div. 

Сначала вычисляется произведение 
10A, затем квадрат числа B и его умножение на 12. После этого формируется числитель выражения как разность 
$10A−12B^2$. Значение $C^3$ вычисляется последовательным умножением C на себя. Деление числителя на $C^3$ даёт частное и остаток, которые затем преобразуются в строковый вид и выводятся в консоль. Программа предполагает корректный ввод и ограничена диапазоном 64‑битных беззнаковых значений, чтобы избежать переполнений при промежуточных вычислениях.


= Исходный код программы

Код программы на ассемблере:
```asm
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

```

= Тестирование

#figure(
  table(
    columns: 6,
    align: center + horizon,
    // stroke: none,
    table.hline(),
    [*№ Вариантов   *], [*A*], [*B*], [*C*], [*Частное*],[*Остаток*],
 table.hline(),
    [1], [10],   [2],   [10],  [0], [52],
    [2], [58],  [0],  [90],  [0], [580],
    [3], [110],  [1],   [6],  [5],[8],
    table.hline(),
  ),
  caption: [Расчёт выражения $(10А—12В^2)/C^3$ для трёх различных вариантов],
)

#figure(
  image("1.png", width: 60%),
  caption: [Вывод тестового результата для варианта №1],
) <glacier>

#figure(
  image("2.png", width: 60%),
  caption: [Вывод тестового результата для варианта №2],
) <glacier>

#figure(
  image("3.png", width: 60%),
  caption: [Вывод тестового результата для варианта №3],
) <glacier>

= Выводы
В ходе работы была реализована программа на ассемблере GAS, предназначенная для вычисления выражения  $(10А—12В^2)/C^3$ для беззнаковых целых чисел. Были организованы ввод значений A, B и C с консоли, их преобразование из текстового вида в числовой формат, выполнение всех необходимых вычислений только беззнаковыми командами, а также вывод частного и остатка в консоль. После написания программы результаты были проверены ручным вычислением. Поскольку программное и ручное вычисления дали одинаковый результат, лабораторная работа выполнена верно и все поставленные цели достигнуты.
