array:	.word 3,4,5,4
n: .word 4
mean: .word 0


	
.global _start
	
_start:

	MOV R0, #0 //i
	LDR R1, =array //starting address of the array
	LDR R6, n
	LDR R8, mean
	MOV R9, #4 // size of int = 4 bytes
	MOV R7, #0 // log_2n
	
log2_n:
	LSL R12, R7, #1
	CMP R12, R6
	BGE CAL_mean
	ADD R7, R7, #1
	B log2_n


CAL_mean:
	MUL R2, R0, R9  //R2 = array element index
	ADD R3, R1, R2 //R3 = base address + index
	LDR R4, [R3] //R4 = content at address R3
	ADD R0, R0, #1
	ADD R8, R8, R4
	CMP R0, R6
	BLT CAL_mean
	
	ASR R8, R8, R7
	MOV R0, #0
	B Center
	
Center:
	MUL R2, R0, R9  //R2 = array element index
	ADD R3, R1, R2 //R3 = base address + index
	LDR R4, [R3] //R4 = content at address R3
	ADD R0, R0, #1
	SUBS R4, R4, R8
	STR R4, [R3]
	CMP R0, R6
	BLT Center
	
	
	