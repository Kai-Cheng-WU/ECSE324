array: .word 5,6,7,8
n: .word 4
log2_n: .word 0
tmp: .word 0
norm: .word 1
cnt: .word 100
k: .word 10
t: .word 2

.global _start
_start:
	MOV R0, #0 //i
	LDR R1, =array //starting address of the array
	LDR R6, n
	MOV R7, #0 //log2_n
	LDR R8, tmp //R8=tmp
	MOV R9, #4 //size of int = 4bytes
	

log:
	LSL R12, R7, #1 
	CMP R12, R6
	BGE CAL_norm
	ADD R7, R7, #1
	B log
	
CAL_norm:
	MUL R2, R0, R9 //R2 = array element index
	ADD R3, R1, R2 //R3 = base address + index
	LDR R4, [R3] //R4 = element at address R3
	MUL R4, R4, R4 //R4 = R4*R4
	ADD R8, R8, R4
	ADD R0, R0, #1
	CMP R0, R6
	BLT CAL_norm

	ASR R8, R8, R7
	
	
//sqrIter
	
	MOV R1, R8  //R1=a=tmp
	LDR R0, norm  //R0=xi=norm
	LDR R2, cnt
	
	MOV R6, #0

//k=10, t=2
//use R4 for steps
LOOP:	
	CMP R6, R2 //loop
	BGE END
	ADD R6, R6, #1
	MUL R4, R0, R0  //step=xi*xi
	SUBS R4, R4, R1  //step=step-a
	MUL R4, R4, R0  //step=step*xi
	ASR R4, R4, #10 //step=step>>10
	CMP R4, #2
	BGT B_STEP
	CMP R4, #-2
	BLT S_STEP
	SUBS R0, R0, R4 //xi=xi-step
	B LOOP //back to the start of the loop
	
	
B_STEP: 
	MOV R4, #2
	SUBS R0, R0, R4
	B LOOP
	
S_STEP:
	MOV R4, #-2
	SUBS R0, R0, R4
	B LOOP
	
END:
	STR R0, norm
	LDR r10, norm
