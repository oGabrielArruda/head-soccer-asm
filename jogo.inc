include \masm32\include\masm32rt.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \MASM32\LIB\gdi32.lib
includelib \MASM32\LIB\Comctl32.lib
includelib \MASM32\LIB\comdlg32.lib
includelib \MASM32\LIB\shell32.lib

INCLUDELIB \Masm32\Lib\msimg32.lib
INCLUDELIB \Masm32\Lib\msvcrt.lib
INCLUDELIB \Masm32\Lib\masm32.lib

include \Masm32\include\winmm.inc 

INCLUDE \Masm32\Include\msimg32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \MASM32\LIB\gdi32.lib
INCLUDELIB \Masm32\Lib\msimg32.lib
includelib \Masm32\lib\winmm.lib

point struct 
    x dd 0      
    y dd 0
point ends

gameObject struct
    pos      point <>
    speed    point <> ; horizontal and vertical speeds
gameObject ends

player struct
    playerObj             gameObject <>
    sizePoint             point <>
    stopped               BYTE 0
    jumping               BYTE 0
    cooldownDash          BYTE 0
    life                  BYTE 4
    direction             BYTE 0
    walkanimationCD       BYTE 0 ; cooldown
    walksequence          BYTE 0
    dashanimationCD       BYTE 0 ; cooldown
    dashsequence          BYTE 0 
    goals                 dd   0
player ends

ballStruct struct
    ballObj               gameObject <>
    sizePoint             point <>
ballStruct ends

golStruct struct
    top point <>
    bottom point <>
golStruct ends


.const
    PLAYER_SIZE      EQU 85
    PLAYER_HALF_SIZE EQU PLAYER_SIZE / 2

    BALL_SIZE      EQU 45
    BALL_HALF_SIZE EQU BALL_SIZE / 2


    BALL_SPEED_Y EQU -17

    D_RIGHT       EQU 0 
    D_TOP         EQU 1  
    D_LEFT        EQU 2     
    D_DOWN        EQU 3
    D_DOWN_RIGHT  EQU 4
    D_DOWN_LEFT   EQU 5
    D_TOP_LEFT    EQU 6
    D_TOP_RIGHT   EQU 7
    MAX_GOALS EQU 7
.data
    player1 player <<<100,420>,  <0,0>>, <PLAYER_HALF_SIZE, PLAYER_HALF_SIZE>, 0, 0, 4, D_RIGHT, 0, 0, 0, 0, 0 >
    player2 player <<<700,420>,  <0,0>>, <PLAYER_HALF_SIZE, PLAYER_HALF_SIZE>, 0, 0, 4, D_LEFT, 0, 0, 0, 0,0 >
    ball ballStruct <<<420,100>,  <0,0>>>
    gol1 golStruct <<30, 240>, <40, 440>>
    gol2 golStruct <<850, 240>, <840, 440>>
    auxiliar_point point <0, 0>
    