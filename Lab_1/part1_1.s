a: .word 168
xi: .word 1
cnt: .word 100

.global _start
_start:

	LDR R0, xi
	LDR R1, a
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
	STR R0, xi
	LDR r10, xi