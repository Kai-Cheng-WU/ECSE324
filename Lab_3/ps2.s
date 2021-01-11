.equ PS2_DATA, 0xFF200100
.equ BUFFER, 0xc8000000
.equ CHAR_BUFFER, 0xc9000000


.global _start
_start:
        bl      input_loop
end:
        b       end

@ TODO: copy VGA driver here.

		
VGA_draw_point_ASM:
	PUSH {R4-R11, LR}
	LSL R4, R0, #1
	LSL R5, R1, #10
	LDR R6, =BUFFER
	ORR R7, R4, R5
	ORR R7, R7, R6
	STRH R2, [R7]
	POP {R4-R11, LR}
	BX LR
	
VGA_clear_pixelbuff_ASM:
	PUSH {R4-R11, LR}
	LDR R6, =BUFFER
	MOV R0, #0
	MOV R1, #0
	MOV R2, #0

	CLEAR_LOOP_1:
		MOV R1, #0
		CLEAR_LOOP_2:
			BL VGA_draw_point_ASM
			ADD R1, R1, #1
			CMP R1, #240
			BLT CLEAR_LOOP_2
		ADD R0, R0, #1
		CMP R0, #320
		BLT CLEAR_LOOP_1
		
	POP {R4-R11, LR}
	BX LR
	
	
	
VGA_write_char_ASM:
	PUSH {R4-R11, LR}
	CMP R0, #0
	BLT SKIP
	CMP R0, #79
	BGT SKIP
	CMP R1, #0
	BLT SKIP
	CMP R1, #59
	LSL R4, R0, #0
	LSL R5, R1, #7
	LDR R6, =CHAR_BUFFER
	ORR R7, R4, R5
	ORR R7, R7, R6
	STRB R2, [R7]
	SKIP:
	POP {R4-R11, LR}
	BX LR

VGA_clear_charbuff_ASM:
	PUSH {R4-R11, LR}
	LDR R6, =BUFFER
	MOV R0, #0
	MOV R1, #0
	MOV R2, #0

	CLEAR_CHAR_LOOP_1:
		MOV R1, #0
		CLEAR_CHAR_LOOP_2:
			BL VGA_write_char_ASM
			ADD R1, R1, #1
			CMP R1, #60
			BLT CLEAR_CHAR_LOOP_2
		ADD R0, R0, #1
		CMP R0, #80
		BLT CLEAR_CHAR_LOOP_1
		
	POP {R4-R11, LR}
	
	BX LR


@ TODO: insert PS/2 driver here.

read_PS2_data_ASM:
	PUSH {R4-R11, LR}
	LDR R6, =PS2_DATA
	LDR R5, [R6]
	ASR R4, R5, #15
	AND R4, R4, #0x1
	CMP R4, #0
	BEQ RINVALID
	STRB R5, [R0]
	MOV R0, #1
	POP {R4-R11, LR}
	BX LR
	
	RINVALID:
		MOV R0, #0
		POP {R4-R11, LR}
		BX LR

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
