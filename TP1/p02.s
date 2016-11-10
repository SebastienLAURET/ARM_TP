@ File: AddMain.s
.text
.global _start
.extern myAdd
_start:
LDR R0,=Num1
LDR R0,[R0] @ first parameter passed in R0
LDR R1,=Num2
LDR R1,[R1] @ second parameter passed in R1
ADD R2, R0, R1
LDR R4, =Answer
STR R2,[R4] @ result was returned in R2
MOV r0,#0
mov R1,#0
LDR R2,=produit
LDR R2,[r2]
SWI 0x204
SWI 0x11
.data
@ Déclaration des produits
p0: .asciz "Code Description Prix Disp."
p1: .asciz "1 Chips 1.25"
p2: .asciz "2 Chocolat 1.50"
p3: .asciz "3 Fromage 2.95"
p4: .asciz "4 Gateau 1.60"
p5: .asciz "5 Yogourt 1.25"
p6: .asciz "6 Lait 1.40"
p7: .asciz "7 Muffin 1.80"
p8: .asciz "8 Arachides 2.00"
p9: .asciz "9 Bonbons 1.25"
@ Déclaration d'un tableau de chaines pour le 9 produits
produit:
.word p1
.word p2
.word p3
.word p4
.word p5
.word p6
.word p7
.word p8
.word p9
@ Déclaration du tableau contenant les quantités disponibles
disp:
.word 10,20,10,8,12,6,8,20,15
@ Déclaration du tableau des prix des produits
prix:
.word 125, 150, 295, 160, 125, 140, 180, 200, 125
Num1: .word 537
Num2: .word -237
Answer: .word 0
