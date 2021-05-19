;    Assembler specific instructions for 32 bit ASM code

    .486                   ; minimum processor needed for 32 bit
    .model flat, stdcall   ; FLAT memory model & STDCALL calling
    option casemap :none   ; set code to case sensitive
    
    include jogo.inc

    WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD

    szText MACRO Name, Text:VARARG
    LOCAL lbl
        jmp lbl
            Name db Text,0
        lbl:
    ENDM

.const
    background equ 100
    p1 equ 1001
    p2 equ 1002
    ball_image equ 102
    CREF_TRANSPARENT  EQU 0FF00FFh
  	CREF_TRANSPARENT2 EQU 0FF0000h
    PLAYER_SPEED  EQU  6
    JUMP_SPEED EQU 20

.data
    szDisplayName db "Cotuca Soccer",0
    AppName db "Cotuca Soccer", 0
    CommandLine   dd 0
    buffer        db 256 dup(?)

    hBmp          dd    0
    p1_spritesheet    dd 0
    p2_spritesheet    dd 0
    ballBmp          dd 0
    paintstruct   PAINTSTRUCT <>
    GAMESTATE             BYTE 2

    ; Música
    ponte      db "sounds/ponte.mp3",0
    ponte_especial      db "sounds/ponte_especial.mp3",0

    ; - MCI_OPEN_PARMS Structure ( API=mciSendCommand ) -
		open_dwCallback     dd ?
		open_wDeviceID     dd ?
		open_lpstrDeviceType  dd ?
		open_lpstrElementName  dd ?
		open_lpstrAlias     dd ?

		; - MCI_GENERIC_PARMS Structure ( API=mciSendCommand ) -
		generic_dwCallback   dd ?

		; - MCI_PLAY_PARMS Structure ( API=mciSendCommand ) -
		play_dwCallback     dd ?
		play_dwFrom       dd ?
		play_dwTo        dd ?    

.data?
    hInstance HINSTANCE ?

    hWnd HWND ?
    thread1ID DWORD ?
    thread2ID DWORD ?
    
; _______________________________________________CODE______________________________________________
.code
start:

    invoke GetModuleHandle, NULL ; provides the instance handle
    mov    hInstance, eax

    ; Carregando Imagens _________________________
    invoke LoadBitmap, hInstance, background
    mov    hBmp, eax

    invoke LoadBitmap, hInstance, p1
    mov     p1_spritesheet, eax

    invoke LoadBitmap, hInstance, p2
    mov     p2_spritesheet, eax

    invoke LoadBitmap, hInstance, ball_image
    mov     ballBmp, eax

    ;_____________________________________________

    invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT    
    invoke ExitProcess,eax     

    ; PROCEDURES________________________________

    isStopped proc addrPlayer:dword
        assume edx:ptr player
        mov edx, addrPlayer

        .if [edx].playerObj.speed.x == 0  && [edx].playerObj.speed.y == 0
            mov [edx].stopped, 1
        .endif

        ret
    isStopped endp
; _____________________________________________________________________________________________________
    paintBackground proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
        LOCAL rect   :RECT
    

        ; paint background image
        invoke SelectObject, _hMemDC2, hBmp
        invoke BitBlt, _hMemDC, 0, 0, 910, 522, _hMemDC2, 0, 0, SRCCOPY


        ; paint score
        ;invoke SetBkMode, _hMemDC, TRANSPARENT
        invoke SetTextColor,_hMemDC,00FF8800h
    
        invoke wsprintf, addr buffer, chr$("%d     x     %d"), player1.goals, player2.goals
        mov   rect.left, 360
        mov   rect.top , 10
        mov   rect.right, 490
        mov   rect.bottom, 50  

        invoke DrawText, _hMemDC, addr buffer, -1, \
            addr rect, DT_CENTER or DT_VCENTER or DT_SINGLELINE
        ;invoke ReleaseDC, hWin, _hMemDC

        ret

    paintBackground endp
; _____________________________________________________________________________________________________

