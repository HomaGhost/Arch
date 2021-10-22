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

; ------------- ������������ ArrayToStr ---------------------
; void arrayToStr(char* buffer, int* array, int size)
;
; ��������� ��������� ������������� �������������� �������
;
; ������� ���������:
;       buffer ( [EBP + 8] )  - ��������� �� ������, � ������� �����
;                               ������������� ������������� �������
;       array  ( [EBP + 12] ) - ��������� �� ������
;       size   ( [EBP + 16] ) - ���������� ��������� � �������

.data
        template db "%d ", 0    ; ������� ������ ��� ������ ������ �����

.code

arrayToStr:
        ; ����������� ������ �������
        push EBP
        mov EBP, ESP
        ; ������ ����� - ���� ���� �������������� ��������
        cycle:
                cmp dword ptr [ EBP + 16 ], 0
                je endFunction
                ; ������������ ���������� ������������� ������ �����
                mov EAX, [ EBP + 12 ]         ; ��������� �� ��������� �����
                push [ EAX ]                  ; ����� ����� (������� �������),
                                              ; ������������� � ������
                push offset template          ; ������ ������, � �������
                                              ; ������������� ��������
                push [ EBP + 8 ]              ; ����� ������ ��� ����������
                                              ; �������� ������
                call wsprintf                 ; � EAX ������������ ����� ��������,
                                              ; ���������� � �����
                add ESP, 12                   ; ��������� ����
                ; ���������� � ���������� �����
                add [ EBP + 8 ], EAX          ; ���������� ����� ������ ���
                                              ; ���������� �����
                add dword ptr [ EBP + 12 ], 4 ; ���������� ��������� �� ���������
                                              ; ������� �������
                dec dword ptr [ EBP + 16 ]    ; ��������� �������
        ; ����� �����
        jmp cycle
        endFunction:
        ; ����������� ������ �������
        pop EBP
; ����� � ��������� ����
ret 12
	
.data?
	inputBuffer db ?
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
.data 
     	buffer db 256 dup(0)
        sz dd 20
.data?
	array dd 20 dup(?) ; <-- 20 - ��� ����. sz
.code 
	; ������������� ������� array
	mov ECX, 0
continue:	
	mov [ array + 4 * ECX ], ECX ; ������ �����: 0, 1, 2, 3, 4 ...
	inc ECX
	cmp ECX, sz
	jb continue 
	
	; ������������� ������������
	push sz
	push offset array
	push offset buffer
	call arrayToStr
	
	push offset buffer
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset buffer
	push outputHandle
	call WriteConsole
	
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