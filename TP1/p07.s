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
	mov r9,#0					@Donne la valeur 0 à r9
	mov r8,#0					@Donne la valeur 0 à r8
	bl printdata 				@Appel la routine printdata qui affiche les donnée à lécran
	LDMFD sp!,{pc}				@Charge l environement précedent

@ ===========keypressed===================================
@ Routine qui traite une touche du clavier.
@ Ici, on détermine quelle touche a été pesée.
@ Si cest un chiffre de 1 à 9, on inscrit le chiffre dans r9 et on met r8 à 0.
@ Si cest de la monnaie, on incrit le montant dans r8 et on met r9 à 0.
@ Si cest une valeur ilégale, on remet les registre à 0 et on affiche un message

keypressed:
	STMFD sp!,{lr}  			@Sauvegarde de l environement précedent
	mov r9,#0 					@Donne la valeur 0 à r9
	mov r8,#1					@Donne la valeur 1 à r8
findtouch:
	cmp r0,r8 					@Compage r0 et r8
	add r8,r8,r8				@Additionne r8 et r8 dans r8 (r8 = r8*2)
	add r9,r9,#1 				@Additionne 1 à r9 dans r9
	bne findtouch 				@Si r0 =! r8 au moment de cmp Saute à findtouch
	mov r0,r9					@
	mov r1,#4
	bl UDiv
	cmp r0,#0
	beq keymonaie
	cmp r1,#3
	beq badKey
	sub r9,r9,r1
	mov r8,#0
	b endkeypressed
keymonaie:
	mov r8,r1
	mov r9,#0
	b endkeypressed
badKey:
	ldr r2,=Errtouch
	mov r0,#5						@Déternime les ordonées pour l affichage
	mov r1,#11						@Détermine les abscises pour l affichage
	swi 0x204						@
	mov r9,#0
	mov r8,#0
endkeypressed:
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


@=============printdata==================================
@Routine qui affiche les totalités des infomations à l ecran
@ -le tableau produit (tableau de la description des produits)
@ -le tableau disp (tableau de disponibilitées des produits)
@ -le solde
@

printdata:
	STMFD sp!,{r0-r5,lr}  				@Sauvegarde de l environement précedent
	mov r0,#0
	mov r1,#0
	swi 0x206 							@Efface l ecran
	mov r1,#0							@Détermine les abscices pour l affichage
	ldr r2,=p0							@Récupère l adresse de p0 dans r2 pour l afficher
	swi 0x204							@Affiche à lecran en fonction de r0, r1 et r2 (si r2 est un interger)
	mov r1,#1							@Détermin les abscides pour l'affichage
	ldr r4,=disp 						@Recupère l adresse de disp dans r4
	ldr r3,=produit 					@recupère l adresse de produit dans r3

printdataloop:
	mov r0,#0							@Déternime les ordonées pour l affichage
	ldr r2,[r3]							@Récupère dans r2 la valeur à l adresse stocker dans r3
	swi 0x204							@Affiche à lecran en fonction de r0, r1 et r2 (si r2 est un interger)
	mov r0,#30							@Déternime les ordonées pour l affichage
	ldr r2,[r4]							@Recupère la valeur à l adresse
	swi 0x205							@Affiche à lecran en fonction de r0, r1 et r2 (si r2 est une string)
	add r4,r4,#4						@Avance de 4octects dans l'adresse de disp (va au int suivant du tableau des disponibilitées)
	add r3,r3,#4						@Avance de 4octects dans l'adresse de produit (va au int suivant du tableau de produits)
	add r1,r1,#1						@Ajoute 1 à r1
	cmp r1,#10							@Compage r1 et la valeur 10
	bne printdataloop					@ Si r1 != 10 il reste des produit à afficher (Saute à printdataloop)
										@Affichage du solde
	mov r0,#0							@Déternime les ordonées pour l affichage
	mov r1,#12							@Détermine les abscises pour l affichage
	ldr r2,=strsolde 					@Recupère l adresse de strsolde dans r2 (pour l affiche)
	swi 0x204							@Affiche à lecran en fonction de r0, r1 et r2 (si r2 est un interger)
	ldr r0,=solde 						@Recupère l adresse de solde dans r0
	ldr r0,[r0] 						@Récupère la valeur dans r0 à ladresse stocker dans r0
	mov r1,#100							@Donne la valeur 100 à r1 pour la routine Udiv (Correspond au diviseur)
	bl UDiv 							@Appel la routine Udiv
	mov r2,r1 							@Donne la valeur de r1 à r2 (résulat de la division et valeur à afficher à l ecran)
	mov r3,r0 							@Donne la valeur de r0 à r3 (reste de la division)
	mov r0,#23							@Déternime les ordonées pour l affichage
	mov r1,#12							@Détermine les abscises pour l affichage
	swi 0x205							@Affiche à lecran en fonction de r0, r1 et r2 (si r2 est une string)
	mov r5,#10
	SUBS r4,r3,r5 						@Vérifie si r3 - r5 > 0 et met la valeur dans r4
	bcs endofsolde						@si r3 - r5 > 0 saute à endofsolde
	mov r2,#0							@Donne la valeur 0 à r2 (valeur à écrire à l écrant)
	mov r0,#25							@Déternime les ordonées pour l affichage
	swi 0x205							@Affiche à lécran en fonction de r0, r1 et r2 (si r2 est une string)
	mov r0,#26							@Déternime les ordonées pour l affichage
	b endofsolde2						@Saute à endofsolde2
endofsolde:
	mov r0, #25 						@Détermine l'axe des ordonées pour l affichage
endofsolde2:
	mov r2,r3							@Donne la valeur de r3-->(cent) à r2 (valeur à écrire à l écran
	swi 0x205							@Affiche à lecran en fonction de r0, r1 et r2 (si r2 est une string)
	LDMFD sp!,{r0-r5,pc} 				@Charge l environement précedent

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
