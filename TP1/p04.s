@ File: AddMain.s
.text
.global _start
.extern myAdd

_start:
								@ r9 et r8 contient le code la touche pesée --> 0 au départ
	BL initialise 				@ Appel la routine initialise

	loop: 						@ boucle principale qui tourne tant que nProd > 0
	swi 0x203 					@ Vérifier si un touche a été pesée
	CMP r0, #0					@ r0 == 0 ?
	BEQ bouton1 				@ SI NON r0 != 0 --> passer aux boutons
	BL keypressed 				@ Si OUI, appeler la routine keypressed qui gère la pression des touches
	b findeboucle 				@ Appel la routine findeboucle

bouton1:
	swi 0x202 					@ Un bouton a été pesé?
	cmp r0, #0					@ Si r0 == 0 Aucune boucle na été préssé.
	BEQ findeboucle 			@ Si r0 == 0 appeler la routine findeboucle
	cmp r0, #1 					@ OUI : Est-ce le bouton #1 ? r0 == 1 ?
	BNE bouton2 				@ NON ==> bouton2 a été pesé --> donner le change
	bl proceedcommande 			@ OUI : traiter la commande
	b findeboucle				@Saute à findeboucle

bouton2:
	bl change 					@ Appel la routine change pour donner le change

findeboucle:
								@ A-t-on fini?
	LDR r1, =nProd 				@ Charger le nombre de produits en inventaire
	LDR r1, [r1]				@ Mettre la valeur dans r1
	CMP r1, #0 					@ Sil ny a plus rien, quitter r1 == r0
	BNE loop					@Si non on rappel le début de la loop
	SWI 0x11 					@Si oui arrêter le programme



@ ==========initialise===================================
@ routine qui procède à linitialisation des variables
@ La seule variable à initialiser est le nombre de produits
@ en inventaire (disp). Pour ce faire, il faut additionner
@ les inventaires de chaque produit.

initialise:
	STMFD sp!,{lr} 				@Sauvegarde de l environement précedent
	LDMFD sp!,{pc}				@Charge l environement précedent

@ ===========keypressed===================================
@ Routine qui traite une touche du clavier.
@ Ici, on détermine quelle touche a été pesée.
@ Si cest un chiffre de 1 à 9, on inscrit le chiffre dans r9 et on met r8 à 0.
@ Si cest de la monnaie, on incrit le montant dans r8 et on met r9 à 0.
@ Si cest une valeur ilégale, on remet les registre à 0 et on affiche un message

keypressed:
	STMFD sp!,{lr}  			@Sauvegarde de l environement précedent
	LDMFD sp!,{pc}				@Charge l environement précedent


@============proceedcommande==================================
@ Routine qui vérifie q une action a été choisie et appel les routines makecomande et addmoney si une action est à faire.
@

proceedcommande:
	STMFD sp!,{r0-r2,lr}	     	@Sauvegarde de l environement précedent
	LDMFD sp!,{r0-r2,pc} 			@Charge l environement précedent

@==========change===============================================
@Routine qui rend la monnaie
@Affiche un message derreur si il ny a pas de monnaie à rendre
@

change:
	STMFD sp!,{r5-r7,lr} 				@Sauvegarde de l environement précedent
	LDMFD sp!,{r5-r7,pc} 				@Charge l environement précedent



; ============= UDiv =======================================
; Routine qui effectue une division entière (non-signée).
; Cette routine ne perturbe le contenu daucun registre à
; lexception de
; r0 : le reste de la division
; r1 : le quotient
; r2 : code derreur (1 --> division par zéro)
; Pour utiliser la routine, placer le dividende dans r0 et
; le diviseur dans r1

UDiv:
	STMFD sp!, {r4, lr}
	MOV r2, #0 						@ par défaut, pas derreur
	MOVS r1, r1 					@ tester si le diviseur = 0
	BNE DivOK
	MOV r2, #1 						@ mettre le code derreur à 1
	BAL EndDiv
	DivOK: MOV r4, #0 				@ init le quotient à 0

PasFini:
	ADD r4, r4, #1 					@ incrémenter le quotient
	SUBS r0, r0, r1 				@ Dividende = dividende – diviseur
	BCS PasFini 					@ Dividende >= 0 ==> pas fini!
	ADD r0, r0, r1 					@ On a soustrait une fois de trop ==> restaurer
	SUB r4, r4, #1 					@ On corrige le quotient
	MOV r1, r4 						@ le quotient est mis dans r1

EndDiv:
	LDMFD sp!, {r4, pc}


.data

@ Déclaration des produits
p0: .asciz "Code   Description   Prix   Disp."
p1: .asciz " 1     Chips         1.25"
p2: .asciz " 2     Chocolat      1.50"
p3: .asciz " 3     Fromage       2.95"
p4: .asciz " 4     Gateau        1.60"
p5: .asciz " 5     Yogourt       1.25"
p6: .asciz " 6     Lait          1.40"
p7: .asciz " 7     Muffin        1.80"
p8: .asciz " 8     Arachides     2.00"
p9: .asciz " 9     Bonbons       1.25"

@ Déclaration dun tableau de chaines pour le 9 produits
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
disp: .word 2,3,6,4,4,2,1,1,1

@ Déclaration du tableau des prix des produits
prix: .word 125, 150, 295, 160, 125, 140, 180, 200, 125
monnaie: .word 0, 200, 100, 25, 10, 0, 0, 0
solde: .word 0
soldemax: .word 995
nProd: .word 9

@Solde
strsolde: .asciz "Votre solde est de :    .     $"

@Messages d erreurs
ErrArgent: .asciz   "Pas de tune        "
Errdisp: .asciz     "Plus de produit    "
ErrAction: .asciz   "Aucune selection   "
ErrToMoney: .asciz  "Trop dbillet Mamen"
Errtouch: .asciz    "Mauvaise touche    "

.end
