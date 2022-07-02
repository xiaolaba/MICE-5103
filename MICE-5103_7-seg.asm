;************************************************
;* author: xiao_laba@yahoo.com.cn
;;;; https://xiaolaba.wordpress.com/2013/01/28/mice-5103-software-sigma-delta-adc-experiment/

; test MICE-5103 7-seg LED display
; 2013-JAN-27
; tested
; assembler : ASEMW-51, http://plit.de/cgi-bin/asem-51/wwwasem.cgi
; how to assemble the code,
;    asemw MICE-5103_7-seg.asm
;************************************************
 
PORT_A EQU 0CF01H
PORT_B EQU 0CF02H
PORT_C EQU 0CF03H
 
display_buffer EQU 0DE00H
 
ORG 0000H
SJMP On_Reset
 
ORG 0003H ;外部中斷 INT0
RETI
 
ORG 000BH ;TIMER 0 溢出中斷
AJMP Timer0Handler
 
;USING 0 ;使用Register bank 0
 
On_Reset:
 
MainLOOP:
MOV A,#0H
MOV 03EH,A
 
MOV A,#1H
MOV 03DH,A
 
MOV A,#2H
MOV 03CH,A
 
MOV A,#3H
MOV 03BH,A
 
MOV A,#4H
MOV 03AH,A
 
MOV A,#5H
MOV 039H,A
 
LCALL display_buffer
LCALL display_buffer
LCALL display_buffer
LCALL display_buffer
LCALL display_buffer
LCALL display_buffer
LCALL display_buffer
LCALL display_buffer
LCALL display_buffer
LCALL display_buffer
 
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
 
AJMP MainLOOP
 
delay:
mov R1,#010h  ; initialize the R1 register with an immediate value 10h = 16d
mov R0,#0FFh  ; load R0 with FFh value to repeat the loop for 256 times
back:
DJNZ R0, back   ;internal loop repeates 256 times
DJNZ R1, back   ;external loop repeates 16 times
RET
 
; add this to a compilation success
Timer0Handler:
ret
 
END
