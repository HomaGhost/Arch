.486
.model flat, stdcall
option casemap :none 
include windows.inc
include kernel32.inc
include masm32.inc
includelib kernel32.lib
includelib masm32.lib 

; ��������� ����� ���� �����������, ���� �� ���������:
; ����� �������� ������� �������� 2^32 !
; ������ ����� ������ ���� ������ �������, �.�. ����� ���� ���������
;  ������� �� �������, � ���������� ���� �������� ������ ���� ��������������

; ��������:
; a = 5, b = 1    ���������: 9
; a = 2, b = 1    ���������: 9
; a = 10, b = 10  ���������: ������� �� 0
; a = 18, b = 9   ���������: 81

.data 
	numberOfCharsToRead dd 255
	a dd 0
	b dd 0 
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
	; ���� ������ �� ������ �����, ����� �����
	; (�� �������: � " " �������� 240)
	; " " - ��� 240
	; " 1" - ��� 2401
	; "1 " - ��� 250
	; "1 1" - ��� 2501	
	
	; ��������� ����������� ����� �� ������� atodw � ����������
	mov a, EAX 
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
	mov b, EAX
	;============================================================= 
	
.data  
	;=================== ���������� � ����� ====================== 
     	messageString db 10, "result: "
     	result db 10 dup(" ") ; ������ ��� ������ ���������� � �������
	; ������������ �������� ���������� �������� ����� 2^32 (4294967296)
     	tmp dd 0
.code    
	;----------------------- ���������� --------------------------
        mov EAX, a
	sub EAX, b ; a - b � EAX
	mov tmp, EAX
	; @ ������ tmp = a - b
	mov EAX, a
	add EAX, b ; a + b � EAX
	mul EAX ; (a + b) * (a + b) � ( EDX : EAX )
	div tmp ; (a + b) * (a + b) / (a - b) � EAX	
	;-------------------------------------------------------------	
	
	push offset result
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 9 ; <-- ������ messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; ������ ������ result
	push offset result
	push outputHandle
	call WriteConsole
     	;============================================================= 
	
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