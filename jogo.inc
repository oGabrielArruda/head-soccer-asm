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
    playerObj       gameObject <>
    stopped               BYTE 0
    cooldownDash          BYTE 0
    life                  BYTE 4
    direction             BYTE 0
    walkanimationCD       BYTE 0 ; cooldown
    walksequence          BYTE 0
    dashanimationCD       BYTE 0 ; cooldown
    dashsequence          BYTE 0 
player ends

.const
    PLAYER_SIZE      EQU 48
    PLAYER_HALF_SIZE EQU PLAYER_SIZE / 2

    D_RIGHT       EQU 0 
    D_TOP         EQU 1  
    D_LEFT        EQU 2     
    D_DOWN        EQU 3
    D_DOWN_RIGHT  EQU 4
    D_DOWN_LEFT   EQU 5
    D_TOP_LEFT    EQU 6
    D_TOP_RIGHT   EQU 7

.data
    player1 player <<<100,350>,  <0,0>>, 0, 0, 4, D_RIGHT, 0, 0, 0, 0>