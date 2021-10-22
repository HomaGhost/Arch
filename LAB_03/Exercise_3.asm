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

.data 
	numberOfCharsToRead dd 255
	a dd 0
	b dd 0
	z dd 0 
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
	
	;==================== ��������� 3 ����� ====================== 
	; ������ �������� ����� �� ������
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
	mov z, EAX
	;=============================================================	
	
.data  
	;=================== ���������� � ����� ====================== 
     	messageString db 10, "result: "
     	result db 10 dup(" ") ; ������ ��� ������ ���������� � �������
	; ������������ �������� ���������� �������� ����� 2^32 (4294967296)
	tmp_1 dd 0
	tmp_2 dd 0
	tmp_3 dd 0
	tmp_4 dd 0
.code    
	;----------------------- ���������� -------------------------- 
	mov EAX, 128
	mul b ; 128 * b � ( EDX : EAX )
	mov tmp_1, EDX
	mov tmp_2, EAX
	; tmp_1 = �.�. 128 * b, tmp_2 = �.�. 128 * b,
	; tmp_3 = 0, tmp_4 = 0
	
	mov EAX, a
	mul EAX ; a^2  � ( EDX : EAX )
	mul EAX ; a^4  � ( EDX : EAX )
	mul a   ; a^5  � ( EDX : EAX )
	mul EAX ; a^10 � ( EDX : EAX )
	mov tmp_3, EDX
	mov tmp_4, EAX
	; tmp_1 = �.�. 128 * b, tmp_2 = �.�. 128 * b,
	; tmp_3 = �.�. a^10, tmp_4 = �.�. a^10
	
	; ��������� a^10 � 128 * a � ��������
	mov EDX, tmp_1
	mov ECX, tmp_2  ; 128 * b � ( EDX : ECX )
	mov EBX, tmp_3
	mov EAX, tmp_4  ;   a^10  � ( EBX : EAX )
	; �������� 64-��������� �����
	add EAX, ECX
	adc EBX, EDX ;        a^10 + 128 * b � ( EBX : EAX )	
	mov EDX, EBX ; ������ a^10 + 128 * b � ( EDX : EAX )
	div z ;	(a^10 + 128 * b) / z � EAX
	      ; (a^10 + 128 * b) % z � EDX
	add EAX, EDX ; 	(a^10 + 128 * b) / z + (a^10 + 128 * b) % z � EAX
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