.equ SW_MEMORY, 0xFF200040
.equ LED_MEMORY, 0xFF200000

.global _start
_start:
	
INF_LOOP:

	BL read_slider_switches_ASM
	BL write_LEDs_ASM
	B INF_LOOP

// returns the state of slider switches in R0
read_slider_switches_ASM:
    LDR R1, =SW_MEMORY
    LDR R0, [R1]
    BX  LR

// writes the state of LEDs (On/Off state) in R0 to the LEDs memory location
write_LEDs_ASM:
    LDR R1, =LED_MEMORY
    STR R0, [R1]
    BX  LR

