.section .vectors, "ax"
B _start
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0 // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

.text

load_val: .word 4000000
.equ LOAD, 0xFFFEC600
.equ CURRENT, 0xFFFEC604
.equ CONTROL, 0xFFFEC608
.equ INT_STAT, 0xFFFEC60C
.equ HEX_MEMORY_0to3, 0xFF200020
.equ HEX_MEMORY_4to5, 0xFF200030
.equ PUSH_BUTTONS_DATA, 0xFF200050
.equ PUSH_BUTTONS_INTERRUPT, 0xFF200058
.equ PUSH_BUTTONS_EDGE, 0xFF20005C

PB_int_flag :
    .word 0x0
	
tim_int_flag :
    .word 0x0


.global _start


_start:
	
    /* Set up stack pointers for IRQ and SVC processor modes */
    MOV        R1, #0b11010010      // interrupts masked, MODE = IRQ
    MSR        CPSR_c, R1           // change to IRQ mode
    LDR        SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV        R1, #0b11010011      // interrupts masked, MODE = SVC
    MSR        CPSR, R1             // change to supervisor mode
    LDR        SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
    BL     CONFIG_GIC           // configure the ARM GIC
    // To DO: write to the pushbutton KEY interrupt mask register
    // Or, you can call enable_PB_INT_ASM subroutine from previous task
    // to enable interrupt for ARM A9 private timer, use ARM_TIM_config_ASM subroutine
    BL enable_PB_INT_ASM
	BL ARM_TIM_config_ASM
	
	LDR        R0, =0xFF200050      // pushbutton KEY base address
    MOV        R1, #0xF             // set interrupt mask bits
    STR        R1, [R0, #0x8]       // interrupt mask register (base + 8)
    // enable IRQ interrupts in the processor
    MOV        R0, #0b01010011      // IRQ unmasked, MODE = SVC
    MSR        CPSR_c, R0
	
IDLE:

	
	CMP R12, #0
	BEQ START_CONFIG
	B STOP_WATCH

START_CONFIG:

	MOV R0, #1
	MOV R1, #0
	MOV R4, #0
	MOV R6, #0
	MOV R7, #0
	MOV R8, #0
	MOV R9, #0
	
STOP_LOOP:
	push {R0,R1}
	LDR R0, PB_int_flag	
	
	CMP R0, #2
	popeq {R0,R1}
	BEQ STOP_WATCH

	CMP R0, #1
	popeq {R0,R1}
	BEQ STOP_WATCH
	
	CMP R0, #4
	pop {R0,R1}
	BNE STOP_LOOP
	MOV R0, #0x3F
	BL HEX_clear_ASM
	B STOP_LOOP
	

INF_LOOP:
	MOV R0, #0x3F
	BL HEX_clear_ASM
	
	BL ARM_TIM_config_ASM
	MOV R0, #1
	MOV R1, #0
	MOV R4, #0
	MOV R6, #0
	MOV R7, #0
	MOV R8, #0
	MOV R9, #0
	
STOP_WATCH:
	MOV R0, #1
	BL HEX_write_ASM
	 // This is where you write your objective task
	
READ_WAIT:
	PUSH {R0, R1}
	
	LDR R0, PB_int_flag
	
	CMP R0, #2
	BEQ STOPUU_
	
	CMP R0, #4
	POP {R0, R1}
	BEQ START_CONFIG
	
	LDR R11, tim_int_flag
	CMP R11, #0
	BEQ READ_WAIT
	MOV R11, #0
	STR R11, tim_int_flag
	

	CMP R1, #9
	ADD R1, R1, #1
	BLT STOP_WATCH
	BEQ STOP_WATCH2
	B INF_LOOP
	
	
	STOPUU_:
	POP {R0, R1}
	B STOP_LOOP	
	
STOP_WATCH2:

	ADD R4, R4, #1
	
	MOV R0, #1
	MOV R1, #0
	BL HEX_write_ASM
	
	MOV	R0, #2
	MOV R1, R4
	BL HEX_write_ASM
	
	CMP R4, #10
	BLT SKIP_REWRITE
	MOV R4, #0
	B STOP_WATCH3
	
STOP_WATCH3:
	
	ADD R6, R6, #1
	
	MOV R0, #2
	MOV R1, #0
	BL HEX_write_ASM
	
	MOV R0, #4
	MOV R1, R6
	BL HEX_write_ASM
	
	CMP R6, #10
	BLT SKIP_REWRITE
	MOV R6, #0
	B STOP_WATCH4
	
STOP_WATCH4:

	ADD R7, R7, #1
	
	MOV R0, #4
	MOV R1, #0
	BL HEX_write_ASM
	
	MOV R0, #8
	MOV R1, R7
	BL HEX_write_ASM
	
	CMP R7, #6
	BLT SKIP_REWRITE
	MOV R7, #0
	B STOP_WATCH5
	
STOP_WATCH5:

	ADD R8, R8, #1
	
	MOV R0, #8
	MOV R1, #0
	BL HEX_write_ASM
	
	MOV R0, #16
	MOV R1, R8
	BL HEX_write_ASM
	
	CMP R8, #10
	BLT SKIP_REWRITE
	MOV R8, #0
	B STOP_WATCH6
	
STOP_WATCH6:
	MOV R0, #32
	MOV R1, R9
	BL HEX_write_ASM
	ADD R9, R9, #1
	CMP R9, #6
	BLT SKIP_REWRITE
	MOV R9, #0
	B INF_LOOP
	
SKIP_REWRITE:
	B STOP_WATCH
	
	
/*--- Undefined instructions ---------------------------------------- */
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts ------------------------------------------- */
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads -------------------------------------------- */
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch ------------------------------------- */
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ----------------------------------------------------------- */
SERVICE_IRQ:
    PUSH {R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR

/* To Do: Check which interrupt has occurred (check interrupt IDs)
   Then call the corresponding ISR
   If the ID is not recognized, branch to UNEXPECTED
   See the assembly example provided in the De1-SoC Computer_Manual on page 46 */
 
 //Implement this -> should be good now.
 TIME_check:
 	CMP R5, #29
	BNE Pushbutton_check
	BL ARM_TIM_ISR
	B EXIT_IRQ
 
 Pushbutton_check:
    CMP R5, #73
UNEXPECTED:
    BNE UNEXPECTED      // if not recognized, stop here
    BL KEY_ISR
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    POP {R0-R7, LR}
SUBS PC, LR, #4
/*--- FIQ ----------------------------------------------------------- */
SERVICE_FIQ:
    B SERVICE_FIQ
	
	
	
CONFIG_GIC:
    PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* To Do: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
   
   //should be good now?
    MOV R0, #29
	MOV R1, #1
	BL CONFIG_INTERRUPT
   
    MOV R0, #73            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT

/* configure the GIC CPU Interface */
    LDR R0, =0xFFFEC100    // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF        // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}
	
//implement this (should be good)
ARM_TIM_ISR:
	MOV R1, #1
	STR R1, tim_int_flag
	push {r4-r11, lr}
	MOV R7, #1
	LDR R5, =INT_STAT
	STR R7, [R5]
	pop {r4-r11, lr}
	BX LR

	
//change this (should be good)
KEY_ISR:
    LDR R0, =0xFF200050    // base address of pushbutton KEY port
    LDR R1, [R0, #0xC]     // read edge capture register
    STR R1, PB_int_flag
	MOV R2, #0xF
    STR R2, [R0, #0xC]     // clear the interrupt
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
	
ARM_TIM_config_ASM:
	push {r4-r11, lr}
	LDR R0, load_val
	MOV R1, #0b111
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
	
	
END:
	STR R5, [R2]
	STR R7, [R3]
	MOV R12, #0
	pop {r4-r11, lr}
	BX LR
	