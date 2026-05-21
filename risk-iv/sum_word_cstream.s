    .data

in:              .word  0x80
out:             .word  0x84
stack:           .word 0x1000

    .text
    .org 0x90
_start:
    lui      a0, %hi(in)
    addi     a0, a0, %lo(in)
    lw       a0, 0(a0)

    lui      a1, %hi(out)
    addi     a1, a1, %lo(out)
    lw       a1, 0(a1)
    
    lui      sp, %hi(stack)
    addi     sp, sp, %lo(stack)
    lw       sp, 0(sp)

    mv       fp, sp

    jal     a7, loop

    sw       t2, 0(a1)
    sw       t1, 0(a1)

    halt



    ; t0 is inputed int32 value
    ; t1 is lower word of answer
    ; t2 is higher word of answer
    ; t3 is t1 + t0. Used for checking wether we encounter overflow on add.
loop:
    addi    sp, sp, -4
    sw      a7, 0(sp)

    lw       t0, 0(a0)
    beqz     t0, loop_return

    add      t3, t1, t0

    ; if t1 >= t3 than we encounter overflow on adding input to our lower word.
    ; and need to check if we need to increment the high word.
    bgtu     t1, t3, carry

    ; else we need to check if we need to borrow from the high word.
    mv       t1, t3
    ; if the input was negative then we need to borrow from the high word.
    bgt      zero, t0, sub_1_high

    jal        a7, loop    
    j loop_return


carry:
    ; we are setting the lower word as remainder after overflowing
    mv       t1, t3
    ; if input was negative, then we dont need to increment the higher word.
    bgt      t0, zero, add_1_high
    jal       a7, loop
    j loop_return

add_1_high:
    addi     t2, t2, 1
    jal      a7, loop
    j loop_return

sub_1_high:
    addi     t2, t2, -1
    jal      a7, loop
    j loop_return


loop_return:
    lw       a7, 0(sp)
    addi     sp, sp, 4
    jr a7

