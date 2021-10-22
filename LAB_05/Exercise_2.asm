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
;------------------------------------------------------------

;-------------- ������������ countSum -----------------------
; int countSum(int* array, int size)
;
; ������� ����� ��������� �������������� �������, ����������
; ����� � �������� EAX (�.�. �������� 32-������ �����)
;
; ������� ���������:
;       array ( EDX )  - ��������� �� ������
;       size   ( EAX ) - ���������� ��������� � �������
.data
	sum dd 0
.code

countSum:
	mov sum, 0
	mov ECX, 0
	cmp EAX, 0
	jbe endCountSum
countSum_cycle:
		mov EBX, [ EDX + 4 * ECX ]
	        add sum, EBX  ; <-- add <������_������>, <�������>
	        inc ECX                   
		cmp ECX, EAX
		jb countSum_cycle
endCountSum:	
	mov EAX, sum
ret
;------------------------------------------------------------

;--------- ������������ changeEvenElements ------------------
; void changeEvenElements(int* array, int size)
;
; ������� ����� ��������� �������������� �������
;
; ������� ���������:
;       array  ( [EBP + 8] )  - ��������� �� ������
;       size   ( [EBP + 12] ) - ���������� ��������� � �������  
.code
changeEvenElements:
	push EBP
	mov EBP, ESP
	   
	cmp dword ptr [ EBP + 12 ], 0
	je endChangeEvenElements 
	
	mov ECX, 0
	add dword ptr [ EBP + 8 ], 4 ; ����� ������ �� 2 ��������
changeEvenElements_cycle:
	mov EDX, 0                  ;	\
	mov EBX, [ EBP + 8 ]        ;	 |
	mov dword ptr EAX, [ EBX ]  ;	  > ���������� � �������
	mul EAX                     ;	 |
	mov [ EBX ], EAX            ;	/
	       
	add dword ptr [ EBP + 8 ], 8  ; ������� � ���������� �������� �������
	add ECX, 2	
	cmp ECX, [ EBP + 12 ]
	jb changeEvenElements_cycle
endChangeEvenElements:

	pop EBP
ret 8
;------------------------------------------------------------ 
	
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
        arrayMessage db "array: ", 0
        
     	buffer db 256 dup(0)
        sz dd 12
.data?
	array dd 12 dup(?) ; <-- 12 - ��� ����. sz
.code 
        push offset arrayMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset arrayMessage 
	push outputHandle
	call WriteConsole
	
	; ������������� ������� array	
	mov [ array ], 0
	mov [ array + 4 ], 1 
	mov EBX, [ array ]
	mov EDX, [ array + 4 ]
	
	mov ECX, 2	
continue:
       	mov EAX, 0
       	add EAX, EBX
       	add EAX, EDX
       	
       	mov EBX, EDX
       	mov EDX, EAX
		
	mov [ array + 4 * ECX ], EAX
	inc ECX
	cmp ECX, sz
	jb continue 
	
	; ������������� ������������ arrayToStr
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

.data
        arraySumMessageTemplate db 10, 13, "sum of elements: %d", 10, 13, 0
        arraySumMessage db 256 dup(0)
.code 

	; ������������� ������������ countSum 
	mov EDX, offset array
	mov EAX, sz
	call countSum
	
	; ����� �����
	push EAX
	push offset arraySumMessageTemplate 
	push offset arraySumMessage 
	call wsprintf
	
       	push offset arraySumMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset arraySumMessage 
	push outputHandle
	call WriteConsole
	
	;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	;|||||||||||||| ������������� ������������ changeEvenElements ||||||||||||
	;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	push sz
	push offset array
	call changeEvenElements  

	push offset arrayMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset arrayMessage 
	push outputHandle
	call WriteConsole
	
	mov ECX, 0
zeroMemory_cycle:
	mov [ buffer + ECX ], 0
	mov [ arraySumMessage + ECX ], 0
	inc ECX
	cmp ECX, 256
	jb zeroMemory_cycle
	
	; ������������� ������������ arrayToStr
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
	
	; ������������� ������������ countSum 
	mov EDX, offset array
	mov EAX, sz
	call countSum
	
	; ����� �����
	push EAX
	push offset arraySumMessageTemplate 
	push offset arraySumMessage 
	call wsprintf
	
       	push offset arraySumMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset arraySumMessage 
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