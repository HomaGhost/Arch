.486
.model flat, stdcall
option casemap :none
include windows.inc
include kernel32.inc
include user32.inc
include masm32.inc
includelib kernel32.lib
includelib masm32.lib
includelib user32.lib


.data
; ������ �������� ��������� � ���������� �������:
complex struct
	re dq ?
	im dq ?
complex ends
	zero dq 0
	; ���������� ������� �� 5-�� ����������� �����
	array complex <1.0, 2.0>, <-4.5, 1.25>, <0.0, -3.1>, <3.5, -1.5>, <2.0, 3.0>
.code
; ������ ������������, ������������ ��� ����������� �����:
complexCompareByRealPart:
	; �������� ����� ������� ���������
	mov EAX, [ ESP + 4 ]
	; ������� � ������� ����� ������������
	; �������������� ����� ������� ���������
	fld qword ptr [ EAX ]
	; �������� ����� ������� ���������
	mov EAX, [ ESP + 8 ]
	; ���������� �������������� ����� �������
	; ��������� �� ������� ����� ������������
	; � �������������� ������ ������� ���������,
	; ������������ � ������; ��� ���� ����� ��
	; ������� ����� ������������ ���������
	fcomp qword ptr [ EAX ]
	; �������� ����� ������������ � �������
	; ������ ��������� ����������
	fstsw AX
	sahf
	; ���������� ����������� ������������� ���������
	ja great1
	jb less1
		mov EAX, 0
		jmp return1
	great1:
		mov EAX, 1
		jmp return1
	less1:
		mov EAX, -1
	return1:
ret 8

; ������ ������������, ������������ ��� ����������� �����:
complexCompareByModulus:
	; �������� ����� ������� ���������
	mov EAX, [ ESP + 4 ]
	; ������� � ������� ����� ������������
	; �������������� ����� ������� ���������
	fld qword ptr [ EAX ]
	; �������� �������������� ����� �������
	; ��������� � �������
	fmul ST (0), ST (0)
	; ������� � ������� ����� ������������
	; ������ ����� ������� ���������
	fld qword ptr [ EAX + 8 ]
	; �������� ������ ����� ������� ���������
	; � �������
	fmul ST (0), ST (0)
	; ���������� � �������� ST (1) �������
	; �������������� � ������ �����, �����
	; ������ ������� ST (0) ��������� �� �����,
	; � ��������� ���������� � ������� �����
	faddp ST (1), ST (0)
	; ���������� ���������� ������ �������
	; ������������ ����� ���������� �������
	mov EAX, [ ESP + 8 ]
	fld qword ptr [ EAX ]
	fmul ST (0), ST (0)
	fld qword ptr [ EAX + 8 ]
	fmul ST (0), ST (0)
	faddp ST (1), ST (0)
	; ������� �������� ��������� �������
	; ����������� �����
	fsubp ST (1), ST (0)
	; ��������� �������� ������� � ����
	fcomp zero
	fstsw AX
	sahf
	; ���������� ������������� ���������
	ja great2
	jb less2
		mov EAX, 0
		jmp return2
	great2:
		mov EAX, 1
		jmp return2
	less2:
		mov EAX, -1
	return2:
ret 8

; ������ ������ ������ ������������� �������� �������:
max:
	; ������ �������� - ����� �������
	; �������� �������
	mov EBX, [ ESP + 4 ]
	; ���������� ��������� �������
	mov ECX, [ ESP + 8 ]
	; ����� �������, ������� �����
	; ���������� ��� �������� �������
	mov EDX, [ ESP + 12 ]

	; ������� � ������� ESI �����
	; ������� �������� �������, �
	; ���������� ����� ����� �������
	; ����� ������������� ��������
	mov ESI, EBX

	beginCycle:
		; ���������, ��������� ��
		; ����� �������
		cmp ECX, 0
		je endCycle
		; ������� � ������� ���������
		; ����� �������� �������������
		; �������� �������
		push ESI
		; ������� � ������� ���������
		; ����� ���������� �������� �������
		push EBX
		; �������� ������� ���������,
		; ��������� ��������� ���������� ������
		call EDX
		; ���������� ���������, ������������
		; �������� ���������, � ����
		cmp EAX, 0
		; ���� ������� ������������ �������
		; ������ ���������� �������� �������
		jng skip
			; ���������� � �������� ������
			; ������������� �������� �������
			; ����� �������� �������� �������
			mov ESI, EBX
		skip:
		; ��������� � ���������� �������� �������
		; (���������� �������� 16 ���� - ������
		; ��������� complex)
		add EBX, 16
		; ��������� ���������� ��������� �������
		dec ECX
		jmp beginCycle
	endCycle:
	; ������� � ������� EAX ����� �����������
	; �������� �������
	mov EAX, ESI
ret 12

; ������ ������ ������������ max ��� ������ ������������� �������� � ������� 
; ����������� �����, ��������� ��������� �������������� ������ ���������:
;   push complexCompareByRealPart
;   push 5
;   push offset array
;   call max
 
; ������ ������ ������������ max ��� ������ ������������� �������� � ������� 
; ����������� �����, ��������� ��������� ������� ���������:
;   push complexCompareByModulus
;   push 5
;   push offset array
;   call max


;----------------------------- ������������ inputNumber -------------------------
; void inputNumber(char* inputMessage, float &number)
; 	inputMessage ( [ EBP + 8 ] ) - ��������� ���� "Input number: "
;	number ( [ EBP + 12 ] ) - ������ �� �����, ������� ����� ������
inputNumber:
       	push EBP
	mov EBP, ESP   

	push [ EBP + 8 ]
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push [ EBP + 8 ] 
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push numberOfBytesToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0

	push [ EBP + 12 ]
	push offset inputBuffer
	call StrToFloat
     
	pop EBP
ret 8

.data
	numberOfBytesToRead dd 256

.data?
	inputBuffer db 256 dup(?)
	inputHandle dd ?
	outputHandle dd ?
	numberOfChars dd ? 

.code
entryPoint:	
	push STD_INPUT_HANDLE  
	call GetStdHandle 
	mov inputHandle, EAX 
	
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX

	

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