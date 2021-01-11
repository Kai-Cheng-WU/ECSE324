array: .word 4,2,1,4,-1
n: .word 5

.global _start
_start:
	MOV R0, #0 //i
	LDR R1, =array //starting address of the array
	MOV R9, #4 // size of int = 4 bytes
	
LOOP1:
	MUL R2, R0, R9  //R2 = array element index
	ADD R3, R1, R2 //R3 = base address + index 
	LDR R4, [R3] //R4 = element at address [R3] (tmp)
	MOV R5, R0 //cur_min_idx = i
	MOV R10, R0 //j=i
	
	LOOP2:
		ADD R10, R10, #1 //j=i+1
		MUL R8, R10, R9 //array
		ADD R11, R1, R8 //array, R11 = *(ptr+j)
		LDR R7, [R11]
		CMP R4, R7
		BLE SKIP
		LDR R4, [R11]
		MOV R5, R10
		SKIP:
		CMP R10, #5
		BLT LOOP2
	//SWAP
	LDR R4, [R3]
	MUL R12, R5, R9 //R12=
	ADD R12, R1, R12 //R12=ptr + cur_min_idx
	LDR R6, [R12]
	STR R6, [R3]
	STR R4, [R12]
	
	ADD R0, R0, #1
	CMP R0, #4
	BLT LOOP1
		
	
		