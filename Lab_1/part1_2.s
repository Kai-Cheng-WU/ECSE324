a: .word 168
xi: .word 1
cnt: .word 100


.global _start
_start:
	LDR R0, xi
	LDR R1, a
	LDR R2, cnt
	


LOOP:
	CMP R2, #0 //if condition
	BEQ END
	BL RECUR
	SUBS R2, R2, #1 //cnt=cnt-1
	B LOOP
//k=10, t=2
//use R4 f0r gradient
RECUR:
	push {r4-r11, lr}
	MUL R4, R0, R0 //else: grad = xi * xi
	SUBS R4, R4, R1 //grad = grad - a
	MUL R4, R4, R0 //grad = grad * xi
	ASR R4, R4, #10 //grad = grad >> k
	CMP R4, #2 
	BGT B_GRAD
	CMP R4, #-2
	BLT S_GRAD
	SUBS R0, R0, R4 //xi=xi-grad
	pop {r4-r11, lr}

	BX LR //restart the recursion whith cnt = cnt-1
	
	
B_GRAD:
	MOV R4, #2
	SUBS R0, R0, R4
	BX LR
	
S_GRAD:
	MOV R4, #-2
	SUBS R0, R0, R4
	BX LR
	

END:
	STR R0, xi
	LDR R10, xi
	