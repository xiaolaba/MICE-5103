
;************************************************
;;;; https://xiaolaba.wordpress.com/2013/01/28/mice-5103-software-sigma-delta-adc-experiment/

;* Sigma-Delta ADC experiment with generic 8051 core and LM311 comparator
;* author: xiao_laba@yahoo.com.cn
; reading and learning, include more comments for better understanding
; 2012-DEC-07
; 2013-JAN-27, test rig setup for 8051 test and debug
; last modification : 2013-JAN-27
; assembler : ASEMW-51, http://plit.de/cgi-bin/asem-51/wwwasem.cgi
; how to assemble the code,
;    asemw sigma-delta-adc-8051-LM311.asm
 
;************************************************
 
; reference and the orginal idea of code:
; software Sigma-Delta ADC for AT89C2051
; http://5.13.blog.163.com/blog/static/335445652007929113450285/
; Sigma-Delta ADC Version 1.0a *
; 作者: jimweaver@nbip.net *
; 測量範圍: DC 18V~30V *
; 最近修改: 2003-12-29 *
;************************************************
 
; this for 89c2051 only, as it has internal comparator
;ADC_CON BIT P3.7 ; RC 充電引腳
;COM_OUT BIT P3.6 ; AT89C2051特有的, P3.6無外接引腳, P1.0/P1.1兩腳接內部比
; 較器, 比較輸出在P3.6讀取
; 當P3.6 = 1, 跳回上面Precharge:, 繼續充電
; 當P3.6 = 0, Vc > Vin, 表示AIN-的電壓高於AIN+, 執行下面
; 一行指令, 開始 ADC
 
; my confiiguration, for Intel P8051AH and it should be in general
; no internal comparator, use LM311 instead external
ADC_CON BIT P1.0 ; RC 充電引腳, P1.0 must set to outpout pin
COM_OUT BIT P1.6 ; LM311 COMparator OUTput connect to P1.6 (input pin)
 
; MICE-5103 8051 emualator definnation
PORT_A EQU 0CF01H ;8155 port define, should be no uses
PORT_B EQU 0CF02H ;8155 port define, should be no uses
PORT_C EQU 0CF03H ;8155 port define, should be no uses
display_ADC_result EQU 0DE00H ; 7-SEG LED display subroutine, put bytes at
; 0x3EH-0x39H to LED, each byte for each LED
 
;ISEG AT 60H ;堆棧起始
;Stack: DS 20H ;堆棧大小
 
;CSEG
ORG 0000H
SJMP On_Reset
 
ORG 0003H ;外部中斷 INT0
RETI
 
ORG 000BH ;TIMER 0 溢出中斷
AJMP Timer0Handler
 
;USING 0 ;使用Register bank 0
 
On_Reset:
;    MOV SP,#(Stack-1) ;初始化堆棧指針
;    MOV SP,#5f ;初始化堆棧指針
 
mov P1,#0f0h  ; p1.0 output, p1.6 input
CLR ADC_CON       ;ADC_CON=0, C5 discharging; ADC_CON拉低,電容放電
 
MainLOOP:
ACALL SigmaDeltaADC
 
;call many times, then naked eyes can visual the digits of 7-seg LED
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
LCALL display_ADC_result
 
SJMP MainLOOP
 
; add this to a compilation success
Timer0Handler:
ret
 
;************************************************
;* 名稱:SigmaDeltaADC *
;* 功能:測量電池電壓 *
;* 參數:無 *
;* 返回:R0R1: 電池電壓 *
;* 影響:A,PSW,R0,R1,R6,R7 *
;************************************************
 
SigmaDeltaADC:
;ADC過程不允許中斷,所以要關中斷
CLR EA ;屏蔽所有中斷
 
Precharge: ;預充電,令Vc=Vin, Vc = 電容C5的電壓, Vin=待測的電壓
SETB ADC_CON      ; 設定 ADC_CON 輸出 HIGH 大約電壓為 VCC(+5V), 透過 R9 (100K)
; 對 C5 (104, 0.1UF) 充電, 此為 Vc, 並進入比較器 AIN-
 
;     JB P3.6,Precharge ; AT89C2051特有的, P3.6無外接引腳, P1.0/P1.1兩腳接內部比
; 較器, 比較輸出在P3.6讀取
; 當P3.6 = 1, Vin > Vc, 跳回上面Precharge:, 繼續充電
; 當P3.6 = 0, Vc > Vin, 表示AIN-的電壓高於AIN+, 執行下面
; 一行指令, 開始 ADC
 
