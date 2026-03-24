    .data
counter:         .word  0
const_32:        .word  32
const_1:         .word  1
in_addr:         .word  0x80
out_addr:        .word  0x84
tmp:             .word  0

    .text
_start:
    load         in_addr                     ; загружаю адрес входной ячейки
    load_acc                                 ; загружаю в аккумулятор данные из входной ячейки
for:
    store        tmp                         ; сохраняю в ячейке памяти для дальнейшего переиспользования

    and          const_1                     ; битовое и с 1 чтобы занулить все разряды кроме первого
    bnez         exit                        ; если нашелся не 0 --- выходим из программы

    load         counter
    add          const_1                     ; увеличиваю счетчик
    store        counter

    sub          const_32
    beqz         exit                        ; если число полностью пройдено (т.е. счетчик = 32), то выходим из цикла

    load         tmp
    shiftr       const_1                     ; сдвигаю число для проверки следующего разряда
    jmp          for

exit:
    load         counter
    store_ind    out_addr
    halt