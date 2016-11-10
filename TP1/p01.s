@ File: AddMain.s
.text
.global _start
.extern myAdd
_start:
LDR R0,=Num1
LDR R0,[R0] @ first parameter passed in R0
LDR R1,=Num2
LDR R1,[R1] @ second parameter passed in R1
ADD R0, R0, R1
LDR R4, =Answer
STR R0,[R4] @ result est écrit en mémoire
SWI 0x11 @ arrêter le programme
.data
Num1: .word 537
Num2: .word -237
Answer: .word 0
.end
