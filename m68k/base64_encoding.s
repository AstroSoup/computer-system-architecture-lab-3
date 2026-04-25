.data
buffer: .byte '_________________________________________________________________' ; [0; 0x40]
in: .word 0x80
out: .word 0x84
mask: .word 0x3F

.data
.org 0x88
lookup: .byte 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'


.text
_start:
movea.l in, A0
movea.l (A0), A0
movea.l out, A1
movea.l (A1), A1

movea.l buffer, A2

movea.l lookup, A3

; Process the 3 bytes in D0 into ascii symbols and add them to the buffer. 
; D7 acts as loop counter.
loop:

    ; In inner loop we load bytes from input in threes. 
    ; If we encounter '\n' we get out of the both loops, and add padding if needed.
    ; D6 acts as a loop counter.
    move.l 0, D6
    inner_loop_input:

        cmp.l 3, D6
        bge inner_done_input;

        cmp.l 0x40, D7
        bge overflow
        add.l 1, D7

        lsl.l 8, D0
        move.b (A0), D0

        ; if (c == '\n') {break;}
        cmp.b 0x0A, D0
        beq done

        add.l 1, D6
        jmp inner_loop_input

        inner_done_input:

    move.l 0, D6
    inner_loop_process:
        cmp.l 4, D6
        bge inner_done_process

        lsl.l 2, D0; Shift last 2 bits of the symbol out of the byte to the left
        lsr.b 2, D0; Shift symbol inside the lowest byte to encode it
        lsl.l 8, D2;
        move.b D0, D1
        move.b (A3, D1), D2;
        

        lsr.l 8, D0

        add.l 1, D6
        jmp inner_loop_process
        inner_done_process:

    move.l 0, D6
    inner_loop_to_buffer:
        cmp.l 4, D6
        bge inner_done_to_buffer

        move.b D2, (A2)+
        lsr.l 8, D2

        add.l 1, D6
        jmp inner_loop_to_buffer
        inner_done_to_buffer:


jmp loop
done:

; if we did not encounter overflow, the last byte will be '\n'. 
; We have 3 options: '\n' was loaded 1st, 2nd or 3rd of 3. 
; We need to insert 0, 2 or 1 padding chars, respectivly. 
cmp.l 0, D6 ; if '\n' was loaded 1st of 3: 
beq first

cmp.l 1, D6 ; if '\n' was loaded 2nd of 3: 
beq second

cmp.l 2, D6 ; if '\n' was loaded 3rd of 3: 
beq third


exit:
halt

; TODO: add processing of leftover symbols in D0.
first:
move.b 0x00, (A2)+
jmp output

second:
lsr.l 8, D0 ; remove '\n' from the symbols.

lsl.l 6, D0
lsr.b 2, D0

move.b D0, D1
move.b (A3, D1), D2
lsl.l 8, D2
lsr.l 8, D0
move.b D0, D1
move.b (A3, D1), D2

move.b D2, (A2)+
lsr.l 8, D2
move.b D2, (A2)+
lsr.l 8, D2


move.b 0x3D, (A2)+
move.b 0x3D, (A2)+
move.b 0x00, (A2)+
jmp output

third:
lsr.l 8, D0 ; remove '\n' from the symbols.

lsl.l 4, D0
lsr.b 2, D0

move.b D0, D1
move.b (A3, D1), D2

lsl.l 8, D2
lsr.l 6, D0
lsr.b 2, D0

move.b D0, D1
move.b (A3, D1), D2

lsl.l 8, D2
lsr.l 6, D0
lsr.b 2, D0
move.b D0, D1
move.b (A3, D1), D2

move.b D2, (A2)+
lsr.l 8, D2
move.b D2, (A2)+
lsr.l 8, D2
move.b D2, (A2)+
lsr.l 8, D2

move.b 0x3D, (A2)+
move.b 0x00, (A2)+
jmp output

output:
movea.l buffer, A0
output_loop:
    move.b (A0)+, D0

    cmp.b 0x00, D0
    beq exit

    move.b D0, (A1)    

jmp output_loop


overflow:
movea.l buffer, A2
move.b 0x00, (A2)
move.l 0xCCCCCCCC, (A1)
jmp exit