; _____________________________________________________________________________________________________

    paintPlayers proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
        ; ____________________________________________________________________________________________________
        ; -----------------------------       PLAYER 1      --------------------------------------------------
        ; ____________________________________________________________________________________________________
        invoke SelectObject, _hMemDC2, p1_spritesheet

        movsx eax, player1.direction
        mov ebx, PLAYER_SIZE
        mul ebx
        mov ecx, eax

        invoke isStopped, addr player1

        mov edx, 0

        mov eax, player1.playerObj.pos.x
        mov ebx, player1.playerObj.pos.y
        sub eax, PLAYER_HALF_SIZE
        sub ebx, PLAYER_HALF_SIZE

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            PLAYER_SIZE, PLAYER_SIZE, _hMemDC2,\
            edx, ecx, PLAYER_SIZE, PLAYER_SIZE, 16777215


        ; ____________________________________________________________________________________________________
        ; -----------------------------       PLAYER 2      --------------------------------------------------
        ; ____________________________________________________________________________________________________


        invoke SelectObject, _hMemDC2, p2_spritesheet

        movsx eax, player2.direction
        mov ebx, PLAYER_SIZE
        mul ebx
        mov ecx, eax

        invoke isStopped, addr player2

        mov edx, 0

        mov eax, player2.playerObj.pos.x
        mov ebx, player2.playerObj.pos.y
        sub eax, PLAYER_HALF_SIZE
        sub ebx, PLAYER_HALF_SIZE

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            PLAYER_SIZE, PLAYER_SIZE, _hMemDC2,\
            edx, ecx, PLAYER_SIZE, PLAYER_SIZE, 16777215

        ; ____________________________________________________________________________________________________
        ; ----------------------------------       BOLA     --------------------------------------------------
        ; ____________________________________________________________________________________________________

        invoke SelectObject, _hMemDC2, ballBmp

        movsx eax, player2.direction
        mov ebx, BALL_SIZE
        mul ebx
        mov ecx, eax

        mov edx, 0

        mov eax, ball.ballObj.pos.x
        mov ebx, ball.ballObj.pos.y
        sub eax, BALL_HALF_SIZE
        sub ebx, BALL_HALF_SIZE

        invoke TransparentBlt, _hMemDC, eax, ebx,\
            BALL_SIZE, BALL_SIZE, _hMemDC2,\
            edx, ecx, BALL_SIZE, BALL_SIZE, 16777215

        ret
    paintPlayers endp

; _____________________________________________________________________________________________________

    screenUpdate proc
        LOCAL hMemDC:HDC
        LOCAL hMemDC2:HDC
        LOCAL hBitmap:HDC
        LOCAL hDC:HDC

        invoke BeginPaint, hWnd, ADDR paintstruct
        mov hDC, eax
        invoke CreateCompatibleDC, hDC
        mov hMemDC, eax
        invoke CreateCompatibleDC, hDC ; for double buffering
        mov hMemDC2, eax
        invoke CreateCompatibleBitmap, hDC, 910, 522
        mov hBitmap, eax

        invoke SelectObject, hMemDC, hBitmap

        invoke paintBackground, hDC, hMemDC, hMemDC2

        invoke paintPlayers, hDC, hMemDC, hMemDC2

        invoke BitBlt, hDC, 0, 0, 910, 522, hMemDC, 0, 0, SRCCOPY

        invoke DeleteDC, hMemDC
        invoke DeleteDC, hMemDC2
        invoke DeleteObject, hBitmap
        invoke EndPaint, hWnd, ADDR paintstruct
        ret
    screenUpdate endp

; _____________________________________________________________________________________________________

    paintThread proc p:DWORD
        .WHILE GAMESTATE == 2
            invoke Sleep, 17 ; 60 FPS
            invoke InvalidateRect, hWnd, NULL, FALSE
        .endw
        ret
    paintThread endp   

; _____________________________________________________________________________________________________

    changePlayerSpeed proc uses eax addrPlayer : DWORD, direction : BYTE, keydown : BYTE
        assume eax: ptr player
        mov eax, addrPlayer

        .if keydown == FALSE
            .if direction == 1 ;a
                .if [eax].playerObj.speed.x > 7fh
                    mov [eax].playerObj.speed.x, 0 
                .endif
            .elseif direction == 2 ;s
                .if [eax].playerObj.speed.y < 80h
                    mov [eax].playerObj.speed.y, 0 
                .endif
            .elseif direction == 3 ;d
                .if [eax].playerObj.speed.x < 80h
                    mov [eax].playerObj.speed.x, 0 
                .endif
            .endif
        .else
            .if direction == 0 ; w
                .if [eax].jumping == 0  ; se o player não está pulando
                    mov [eax].jumping, 1
                    mov [eax].playerObj.speed.y, -JUMP_SPEED ; setamos a velocidade do player para o pulo
                    mov [eax].stopped, 0                      
                .endif
            ;.elseif direction == 1 ; s
            ;    mov [eax].playerObj.speed.y, PLAYER_SPEED
            ;    mov [eax].stopped, 0
            .elseif direction == 2 ; a
                mov [eax].playerObj.speed.x, -PLAYER_SPEED
                mov [eax].stopped, 0
            .elseif direction == 3 ; d
                mov [eax].playerObj.speed.x, PLAYER_SPEED
                mov [eax].stopped, 0
            .endif
        .endif

        assume ecx: nothing
        ret
    changePlayerSpeed endp

