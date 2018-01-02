.686 
.model flat,stdcall 
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc 
include \masm32\include\gdi32.inc
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 

includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib
include masm32.inc
includelib masm32.lib

.const

largeur	equ	600
hauteur	equ	600

.data 
ps	PAINTSTRUCT	<0>
hdc	HDC	0
ClassName	db "Parent Class Name",0
ClassName_F db "SimpleWinClass",0 	; classe de type SimpleWinClass (fenêtre simple)
AppName  db "Fenêtre de dessin",0 
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
			
			mov x, 250
			mov y, 250
            mov ecx, 0

			; boucle:
            ; segment 1
			invoke MoveToEx,hdc,x,y,NULL	; place la pointe de crayon aux coordonnées (x,y)
			mov eax,100	; eax=100
			add eax,x	; eax=eax+x
			mov x,eax	; x=eax				; x = 350
			
			invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)
                
                
            ; segment 2
            invoke MoveToEx,hdc,x,y,NULL	; place la pointe de crayon aux coordonnées (x,y)
            mov eax,-100	; eax=-100
			add eax,y	; eax=eax+y
			mov y,eax	; y=eax				; y = 150
            invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)
                
                
            ; segment 3
            invoke MoveToEx,hdc,x,y,NULL	; place la pointe de crayon aux coordonnées (x,y)
            mov eax,-100	; eax=-100
			add eax,x	; eax=eax+x
			mov x,eax	; x=eax				; x = 250
            invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)
                 
                
            ; segment 4
            invoke MoveToEx,hdc,x,y,NULL	; place la pointe de crayon aux coordonnées (x,y)
            mov eax,100	; eax=100
			add eax,y	; eax=eax+y
			mov y,eax	; y=eax				; y = 250
            invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)

            
            ; se placer sur le bord en bas à droite du carré
            mov eax,100
            add eax,x
            mov x,eax                       ; x = 350
            
            ; segment 5
            invoke MoveToEx,hdc,x,y,NULL	; place la pointe de crayon aux coordonnées (x,y)
            
            mov eax,30	; eax=30
			add eax,x	; eax=eax+x
			mov x,eax	; x=eax				; x = 400
                
            mov eax,-50	; eax=-50
			add eax,y	; eax=eax+y
			mov y,eax	; y=eax				; x = 200
            invoke LineTo,hdc,x,y			; trace une ligne de la position précédente à (x,y)

            
				
        	invoke EndPaint, hWnd, ADDR ps ; fin du dessin de la fenêtre
        	
    fin_messages:
    xor    eax,eax 
    ret 
WndProc endp 
push 0
call ExitProcess      	
end start