    .data

in:              .word  0x80
out:             .word  0x84

    .text

_start:
    lui      a0, %hi(in)
    addi     a0, a0, %lo(in)
    lw       a0, 0(a0)

    lui      a1, %hi(out)
    addi     a1, a1, %lo(out)
    lw       a1, 0(a1)

    ; t0 is inputed int32 value
    ; t1 is lower word of answer
    ; t2 is higher word of answer
    ; t3 is t1 + t0. Used for checking wether we encounter overflow on add.
loop:
    lw       t0, 0(a0)
    beqz     t0, exit

    add      t3, t1, t0

    ; if t1 >= t3 than we encounter overflow on adding input to our lower word.
    ; and need to check if we need to increment the high word.
    bgtu     t1, t3, carry

    ; else we need to check if we need to borrow from the high word.
    mv       t1, t3
    ; if the input was negative then we need to borrow from the high word.
    bgt      zero, t0, sub_1_high
    j        loop

carry:
    ; we are setting the lower word as remainder after overflowing
    mv       t1, t3
    ; if input was negative, then we dont need to increment the higher word.
    bgt      t0, zero, add_1_high
    j        loop

add_1_high:
    addi     t2, t2, 1
    j        loop

sub_1_high:
    addi     t2, t2, -1
    j        loop

exit:
    sw       t2, 0(a1)
    sw       t1, 0(a1)

    halt