; _____________________________________________________________________________________________________

    movePlayer proc uses eax addrPlayer:dword
        assume edx:ptr player
        mov edx, addrPlayer

        assume ecx:ptr gameObject
        mov ecx, addrPlayer



        .if [edx].jumping == TRUE  ; se o player está pulando
            mov ebx, [ecx].speed.y
            inc ebx
            mov [ecx].speed.y, ebx
        .endif



        ; X AXIS ______________
        mov eax, [ecx].pos.x
        mov ebx, [ecx].speed.x
        add eax, ebx
        

        ;  se o player está dentro dos limites da tela, alteramos sua posicao
        .if eax > 0 && eax < 890
            mov [ecx].pos.x, eax
        .endif

        ; Y AXIS ______________
        mov eax, [ecx].pos.y
        mov ebx, [ecx].speed.y
        add ax, bx

        ; se o player está voltando de um pulo, e iria "para baixo" do chão
        .if eax >= 420
            mov [edx].jumping, 0 ; avisamos que ele não está mais pulando
            mov eax, 420         ; o colocamos no chão
        .endif

        mov [ecx].pos.y, eax

        assume ecx:nothing
        ret
    movePlayer endp

; _____________________________________________________________________________________________________

    moveBall proc uses eax addrBall:dword
        assume ebx:ptr ballStruct
        mov ebx, addrBall

        ; Y AXIS ______________

        .if [ebx].ballObj.pos.y < 437       ; se a bola está no ar, a puxamos (gravidade)
            mov ecx, [ebx].ballObj.speed.y
            inc ecx
            mov [ebx].ballObj.speed.y, ecx
        .endif

        .if [ebx].ballObj.pos.y >= 437                      ; se a bola bateu no chão, vamos fazer quicar          
            ;mov edx, 0
            ;mov eax, [ebx].ballObj.speed.y
            ;mov ecx, 2
            ;div ecx
            ;neg eax

            mov eax, [ebx].ballObj.speed.y              ; invertemos a velocidade da bola
            dec eax                                     ; fazendo com que ela suba
            dec eax
            dec eax
            neg eax

            mov [ebx].ballObj.speed.y, eax     
        .endif

    
        ; incrementase a speed no eax
        mov eax, [ebx].ballObj.pos.y
        mov ecx, [ebx].ballObj.speed.y
        add ax, cx

        .if eax > 437
            mov eax, 437
        .endif

        ; incrementamos a speed X
        mov edx, [ebx].ballObj.pos.x
        mov ecx, [ebx].ballObj.speed.x
        add dx, cx

        ; se a bola estiver nos limites da tela, a movemos
        .if edx > 10 && edx < 885
            mov [ebx].ballObj.pos.x, edx
        .else                               ; se a bola bateu na parede, a rebatemos
            mov ecx, ball.ballObj.speed.x
            dec ecx
            dec ecx
            neg ecx
            mov [ebx].ballObj.speed.x, ecx 
        .endif

        mov [ebx].ballObj.pos.y, eax        ; movemos o Y
        
        assume ecx:nothing
        ret 
    moveBall endp

