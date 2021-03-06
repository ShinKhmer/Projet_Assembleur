.386
.model flat, stdcall ;32 bit memory model
option casemap :none ;case insensitive
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32rt.inc
include \masm32\include\esgi32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\esgi32.lib
includelib \masm32\lib\esgi32.lib

.data
cpt	db	0
ask2	db	"Entrez la chaine a supprimer : ",0
ask1	db	"Entrez la chaine initiale : ",10,0 ; 10=code ASCII du retour chariot
trouve	db	"chaine trouvee",10,0
crlf	db	10,0
taille	db	0
taille_ch2	db	0
nbegal	db	0

.data?
ch1	db	50 dup(?)
ch2	db	10 dup(?)

.const

.code
start:

invoke StdOut,addr ask1	; affichage de "Combien de fois ?"
invoke StdIn, addr ch1,50	; lecture au clavier sauv�e dans cpt
invoke StdOut,addr ask2	; affichage de "Combien de fois ?"
invoke StdIn, addr ch2,10	; lecture au clavier sauv�e dans cpt


; Calcul de la taille de ch2
mov eax,0	; eax=indice du caract�re trait�
pour2:
	cmp ch2[eax*BYTE],0	; on compare le caract�re en cours avec la valeur 0 (fin de cha�ne)
	je fin_ch2			; s'ils sont �gaux : fin de cha�ne donc fin de traitement
	inc taille_ch2		; sinon on incr�mente la taille de ch2
	inc eax				; incr�mentation de l'indice
	jmp pour2			; on recommence
	
fin_ch2:

mov eax,0	; indice de parcours de ch1 dans eax 
mov ebx,0	; indice de parcours de ch2 dans ebx 

boucle:
	mov cl,ch1[eax*BYTE]	; cl=caract�re de ch1
	cmp cl,ch2[ebx*BYTE]	; on compare cl avec le caract�re de ch2
	je egalite		; s'ils sont �gaux, on saute au label egalite
	mov nbegal,0	; sinon on r�initialise le nombre de caract�res cons�cutifs �gaux � 0
	mov ebx,0		; on repart du d�but de ch2
	back:
	inc eax			; on incr�mente  l'indice de ch1
	cmp ch1[eax*BYTE],0	; si on n'est pas � la fin de ch1
jne boucle				; on recommence

jmp fin

egalite:
inc nbegal		; on incr�mente le nombre de caract�res �gaux cons�cutifs
inc ebx			; on avance dans ch2
mov dl,taille_ch2	
cmp nbegal,dl	; on compare nbegal avec la taille de ch2
jne back		; s'ils sont �gaux on a termin� et trouv�.

delete:
mov ch1[eax*BYTE],'-'	; on �crit le caract�re "-" dans ch1
dec eax					; on recule d'un caract�re dans ch1
dec taille_ch2			; on d�cr�mente taille_ch2
cmp taille_ch2,0		; tant que taille_ch2 >0
jne delete				; on recommence

fin:
invoke StdOut,addr ch1
invoke StdOut,addr crlf
inkey
push 0
call ExitProcess
end start