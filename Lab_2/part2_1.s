load_val: .word 200000000
.equ LOAD, 0xFFFEC600
.equ CURRENT, 0xFFFEC604
.equ CONTROL, 0xFFFEC608
.equ INT_STAT, 0xFFFEC60C
.equ HEX_MEMORY_0to3, 0xFF200020
.equ HEX_MEMORY_4to5, 0xFF200030

.global _start
_start:

INF_LOOP:
	BL ARM_TIM_config_ASM
	MOV R0, #1
	MOV R1, #0
	
STOP_WATCH:
	MOV R0, #1
	BL HEX_write_ASM

READ_WAIT:
	BL ARM_TIM_read_INT_ASM
	TST R12, #1
	BEQ READ_WAIT
	
	
	BL ARM_TIM_clear_INT_ASM
	CMP R1, #15
	ADD R1, R1, #1
	BLT STOP_WATCH
	
	B INF_LOOP

ARM_TIM_config_ASM:
	push {r4-r11, lr}
	LDR R0, load_val
	MOV R1, #3
	LDR R3, =LOAD
	LDR R4, =CONTROL
	STR R0, [R3]
	STR R1, [R4]
	pop {r4-r11, lr}
	BX LR
	
ARM_TIM_read_INT_ASM:
	push {r4-r11, lr}
	LDR R3, =LOAD
	LDR R5, =INT_STAT
	LDR R12, [R5]
	pop {r4-r11, lr}
	BX LR
	
ARM_TIM_clear_INT_ASM: 
	push {r4-r11, lr}
	MOV R7, #1
	LDR R5, =INT_STAT
	STR R7, [R5]
	pop {r4-r11, lr}
	BX LR
	
	
	
HEX_write_ASM:
	push {r4-r11, lr}
	LDR R2, =HEX_MEMORY_0to3
	LDR R3, =HEX_MEMORY_4to5
	LDR R5, [R2]
	LDR R7, [R3]
	MOV R12, #0 //counter
	MOV R9, #0xFFFFFF00
	MOV R10, #0xFFFFFF00
	
	CMP R1, #0
	BEQ case_0
	
	CMP R1, #1
	BEQ case_1
	
	CMP R1, #2
	BEQ case_2
	
	CMP R1, #3
	BEQ case_3
	
	CMP R1, #4
	BEQ case_4
	
	CMP R1, #5
	BEQ case_5
	
	CMP R1, #6
	BEQ case_6
	
	CMP R1, #7
	BEQ case_7
	
	CMP R1, #8
	BEQ case_8
	
	CMP R1, #9
	BEQ case_9
	
	CMP R1, #0x0a
	BEQ case_a
	
	CMP R1, #0x0b
	BEQ case_b
	
	CMP R1, #0x0c
	BEQ case_c
	
	CMP R1, #0x0d
	BEQ case_d
	
	CMP R1, #0x0e
	BEQ case_e
	
	CMP R1, #0x0f
	BEQ case_f
	
	
case_0:
	MOV R6, #0b111111
	MOV R8, #0b111111
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW
	
case_1:
	MOV R6, #0b110
	MOV R8, #0b110
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	

case_2:
	MOV R6, #0b1011011
	MOV R8, #0b1011011
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW
	
case_3:
	MOV R6, #0b1001111
	MOV R8, #0b1001111
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW
	
case_4:
	MOV R6, #0b1100110
	MOV R8, #0b1100110
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
case_5:
	MOV R6, #0b1101101
	MOV R8, #0b1101101
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
case_6:
	MOV R6, #0b1111101
	MOV R8, #0b1111101
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
		
case_7:
	MOV R6, #0b111
	MOV R8, #0b111
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
		
case_8:
	MOV R6, #0b1111111
	MOV R8, #0b1111111
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
		
case_9:
	MOV R6, #0b1101111
	MOV R8, #0b1101111
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
		
case_a:
	MOV R6, #0b1110111
	MOV R8, #0b1110111
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
		
case_b:
	MOV R6, #0b1111100
	MOV R8, #0b1111100
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
		
case_c:
	MOV R6, #0b0111001
	MOV R8, #0b0111001
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	

case_d:
	MOV R6, #0b1011110
	MOV R8, #0b1011110
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	

case_e:
	MOV R6, #0b1111001
	MOV R8, #0b1111001
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	

case_f:
	MOV R6, #0b1110001
	MOV R8, #0b1110001
	CMP R0, #15
	BLE SMOLW
	BGT BIGGW	
	
SMOLW:
	TST R0, #1
	BEQ SKIP_ADDING_SW
	AND R5, R5, R9
	ADD R5, R5, R6
	
SKIP_ADDING_SW:
	LSL R6, #8
	LSL R9, #8
	ADD R9, R9, #0xFF
	LSR R0, #1
	CMP R0, #0
	BEQ END
	B SMOLW

BIGGW:
	TST R0, #1
	BEQ SKIP_ADDING_BW
	AND R5, R5, R9
	ADD R5, R5, R6
	
SKIP_ADDING_BW:
	LSL R6, #8
	LSL R9, #8
	ADD R9, R9, #0xFF
	LSR R0, #1
	CMP R12, #3
	ADD R12, R12, #1
	BEQ _4to5W
	B BIGGW

_4to5W:
	TST R0, #1
	BEQ SKIP_4to5W
	AND R7, R7, R10
	ADD R7, R7, R8

SKIP_4to5W:
	LSL R8, #8
	LSL R10, #8
	ADD R10, R10, #0xFF
	LSR R0, #1
	CMP R0, #0
	BEQ END
	B _4to5W

	
	
END:
	STR R5, [R2]
	STR R7, [R3]
	MOV R12, #0
	pop {r4-r11, lr}
	BX LR