; _____________________________________________________________________________________________________

    collide proc obj1Pos:point, obj2Pos:point, obj1Size:point, obj2Size:point
        
        mov eax, obj1Pos.x
        add eax, obj1Size.x                    ; pos1 + tamanho

        mov ebx, obj2Pos.x
        sub ebx, obj2Size.x                    ; pos2 - tamanho

        .if eax > ebx
            mov eax, obj1Pos.x
            sub eax, obj1Size.x                    ; pos1 + tamanho

            mov ebx, obj2Pos.x
            add ebx, obj2Size.x                    ; pos2 - tamanho
            .if eax < ebx
                mov edx, TRUE
            .else
                mov edx, FALSE
            .endif
        .else
            mov edx, FALSE
        .endif

        mov eax, obj1Pos.y
        add eax, obj1Size.y                    ; pos1 + tamanho

        mov ebx, obj2Pos.y
        sub ebx, obj2Size.y                    ; pos2 - tamanho

        .if eax > ebx
            mov eax, obj1Pos.y
            sub eax, obj1Size.y                    ; pos1 + tamanho

            mov ebx, obj2Pos.y
            add ebx, obj2Size.y                    ; pos2 - tamanho
            .if eax < ebx
                mov ecx, TRUE
            .else
                mov ecx, FALSE
            .endif
        .else
            mov ecx, FALSE
        .endif

        pop ebx
        pop eax

        ret
    collide endp

; _____________________________________________________________________________________________________

    verifyColliding proc

        ; Verfica a colisão dos dois players
        invoke collide, player1.playerObj.pos, player2.playerObj.pos, player1.sizePoint, player2.sizePoint
        .if edx == TRUE && ecx == TRUE                      ; se colidiu  
            ;                       PLAYER 1
            mov eax, player1.playerObj.pos.x
            mov ebx, player1.playerObj.speed.x
            add eax, ebx

            mov auxiliar_point.x, eax

            mov eax, player1.playerObj.pos.y
            mov ebx, player1.playerObj.speed.y
            add eax, ebx

            mov auxiliar_point.y, eax

            invoke collide, auxiliar_point, player2.playerObj.pos, player1.sizePoint, player2.sizePoint
            .if edx == TRUE                               ; verifica se o prox mov é válido
                mov player1.playerObj.speed.x, 0 
            .endif
            .if ecx == TRUE                               ; verifica se o prox mov é válido
                mov player1.jumping, 0
                mov player1.playerObj.speed.y, 0 
            .endif                   
        .endif

        invoke collide, player2.playerObj.pos, player1.playerObj.pos, player2.sizePoint, player1.sizePoint
        .if edx == TRUE && ecx == TRUE                      ; se colidiu  
            ;                       PLAYER 2
            mov eax, player2.playerObj.pos.x
            mov ebx, player2.playerObj.speed.x
            add eax, ebx

            mov auxiliar_point.x, eax

            mov eax, player2.playerObj.pos.y
            mov ebx, player2.playerObj.speed.y
            add eax, ebx

            mov auxiliar_point.y, eax

            invoke collide, auxiliar_point, player1.playerObj.pos, player2.sizePoint, player1.sizePoint
            .if edx == TRUE                               ; verifica se o prox mov é válido
                mov player2.playerObj.speed.x, 0 
            .endif
            .if ecx == TRUE                               ; verifica se o prox mov é válido
                mov player2.jumping, 0
                mov player2.playerObj.speed.y, 0 
            .endif                   
        .endif        

        ret
    verifyColliding endp

; _____________________________________________________________________________________________________

    ballColliding proc
    
        invoke collide, player1.playerObj.pos, ball.ballObj.pos, player1.sizePoint, ball.sizePoint
        .if edx == TRUE  && ecx == TRUE                      ; se colidiu  
            mov eax, player1.playerObj.speed.x

            .if eax == 0                                    ; se o player estiver parado
                mov eax, ball.ballObj.speed.x               ; apenas "rebatemos" a bola
                dec eax
                dec eax
                neg eax
            .else                                           ; se o player estiver em movimento
                add eax, player1.playerObj.speed.x          ; damos o chute de acordo com sua velocidade
                dec eax
                dec eax
                dec eax

            .endif

            mov ball.ballObj.speed.y, BALL_SPEED_Y
            mov ball.ballObj.speed.x, eax       
        .endif

        invoke collide, player2.playerObj.pos, ball.ballObj.pos, player2.sizePoint, ball.sizePoint
        .if edx == TRUE  && ecx == TRUE                      ; se colidiu  
            mov eax, player2.playerObj.speed.x

            .if eax == 0
                mov eax, ball.ballObj.speed.x
                dec eax
                dec eax
                neg eax
            .else
                add eax, player2.playerObj.speed.x
                dec eax
                dec eax
                dec eax

            .endif

            mov ball.ballObj.speed.y, -10
            mov ball.ballObj.speed.x, eax          
        .endif     

        ret
    ballColliding endp

