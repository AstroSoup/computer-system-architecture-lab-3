    .data
output_buffer:      .byte  'Hello, _________________________' \ Ячейки [0;31]

question:           .byte  'What is your name?\n\0'
mask:               .word  0xFF
const_1:            .word  1
writing_pointer:    .word  7
exclamation_point:  .byte  '!\0__'
read_stop:          .byte  '\n\0\0\0'

in:                 .word  0x80
out:                .word  0x84

overflow:           .word  23
overflow_indicator: .word  0xCCCCCCCC

    .text
    .org 0x88
_start:

    lit question             \ Загружаем указатель на текущее слово в приветствии
    a!                       \ Складываем указатель в регистр A


\ Вывод вопроса

question_loop:

    @+                       \ Загружаем слово
    msk                      \ маскируем
    dup                      \ дублируем т.к. if - деструктивная операция
    if question_loop_exit    \ Если встретили  \0 - выходим из цикла
    \ Выводим символ
    data_to_out
    \ Новая итерация
    question_loop ;

question_loop_exit:



\ Считывание имени

    \ Загружаем указатель на ячейку с которой мы ведем запись имени
    @p writing_pointer
    a!

    \ Читаем символы из mem[in] пока не встретим \n
input_loop:
    in_to_data               \ Считываем ввод на вершину стека данных

    \ Проверка на окончание ввода (\n)
    dup
    @p read_stop
    neg
    +
    if input_loop_exit



    !+                       \ Записываем полученный символ в буфер

    \ Проверка на переполнение
    @p overflow
    @p const_1
    neg
    +
    dup
    !p overflow
    if overflow_event
    \ Новая итерация
    input_loop ;

input_loop_exit:

\ Запись восклицательного знака

    lit output_buffer        \ Записываем адрес начала буфера в регистр А
    a!

    \ Ищем \0 символ завершения строки
find_null:
    @+
    msk
    if null_found
    find_null ;

null_found:

    \ Записываем восклицательный знак на конец строки
    @p exclamation_point
    a
    @p const_1
    neg
    +
    a!
    !


\ Вывод приветствия

    lit output_buffer        \ Загружаем адрес начала буфера в регистр А
    a!

    \ Проходимся по буферу и выводим его посимвольно
hello_loop:
    @+
    dup
    msk
    if hello_loop_exit
    data_to_out

    hello_loop ;

hello_loop_exit:

exit_point:
    halt



\ overflow -> mem[out]; halt;
\ {
overflow_event:
    @p out
    a!
    @p overflow_indicator
    !
    exit_point ;
\ }


\ Процедуры

\ dataStack.push(dataStack.pop() & mask)
\ {
msk:
    @p mask
    and
    ;
\ }

\ dataStack.push(-dataStack.pop());
\ {
neg:
    inv
    @p const_1
    +
    ;
\ }

\ dataStack.push(mem[in]);
\ {
in_to_data:
    @p in
    b!
    @b
    ;
\ }

\ dataStack.pop() -> mem[out];
\ {
data_to_out:
    msk
    @p out
    b!
    !b
    ;
\ }

