.486
.model flat, stdcall
option casemap :none 
include windows.inc
include kernel32.inc
include masm32.inc
include user32.inc
includelib kernel32.lib
includelib masm32.lib
includelib user32.lib

; ��������� ����� ���� �����������, ���� �� ���������:
; ����� �������� ������� �������� 2^32 !

.data 
	numberOfCharsToRead dd 255
	operand_1 dd 0     ; x
	operand_2 dd 0     ; y
.data?
	inputHandle dd ?
	outputHandle dd ?
	numberOfChars dd ?
	inputBuffer db ? 
.code
entryPoint:
	
	push STD_INPUT_HANDLE     
	call GetStdHandle         
	mov inputHandle, EAX      
	
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX
	
	;==================== ��������� 1 ����� ======================  
	; ������ ������� ����� �� ������
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	; ���������� 0 � ����� ������
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0 
	
	push offset inputBuffer
	call atodw
	; ��� �����������:
	; ���� ������� �� ������ �����, ����� �����
	; (�� �������: � " " �������� 240)
	; " " - ��� 240
	; " 1" - ��� 2401
	; "1 " - ��� 250
	; "1 1" - ��� 2501	
	
	; ��������� ����������� ����� �� ������� atodw � ����������
	mov operand_1, EAX
	;=============================================================
	
	;==================== ��������� 2 ����� ====================== 
	; ������ ������� ����� �� ������
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	; ���������� 0 � ����� ������
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0 
	
	push offset inputBuffer
	call atodw
	
	; ��������� ����������� ����� �� ������� atodw � ����������
	mov operand_2, EAX
	;============================================================= 
	
.data
     	result dd 0
     	templateOfResult db "result: %d", 0 
       	templateOfIntermediateValues db "max(x, 5): %d, max(y, 5): %d, min(max(x, 5), max(y, 5)): %d, min(10, |x - y|): %d", 10, 13, 0
     	messageResult db 256 dup(0)
     	messageIntermediateValues db 256 dup(0)
     	
     	divisor dd 0
     	dividend dd 0
.code    
	; max(x, 5): 
	mov EDX, 5 
	cmp operand_1, 5 ; if (x > 5) EDX = x
	jbe step_1 ; jb - ������ ��� �����
	mov EDX, operand_1             
step_1:
  
	; max(y, 5):
	mov EBX, 5  
	cmp operand_2, 5 ; if (y > 5) EBX = y
	jbe step_2 ; jbe - ������ ��� �����               
	mov EBX, operand_2
step_2:
	
	; min(max(x, 5), max(y, 5)):
	mov ECX, EBX
	cmp EDX, EBX   	; if (max(x, 5) < max(y, 5)) ECX = max(x, 5)
	jae step_3 ; ja - ������ ��� �����             
	mov ECX, EDX
step_3:  
	mov dividend, ECX ; <-- ��������� �������� �������� � ����������
	
       	; ������ EAX - ������������ ��������� �������
	; |x - y|:
	mov EAX, operand_1 ; x � EAX 
	cmp EAX, operand_2 ; if (x >= y) x - y � EAX
	jb step_4	
	sub EAX, operand_2
	jmp step_5
step_4:
	mov EAX, operand_2 ; y � EAX
	sub EAX, operand_1 ; else y - x � EAX
step_5:
	
	; ������ � EAX ����� |x - y|
	; min(10, |x - y|):
	cmp EAX, 10   	 ; if (|x - y| > 10) EAX = 10
	jbe step_6   ; jb - ������ ��� �����           
	mov EAX, 10
step_6: 
	mov divisor, EAX ; <-- ��������� �������� �������� � ����������
	
	; EAX = min(10, |x - y|)
	; EBX = max(y, 5)
	; ECX = min(max(x, 5), max(y, 5))
	; EDX = max(x, 5)
	
	push EAX
	push ECX
	push EBX
	push EDX
	push offset templateOfIntermediateValues
	push offset messageIntermediateValues 
	call wsprintf 
	
	push offset messageIntermediateValues 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset messageIntermediateValues 
	push outputHandle
	call WriteConsole 
	
	; ������ ����� ������ dividend �� divisor
	cmp divisor, 0
	je  divisionByZero ; <-- ������ �������, ���� �������� ����� 0
	mov EDX, 0
	mov EAX, dividend
	div divisor  ; <-- ��������� ����������� �������, �.�. ������������� ����� � �������� ����������� �� �����
	mov result, EAX
	
 	; ������������ ������-����������
	push result
	push offset templateOfResult 
	push offset messageResult 
	call wsprintf
	
	; ����� ������-����������
	push offset messageResult 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset messageResult 
	push outputHandle
	call WriteConsole  

divisionByZero:
	
	; � �������� �����
	push NULL
	push offset numberOfChars
	push 1
	push offset inputBuffer 
	push inputHandle
	call ReadConsole

	push 0
	call ExitProcess

end entryPoint