; _____________________________________________________________________________________________________

    resetBall proc
        mov ball.ballObj.speed.x, 0
        mov ball.ballObj.speed.y, 0
        mov ball.ballObj.pos.x, 420
        mov ball.ballObj.pos.y, 100
        ret
    resetBall endp

; _____________________________________________________________________________________________________

    resetPositions proc
        mov player1.playerObj.pos.x, 100
        mov player1.playerObj.pos.y, 420

        mov player2.playerObj.pos.x, 700
        mov player2.playerObj.pos.y, 420

        invoke resetBall

        ret
    resetPositions endp
; _____________________________________________________________________________________________________

    verifyGoal proc uses eax addrBall:dword
        assume ebx:ptr ballStruct
        mov ebx, addrBall
        
        mov eax, [ebx].ballObj.pos.x   ; salvamos a posição da bola
        mov ecx, [ebx].ballObj.pos.y 

        .if eax > gol2.top.x && ecx > gol2.top.y    ; GOL PLAYER 1
            add player1.goals, 1
            invoke resetPositions
        .elseif eax < gol1.top.x && ecx > gol1.top.y ; GOL PLAYER 2
            add player2.goals, 1
            invoke resetPositions
        .endif
        
        assume ecx:nothing
        ret 
    verifyGoal endp

