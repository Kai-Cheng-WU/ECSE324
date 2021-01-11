.equ SW_MEMORY, 0xFF200040
.equ LED_MEMORY, 0xFF200000
.equ HEX_MEMORY_0to3, 0xFF200020
.equ HEX_MEMORY_4to5, 0xFF200030
.equ PUSH_BUTTONS_DATA, 0xFF200050
.equ PUSH_BUTTONS_INTERRUPT, 0xFF200058
.equ PUSH_BUTTONS_EDGE, 0xFF20005C

.global _start
_start:

INF_LOOP:
	BL read_slider_switches_ASM
	BL write_LEDs_ASM

	
	MOV R0, #0X30
	BL HEX_flood_ASM
	

	B INF_LOOP


// returns the state of slider switches in R0
read_slider_switches_ASM:
	push {r4-r11, lr}
    LDR R1, =SW_MEMORY
    LDR R0, [R1]
	TST R0, #0b1000000000
	BEQ SKIP
	push {R0}
	MOV R0, #63
	BL HEX_clear_ASM
	pop {R0}
	
	LDR R11, [R1]
	push {R1}
	AND R1, R11, #15
	push {R0}
	BL read_PB_data_ASM
	BL HEX_write_ASM
	pop {R0}
	pop {R1}
	pop {r4-r11, lr}
	BX LR

SKIP:
	LDR R11, [R1]
	push {R1}
	AND R1, R11, #0b1111
	push {R0}
	BL read_PB_edgecp_ASM
	BL HEX_write_ASM
	BL PB_clear_edgecp_ASM
	pop {R0}
	pop {R1}
	pop {r4-r11, lr}
    BX  LR

// writes the state of LEDs (On/Off state) in R0 to the LEDs memory location
write_LEDs_ASM:
	push {r4-r11, lr}
    LDR R1, =LED_MEMORY
    STR R0, [R1]
	pop {r4-r11, lr}
    BX  LR

	
HEX_clear_ASM:
	push {r4-r11, lr}
	LDR R2, =HEX_MEMORY_0to3
	LDR R3, =HEX_MEMORY_4to5
	LDR R5, [R2]
	LDR R7, [R3]
	MOV R6, #0xFFFFFF00
	MOV R8, #0xFFFFFF00
	MOV R12, #0 //counter
	
	CMP R0, #15
	BLE SMOLC
	BGT BIGGC

SMOLC:
	TST R0, #1
	BEQ SKIP_ADDING_SC
	AND R5, R5, R6
	
SKIP_ADDING_SC:
	LSL R6, #8
	ADD R6, R6, #0xFF
	LSR R0, #1
	CMP R0, #0
	BEQ END
	B SMOLC

BIGGC:
	TST R0, #1
	BEQ SKIP_ADDING_BC
	AND R5, R5, R6
	
SKIP_ADDING_BC:
	LSL R6, #8
	ADD R6, R6, #0xFF
	LSR R0, #1
	CMP R12, #3
	ADD R12, R12, #1
	BEQ _4to5C
	B BIGGC

_4to5C:
	TST R0, #1
	BEQ SKIP_4to5C
	AND R7, R7, R8

SKIP_4to5C:
	LSL R8, #8
	ADD R8, R8, #0xFF
	LSR R0, #1
	CMP R0, #0
	BEQ END
	B _4to5C
	
		
	
HEX_flood_ASM:
	push {r4-r11, lr}
	LDR R2, =HEX_MEMORY_0to3
	LDR R3, =HEX_MEMORY_4to5
	LDR R5, [R2]
	LDR R7, [R3]
	MOV R6, #0x0FF
	MOV R8, #0x0FF
	MOV R12, #0 //counter
	
	CMP R0, #15
	BLE SMOL
	BGT BIGG
	
SMOL:
	TST R0, #1
	BEQ SKIP_ADDING_S
	ORR R5, R5, R6
	
SKIP_ADDING_S:
	LSL R6, #8
	LSR R0, #1
	CMP R0, #0
	BEQ END
	B SMOL

BIGG:
	TST R0, #1
	BEQ SKIP_ADDING_B
	ORR R5, R5, R6
	
SKIP_ADDING_B:
	LSL R6, #8
	LSR R0, #1
	CMP R12, #3
	ADD R12, R12, #1
	BEQ _4to5
	B BIGG

_4to5:
	TST R0, #1
	BEQ SKIP_4to5
	ORR R7, R7, R8

SKIP_4to5:
	LSL R8, #8
	LSR R0, #1
	CMP R0, #0
	BEQ END
	B _4to5
	
	
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
	
read_PB_data_ASM:
	push {r4-r11, lr}
    LDR R12, =PUSH_BUTTONS_DATA
    LDR R0, [R12]
	pop {r4-r11, lr}
    BX  LR
	
	
PB_data_is_pressed_ASM: 
	push {r4-r11, lr}
	LDR R1, =PUSH_BUTTONS_DATA
	LDR R2, [R1]
	TST R2, R0
	BEQ SKIP_DT_PRESS
	MOV R0, #1
	pop {r4-r11, lr}
	BX LR

SKIP_DT_PRESS:
	MOV R0, #0
	pop {r4-r11, lr}
	BX LR
	
read_PB_edgecp_ASM:
	push {r4-r11, lr}
	LDR R12, =PUSH_BUTTONS_EDGE
	LDR R0, [R12]
	pop {r4-r11, lr}
	BX LR
	
PB_edgecp_is_pressed_ASM:
	push {r4-r11, lr}
	LDR R1, =PUSH_BUTTONS_EDGE
	LDR R2, [R1]
	TST R2, R0
	BEQ SKIP_EG_PRESS
	MOV R0, #1
	pop {r4-r11, lr}
	BX LR

SKIP_EG_PRESS:
	MOV R0, #0
	pop {r4-r11, lr}
	BX LR
	
PB_clear_edgecp_ASM:
	push {r4-r11, lr}
	LDR R1, =PUSH_BUTTONS_EDGE
	MOV R4, #0xF
	STR R4, [R1]
	pop {r4-r11, lr}
	BX LR
	
enable_PB_INT_ASM:
	push {r4-r11, lr}
	LDR R1, =PUSH_BUTTONS_INTERRUPT
	STR R0, [R1]
	pop {r4-r11, lr}
	BX LR
	
disable_PB_INT_ASM:
	push {r4-r11, lr}
	LDR R1, =PUSH_BUTTONS_INTERRUPT
	LDR R5, [R1]
	EOR R4, R0, R5
	STR R4, [R1]
	pop {r4-r11, lr}
	BX LR