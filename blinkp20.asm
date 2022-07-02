;;;; ref https://xiaolaba.wordpress.com/2013/01/20/mice-5103-this-8051-emulator-say-hello-world-again-led-blinking-about-4-years-later/

; Assembler used, ASEM-51 Version 1.3 for DOS/Windows
; Win7
; asemw blinkp20.asm
 
; 2013-01-17
; copy from http://www.npeducations.com/2011/09/how-to-blink-led-using-8051.html
; xiaolaba
; fixed divide overflow problem of MICE-5103, and test to load this blinking programm
 
; not_work ?
; LED + 330 ohm resistor, connect to P2.0 (pin21 of 40 DIP) of 8051 MCU
 
; this works,
; LED + 330 ohm resistor, connect to P1.0 (pin1 of 40 DIP) of 8051 MCU
 
org 0000h
mov P1,#00h  ; initialize the Port1 as output port
mov P2,#00h  ; initialize the Port2 as output port
top:
cpl P1.0      ; compliment the bit
cpl P2.0      ; compliment the bit
nop
nop
 
;;;; more delay, slow LED blinking, easy to visual
acall delay   ; call delay procedure
acall delay   ; call delay procedure
acall delay   ; call delay procedure
acall delay   ; call delay procedure
 
sjmp top      ; make this operation to run repeatedly
 
delay:
mov R1,#010h  ; initialize the R1 register with an immediate value 10h = 16d
mov R0,#0FFh  ; load R0 with FFh value to repeat the loop for 256 times
back:
DJNZ R0, back   ;internal loop repeates 256 times
DJNZ R1,back    ;external loop repeates 16 times
RET
END