; _____________________________________________________________________________________________________

    gameManager proc p:dword
        LOCAL area:RECT

        game:
            .while GAMESTATE == 2
                invoke Sleep, 30
                ;invoke verifyColliding                
                invoke movePlayer, addr player1
                invoke movePlayer, addr player2
                invoke ballColliding
                invoke moveBall, addr ball
                invoke verifyGoal, addr ball
            .endw

        jmp game

        ret
    gameManager endp
        
    ;______________________________________________________________________________

    ; comentario do sergio -> coloco aqui o procedimento WinMain para criação da janela em si

    WinMain proc hInst     :DWORD,
                hPrevInst :DWORD,
                CmdLine   :DWORD,
                CmdShow   :DWORD

        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        LOCAL Wtx  :DWORD
        LOCAL Wty  :DWORD

        szText szClassName,"Generic_Class"
        
        ;==================================================
        ; Fill WNDCLASSEX structure with required variables
        ;==================================================

        mov wc.cbSize,         sizeof WNDCLASSEX
        mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                            or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc      ; address of WndProc
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance,      hInst               ; instance handle
        mov wc.hbrBackground,  COLOR_BTNFACE+1     ; system color
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName  ; window class name
        ; id do icon no arquivo RC
        invoke LoadIcon,hInst, IDI_APPLICATION;  500                  ; icon ID   ; resource icon
        mov wc.hIcon,          eax
        invoke LoadCursor,NULL,IDC_ARROW         ; system cursor
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

        invoke RegisterClassEx, ADDR wc     ; register the window class


        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW, \
                            ADDR szClassName, \
                            ADDR szDisplayName,\
                            WS_OVERLAPPEDWINDOW,\
                            ;Wtx,Wty,Wwd,Wht,
                            CW_USEDEFAULT,CW_USEDEFAULT, 910, 552, \      ;tamanho da janela
                            NULL,NULL,\
                            hInst,NULL

        mov   hWnd,eax  ; copy return value into handle DWORD

        invoke LoadMenu,hInst,600                 ; load resource menu
        invoke SetMenu,hWnd,eax                   ; set it to main window

        invoke ShowWindow,hWnd,SW_SHOWNORMAL      ; display the window
        invoke UpdateWindow,hWnd                  ; update the display

        ;===================================
        ; Loop until PostQuitMessage is sent
        ;===================================

        StartLoop:
        invoke GetMessage,ADDR msg,NULL,0,0         ; get each message
        cmp eax, 0                                  ; exit if GetMessage()
        je ExitLoop                                 ; returns zero
        invoke TranslateMessage, ADDR msg           ; translate it
        invoke DispatchMessage,  ADDR msg           ; send it to message proc
        jmp StartLoop
        ExitLoop:

        return msg.wParam

    WinMain endp

    WndProc proc hWin  :DWORD,
                uMsg   :DWORD,
                wParam :DWORD,
                lParam :DWORD

        LOCAL hDC    :DWORD
        LOCAL memDC  :DWORD
        LOCAL memDCp1 : DWORD
        LOCAL hOld   :DWORD
        LOCAL hWin2  :DWORD
        LOCAL direction : BYTE
        LOCAL keydown   : BYTE
        mov direction, -1
        mov keydown, -1

        
    
        ; quando esta criando
        .if uMsg == WM_CREATE
            mov eax, offset gameManager 
            invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread1ID 
            invoke CloseHandle, eax 

            mov eax, offset paintThread 
            invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread2ID 
            invoke CloseHandle, eax 

            ; Música
            mov   open_lpstrDeviceType, 0h         ;fill MCI_OPEN_PARMS structure
            mov   open_lpstrElementName,OFFSET ponte
            invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
            cmp   eax,0h                 	
            je    next		
            next:	
                invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_NOTIFY,offset play_dwCallback			


    

        .elseif uMsg == WM_PAINT
            invoke screenUpdate

        .elseif uMsg == WM_DESTROY                                        ; if the user closes our window 
            invoke PostQuitMessage,NULL                                   ; quit our application 

        ; Quando a tecla sobe
        .elseif uMsg == WM_KEYUP

            ; ____________________________________________________________________________________________________
            ; -----------------------------       PLAYER 1         -----------------------------------------------
            ; ____________________________________________________________________________________________________
            .if (wParam == 77h || wParam == 57h || wParam == 20h) ;w
                mov keydown, FALSE
                mov direction, 0                

            .elseif (wParam == 61h || wParam == 41h) ;a
                mov keydown, FALSE
                mov direction, 1

            .elseif (wParam == 64h || wParam == 44h) ;d
                mov keydown, FALSE
                mov direction, 3
            .endif

            .if direction != -1
                invoke changePlayerSpeed, ADDR player1, direction, keydown
                mov direction, -1
                mov keydown, -1
            .endif


            ; ____________________________________________________________________________________________________
            ; -----------------------------       PLAYER 2         -----------------------------------------------
            ; ____________________________________________________________________________________________________

            .if (wParam == VK_UP) ;w
                mov keydown, FALSE
                mov direction, 0                

            .elseif (wParam == VK_LEFT) ;a
                mov keydown, FALSE
                mov direction, 1

            .elseif (wParam == VK_RIGHT) ;d
                mov keydown, FALSE
                mov direction, 3
            .endif

            .if direction != -1
                invoke changePlayerSpeed, ADDR player2, direction, keydown
                mov direction, -1
                mov keydown, -1
            .endif            
            
        ;quando a tecla desce
        .elseif uMsg == WM_KEYDOWN
            ; ____________________________________________________________________________________________________
            ; -----------------------------       PLAYER 1         -----------------------------------------------
            ; ____________________________________________________________________________________________________

            .if (wParam == 57h || wParam == 20h) ; w
                mov keydown, TRUE
                mov direction, 0

            .elseif (wParam == 41h) ; a
                mov keydown, TRUE
                mov direction, 2

            .elseif (wParam == 44h) ; d
                mov keydown, TRUE
                mov direction, 3

            .elseif (wParam == 51h)
                mov ball.ballObj.speed.x, 0
                mov ball.ballObj.speed.y, 0
                mov ball.ballObj.pos.x, 420
                mov ball.ballObj.pos.y, 100

            .endif

            .if direction != -1
                invoke changePlayerSpeed, ADDR player1, direction, keydown
                mov direction, -1
                mov keydown, -1
            .endif



            ; ____________________________________________________________________________________________________
            ; -----------------------------       PLAYER 2         -----------------------------------------------
            ; ____________________________________________________________________________________________________


            .if (wParam == VK_UP) ; w
                mov keydown, TRUE
                mov direction, 0

            .elseif (wParam == VK_LEFT) ; a
                mov keydown, TRUE
                mov direction, 2

            .elseif (wParam == VK_RIGHT) ; d
                mov keydown, TRUE
                mov direction, 3
            .endif

            .if direction != -1
                invoke changePlayerSpeed, ADDR player2, direction, keydown
                mov direction, -1
                mov keydown, -1
            .endif

        .else
            invoke DefWindowProc,hWin,uMsg,wParam,lParam 
        .endif
        ret

    WndProc endp

end start