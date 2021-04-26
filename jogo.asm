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
     
.data
    szDisplayName db "Cotuca Soccer",0
    AppName db "Cotuca Soccer", 0
    CommandLine   dd 0
    hWnd          dd 0
    hInstance     dd 0
    buffer        db 256 dup(?)


    ;Background bitmap:
    background        dd 0

.data?

; _______________________________________________CODE______________________________________________
.code
start:

    invoke GetModuleHandle, NULL ; provides the instance handle
    mov    hInstance, eax

    invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT    
    invoke ExitProcess,eax   
    ; comentario do sergio -> coloco aqui o procedimento WinMain para criação da janela em si

    ; PROCEDURES________________________________

    ; carrega as imagens
    loadImages proc  

        invoke LoadBitmap, hInstance, 100
        mov background, eax

        ret

    loadImages endp
    ; __________________________________________

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

        ;================================
        ; Centre window at following size
        ;================================

        ; mov Wwd, 500
        ; mov Wht, 350

        ; invoke GetSystemMetrics,SM_CXSCREEN ; get screen width in pixels
        ; invoke TopXY,Wwd,eax
        ; mov Wtx, eax

        ; invoke GetSystemMetrics,SM_CYSCREEN ; get screen height in pixels
        ; invoke TopXY,Wht,eax
        ; mov Wty, eax

        ; ==================================
        ; Create the main application window
        ; ==================================
        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW, \
                            ADDR szClassName, \
                            ADDR szDisplayName,\
                            WS_OVERLAPPEDWINDOW,\
                            ;Wtx,Wty,Wwd,Wht,
                            CW_USEDEFAULT,CW_USEDEFAULT, 900, 522, \      ;tamanho da janela
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
        LOCAL Ps     :PAINTSTRUCT
        LOCAL hWin2  :DWORD
    
        ; quando esta criando
        ;if uMsg == WM_CREATE
            invoke loadImages
                        

        invoke DefWindowProc,hWin,uMsg,wParam,lParam 
        ret

    WndProc endp

end start