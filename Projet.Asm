.686 
.model flat,stdcall 
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
projection_X proto :DWORD, :DWORD
projection_Y proto :DWORD, :DWORD

include \masm32\include\windows.inc 
include \masm32\include\gdi32.inc
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
include \masm32\include\esgi32.inc

includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\esgi32.lib
include masm32.inc
includelib masm32.lib

.const
largeur	equ	800
hauteur	equ	650
dist equ 250
Xoff equ 250
Yoff equ 250
Zoff equ 250
mult_3 equ 3
   
    
.data 
ps	PAINTSTRUCT	<0>
hdc	HDC	0
ClassName	db "Parent Class Name",0
ClassName_F db "SimpleWinClass",0 	; classe de type SimpleWinClass (fenêtre simple)
AppName  db "Fenêtre de dessin",0 
cnt_boucle dd 0
cnt_objet dd 0
cnt_faces dd 0
result dd 0
string db "face numero:",0
space db " ",0
;PARAMETRES DU CUBE
			; x     y     z	 NUMERO DE POINT
objet	dd	-100, -100, -100,		;0
			100, -100, -100,		;1
			100, 100, -100,			;2
			-100, 100, -100,		;3
			100, -100, 100,			;4
			-100, -100, 100,		;5
			-100, 100, 100,			;6
			100, 100, 100			;7
			;SOMMETS		NUMERO DE LA FACE
faces dd 	0, 1, 2, 3,				;0
			1, 4, 7, 2,				;1
			4, 5, 6, 7,				;2
			5, 0, 3, 6,				;3
			5, 4, 1, 0,				;4
			3, 2, 7, 6				;5

.data? 
x	dd	?
y	dd	?
z 	dd  ?
hInstance HINSTANCE ? 
CommandLine LPSTR ? 


.const 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    
    mov   	wc.cbSize, SIZEOF WNDCLASSEX	; taille de la structure de la window class
	mov   	wc.style, CS_HREDRAW or CS_VREDRAW ; style de la fenêtre : redessinée si redim. ou mouv. horizontal ou vertical
	mov   	wc.lpfnWndProc, OFFSET WndProc	;pointeur vers la fonction de gestion de la fenêtre
	mov   	wc.cbClsExtra, NULL	; nombre de bits supplémentaires à allouer après la window class
	mov   	wc.cbWndExtra, NULL	; nombre de bits supplémentaires à allouer après l'instance de fenêtre
	push  	hInst 
    pop   	wc.hInstance ; un handle de l'instance qui contient la fonction de gestion de la fenêtre
	mov   	wc.hbrBackground, COLOR_WINDOW+1	; handle de la class backgroune brush utilisé pour le fond de la fenêtre
	mov   	wc.lpszMenuName, NULL	; pointeur vers une chaîne précisant le nom de la ressource menu name
	mov   	wc.lpszClassName, OFFSET ClassName ; pointeur vers le nom de la classe de la fenêtre
	
    invoke 	LoadIcon, NULL, IDI_APPLICATION ; arg1=handle vers le module contenant l'icone à charger, NULL pour une icone prédéfinie, arg2=nom del'icone à charger ou icone prédéfinie 
	
	mov   	wc.hIcon, eax	; un handle de la classe icon (vers une ressource de type icon)
	mov   	wc.hIconSm, eax	; un handle de la classe small icon (vers une ressource de type icon)
	
	invoke 	LoadCursor, NULL, IDC_ARROW	; arg1=handle vers le module contenant le curseur à charger, NULL pour un curseur prédéfini, arg2=nom du curseur à charger ou curseur prédéfini
	
	mov   	wc.hCursor, eax	; un handle de la classe cursor (vers une ressource de type cursor)
	
	invoke 	RegisterClassEx, addr wc	; enregistre la window class définie au-dessus

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName, \ 
                        ADDR AppName, WS_OVERLAPPEDWINDOW + WS_HSCROLL + WS_VSCROLL,\ 
                        CW_USEDEFAULT, CW_USEDEFAULT,\ 
                        largeur,hauteur,NULL,NULL, hInst,NULL 
    
    mov   	hwnd, eax	; eax=valeur de retour de CreateWindowEx, copiée dans hwnd 
    
	invoke 	ShowWindow, hwnd, SW_SHOWNORMAL ; handle de la fenêtre
											; mode d'affichage de la fenêtre
    
    messages:
        invoke GetMessage, ADDR msg,NULL,0,0 
        cmp eax,0
        jle fin_boucle 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    jmp messages
    fin_boucle:
    mov     eax,msg.wParam 
    ret 
WinMain endp
        
; fonctions de projection astrale
projection_X proc x1:DWORD, z1:DWORD
	
    ;X' = (df*x)/(z+Zoff)+Xoff
    mov ebx,x1
    ; ajout de Xoff
    mov eax,[ebx]
    add eax,Xoff
    mov [ebx],eax
    ; ici x1 = x1 + Xoff
    mov eax,dist
    imul eax,[ebx]        ; calcul df * x, résultat dans eax
    add z1,Zoff    ; z = z + Zoff
    mov edx,0     ; pour la division
    idiv z1        ; on divise eax par z, le reste sera dans edx, le résultat dans eax
    add eax,Xoff 
    mov [ebx],eax
            
    ret
        
projection_X endp

projection_Y proc y1:DWORD, z2:DWORD
	
    ;Y' = (df*y)/(z+Zoff)+Yoff
    mov ebx, y1
    ; ajout de Yoff
    mov eax,[ebx]
    add eax,Yoff
    mov [ebx],eax
    ; ici y1 = y1 + Yoff
    mov eax,dist    
    imul eax,[ebx]         ; calcul df * y, résultat dans eax
    add z2,Zoff    ; z = z + Zoff
    mov edx,0     ; pour la division
    idiv z2        ; on divise eax par z, le reste sera dans edx, le résultat dans eax
    add eax,Yoff 
    mov [ebx], eax
    
    ret