; 8051AH, no internal comparator, use LM311, comparator connects to P1.6
; 8051AH, 沒有內置比較器, 用LM311輸出接到P1.6
JB COM_OUT,Precharge ; when COM_OUT = 1, means Vin > Vc, go back, keep charging
; when COM_OUT = 0, means Vc > Vin, AIN- > AN+,
; go to next instruction, start ADC comversion
 
ADC_Start:
;每次轉換時間=5000*11us=55ms
;each ADC is about 5000*11us=55ms
 
; intial ADC result, set to 00:00
CLR A
MOV R0,A   ;high byte;高字節, R0:R1 (16bit) to store ADC value
MOV R1,A   ;low byte; 低字節
 
;load counter
;   MOV R6,#20 ;20x250 = 5000 sampling; 5000次ADC採樣, 5000 loops
MOV R6,#66 ;66x250 = 165000 sampling is about 2^17, over sampling technique
ADC_Loop1:
;   MOV R7,#250    ;R6=20, R7=250, total loop count = 20x250 = 5000 loops
MOV R7,#250    ;R6=20, R7=250, total loop count = 20x250 = 5000 loops
 
ADC_Loop2:
;   MOV C,P3.6     ; 取比較器輸出, 存入 Carry bit (Cy)
MOV C,COM_OUT  ; comparator output, save to carry bit (Cy), 取比較器輸出, 存入 Carry bit (Cy)
MOV ADC_CON,C  ; if Cy =1, Vin >= Vc, ADC_CON = high, keep charging; 若Cy=1, 說明 Vc 等於或小於 Vin, ADC_CON (P1.0) = 1, 繼續充電
; if Cy =0, Vin < Vc, 若Cy=0, 說明 Vc > Vin, ADC_CON = low, around 0V; 此時 ADC_CON (P1.0) = 0, 大約 0V,
; C5 is discharging; C5 開始被放電
; 下面繼續 ADC value 累計, 加上 Cy (0 或 1), 累計比較器輸出的
; 高電平個數
CLR A     ;1C (1 CPU cycle time, 6MHZ Xtal = 0.5MHZ CPU speed ?!)
ADDC A,R1 ;1C, low byte 低字節
MOV R1,A  ;1C
CLR A     ;1C
ADDC A,R0 ;1C, high byte 高字節
MOV R0,A  ;1C
DJNZ R7,ADC_Loop2 ; loop 循環
DJNZ R6,ADC_Loop1   ; ADC value, accumualted xxx000 times, 連續累計 xxx000, 得到 ADC value 累計總值
 
;ADC completed 結束
SETB EA ; enable all interrupt 開放所有中斷
CLR ADC_CON ; discharge Capacitor, prepare for next ADc, 電容放電,為下一次測量做準備
 
;R0:R1, 16 bit ADC value, save this result to 7-SEG LED buffer for display & debug purpose
;0X3E, 0X3D, 0X3C, 0X3B = 7-SEG LED BUFFER
;R0-H, R0-L, R1-H, R1-l = 16 bit ADC result, R0:R1
MOV A,R0  ; HIGH BYTE, HIGH NIBBLE
swap a    ; ACC = hhhhllll, after swap, ACC = llllhhhh, 4bit:4bit swapped
anl A,#0fh; filter out ACC = 0000hhhh
mov 03eh,a; first digit, R0 high nibble
 
MOV A,R0  ; HIGH BYTE, LOW NIBBLE
anl A,#0fh
mov 03dh,a
 
MOV A,R1  ; LOW BYTE, HIGH NIBBLE
swap a
anl A,#0fh
mov 03ch,a
 
MOV A,R1  ; LOW BYTE, LOW NIBBLE
anl A,#0fh
mov 03bh,a
 
; MICE-5103 have 6 digits of 7-SEG LED, this last two have no used, masked to
; no display, show 'space' of off, LED table, see MICE-5103 manual, page 21
; LED_table @ 0xFD80, "space" is at index = 0x10h, so load ACC=0x10h, put
;them to display buffer
;   ORG 0DF80H
; LED_TB:
;   db 3FH ; "0"
;   db 06H ; "1"
;   db 5BH ; "2"
;.. so on
mov a,#010h ; space
mov 03ah,a
mov 039h,a
 
; now, ADC result is already at display buffer, let us go back to caller
; ready to display this ADC result
RET
 
END
