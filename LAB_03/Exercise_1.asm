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
; ����� ��� ��������� �����, ���� ��������� ������ 2^32, �������� ������� !

.data 
	numberOfCharsToRead dd 255
	operand_1 dd 0
	operand_2 dd 0 
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
     	resultOfAdd db 10 dup(" ") ; ������ ��� ������ ���������� � �������
	; ������������ �������� ���������� �������� ����� 2^32 (4294967296)
	resultOfSub db 10 dup(" ") ; ������ ��� ������ ���������� � �������
	; ������������ �������� ���������� �������� ����� 2^32 (4294967296)
	resultOfMul db 10 dup(" ") ; ������ ��� ������ ���������� � �������
	; ������������ �������� ���������� �������� ����� 2^64, �� ���� ������� , ��� 2^32
	resultOfDiv db 10 dup(" ") ; ������ ��� ������ ���������� � �������
	; ������������ �������� ���������� �������� ����� 2^16 (65536)
     	messageString db 10, "sum: "
.code
	;================ ���������� � ����� ����� =================== 
	mov EAX, operand_1
	add EAX, operand_2
	
	push offset resultOfAdd
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 6 ; <-- ������ messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; ������ ������ resultOfAdd
	push offset resultOfAdd
	push outputHandle
	call WriteConsole	                                                              
	;============================================================= 
	
	;================ ���������� � ����� �������� ================
	; ��������� messageString �� "sub: "
	mov EDX, offset messageString
	mov byte ptr [ EDX + 3 ], "b"
	
	mov EAX, operand_1
	sub EAX, operand_2
	
	push offset resultOfSub
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 6 ; <-- ������ messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; ������ ������ resultOfSub
	push offset resultOfSub
	push outputHandle
	call WriteConsole
	;=============================================================
	
	;================ ���������� � ����� ��������� ===============
	; ��������� messageString �� "mul: "
	mov EDX, offset messageString
	mov byte ptr [ EDX + 1 ], "m"
	mov byte ptr [ EDX + 3 ], "l"
	
	mov EAX, operand_1
	mul operand_2
	
	push offset resultOfMul
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 6 ; <-- ������ messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; ������ ������ resultOfMul
	push offset resultOfMul
	push outputHandle
	call WriteConsole
	;=============================================================
	
	;================ ���������� � ����� ������� =================
	; ��������� messageString �� "div: "
	mov EDX, offset messageString
	mov byte ptr [ EDX + 1 ], "d"
	mov byte ptr [ EDX + 2 ], "i"
	mov byte ptr [ EDX + 3 ], "v"    
	
        mov EAX, operand_1
        mov EDX, 0 ; ���� ������� ���� ������������ ��������
        div operand_2

	push offset resultOfDiv
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 6 ; <-- ������ messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; ������ ������ resultOfDiv
	push offset resultOfDiv
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