projection_Y endp

repere proc
    ; tracer un repère
    mov z,-100
    mov x,0
    invoke projection_X, addr x, z  ; appel de la fonction de projection en x
    mov y,0
    invoke projection_Y, addr y, z  ; appel de la fonction
	invoke MoveToEx,hdc,x,y,NULL	; place la pointe de crayon aux coordonnées (x,y)
			
	mov x, 50
	invoke projection_X, addr x, z   ;appel de la fonction
	invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)
			
    mov x,0
    invoke projection_X, addr x, z  ; appel de la fonction de projection en x
    mov y,0
    invoke projection_Y, addr y, z  ; appel de la fonction
    invoke MoveToEx,hdc,x,y,NULL	; place la pointe de crayon aux coordonnées (x,y)
			
	mov y, 50
	invoke projection_Y, addr y, z   ;appel de la fonction
	invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)
	; fin du tracé de repère
	
	
	ret

repere endp
            
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    
    cmp uMsg,WM_DESTROY	; demande de fermeture de la fenêtre (clic sur croix rouge)
    je destroy
    cmp uMsg,WM_PAINT	; message WM_PAINT envoyé à chaque rafraîchissement de la fenêtre
    je paint
    invoke DefWindowProc,hWnd,uMsg,wParam,lParam ; si aucun des messages précédents
    ret 
    
    destroy:
    	invoke PostQuitMessage,NULL
    	
    jmp fin_messages 
    

    paint:
    	   	invoke BeginPaint, hWnd, ADDR ps	; lance le dessin de la fenêtre
			mov hdc, eax	; BeginPaint retourne le handle du contexte où on dessine
			
            ;invoke repere;
			
			mov cnt_objet,0	; compteur
			mov cnt_faces,0
			mov cnt_boucle,0
			
			
            ; point de départ du crayon
            init_crayon:
            	mov cnt_boucle,0
            	mov ecx,0
            	invoke StdOut, addr string
            	invoke StdOut_int, cnt_faces
            	invoke StdOut, addr space
            	mov ecx,cnt_faces			; récupération du compteur de face
            	mov ecx,faces[ecx*DWORD]	; récupération de la face désignée
            	imul ecx,mult_3				; ecx = ecx * 3
            	add ecx,2					; ecx = ecx + 2 => obtenir z
            	invoke StdOut_int, ecx
            	mov eax,objet[ecx*DWORD]	; récupération de z
            	mov z,eax
            	add z,Zoff
            	sub ecx,2					; ecx = ecx - 2 => pour récupérer x
            	mov eax,objet[ecx*DWORD]
            	mov x,eax
            	invoke projection_X,addr x,z  ; appel de la fonction de projection
            	inc ecx						; ecx = ecx + 1 => pour récupérer y
            	mov eax,objet[ecx*DWORD]
            	mov y,eax
            	invoke projection_Y,addr y,z  ; appel de la fonction de projection  
            	
            	inc cnt_faces
	            
				invoke MoveToEx,hdc,x,y,NULL	; place la pointe de crayon aux coordonnées (x,y)
			
			; tracer les lignes d'une face
			trace_line:
				mov ecx,0
            	invoke StdOut, addr string
            	invoke StdOut_int, cnt_faces
            	invoke StdOut, addr space
            	mov ecx,cnt_faces			; récupération du compteur de face
            	mov ecx,faces[ecx*DWORD]	; récupération de la face désignée

            	imul ecx,mult_3				; ecx = ecx * 3
            	add ecx,2					; ecx = ecx + 2 => obtenir z
            	mov eax,objet[ecx*DWORD]	; récupération de z
            	mov z,eax
            	add z,Zoff
            	sub ecx,2					; ecx = ecx - 2 => pour récupérer x
            	mov eax,objet[ecx*DWORD]
            	mov x,eax
            	invoke projection_X,addr x,z  ; appel de la fonction de projection
            	inc ecx						; ecx = ecx + 1 => pour récupérer y
            	mov eax,objet[ecx*DWORD]
            	mov y,eax
            	invoke projection_Y,addr y,z  ; appel de la fonction de projection  
            	
            	invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)
            	
				inc cnt_faces
				inc cnt_boucle
				cmp cnt_boucle, 3
				jb trace_line
				
			face_trace_last_line:
				mov ecx,0
            	mov ecx,cnt_faces			; récupération du compteur de face
            	sub ecx, 4
            	mov ecx,faces[ecx*DWORD]	; récupération de la face désignée

            	imul ecx,mult_3				; ecx = ecx * 3
            	add ecx,2					; ecx = ecx + 2 => obtenir z
            	mov eax,objet[ecx*DWORD]	; récupération de z
            	mov z,eax
            	add z,Zoff
            	sub ecx,2					; ecx = ecx - 2 => pour récupérer x
            	mov eax,objet[ecx*DWORD]
            	mov x,eax
            	invoke projection_X,addr x,z  ; appel de la fonction de projection
            	inc ecx						; ecx = ecx + 1 => pour récupérer y
            	mov eax,objet[ecx*DWORD]
            	mov y,eax
            	invoke projection_Y,addr y,z  ; appel de la fonction de projection  
            	
            	invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)
            	
            	cmp cnt_faces, 20
            	jb init_crayon
        	
        	
        	invoke EndPaint, hWnd, ADDR ps ; fin du dessin de la fenêtre
        	
        	
    fin_messages:
    xor    eax,eax 
    ret 
WndProc endp 
push 0
call ExitProcess      	
end start