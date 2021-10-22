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
                                                                          
;------------------------- ����������� sortByArea -------------------------
; int sortByArea(polygon &polygon_1, polygon &polygon_2)
;	polygon_1 ( [ EBP + 8 ] ) - ����� ������ ��������������
;	polygon_2 ( [ EBP + 12 ] ) - ����� ������� ��������������
sortByArea:
       	push EBP
	mov EBP, ESP 
        
	; ������������ �������� ����� � EAX	
	pop EBP
ret 8

;------------------------- ����������� sortByPerimeter ---------------------
; int sortByPerimeter(polygon &polygon_1, polygon &polygon_2)
;	polygon_1 ( [ EBP + 8 ] ) - ����� ������ ��������������
;	polygon_2 ( [ EBP + 12 ] ) - ����� ������� �������������� 
sortByPerimeter:
       	push EBP
	mov EBP, ESP 
        
	; ������������ �������� ����� � EAX
	pop EBP
ret 8

;------------------------- ����������� findPosOfMin --------------------------
; !!! ����������� ECX, EDX
; int findPosOfMin(int &array, int size)
;	array ( [ EBP + 8 ] ) - ����� 1-��� �������� �������
;	size ( [ EBP + 12 ] ) - ���-�� ��-��� �������
findPosOfMin:
       	push EBP
	mov EBP, ESP 
        
        mov dword ptr EDX, [ EBP + 8 ]    ; <-- ����� �������� �������
        mov dword ptr ECX, [ EBP + 12 ]   ; <-- ������ �������� �������
findPosOfMinCycle:

	; ��������� ��������� �� ����� �������
	dec ECX
	cmp ECX, 0
	ja findPosOfMinCycle
        
	; ������������ �������� ����� � EAX
	pop EBP
ret 8

;------------------------- ����������� sorting -----------------------------
; !!! ����������� EBX, ECX, EDX, ESI 
; void sorting(int &array, int sortingMethod)
;	array ( [ EBP + 8 ] ) - ����� 1-��� �������� �������
;	size ( [ EBP + 12 ] ) - ���-�� ��-��� �������
;	sortingMethod ( [ EBP + 16 ] ) - ����� ������� ���������� 
sorting:
       	push EBP
	mov EBP, ESP 
        
	mov dword ptr EBX, [ EBP + 16 ] ; <-- sortingMethod
	mov dword ptr ECX, [ EBP + 12 ] ; <-- size
	mov dword ptr EDX, [ EBP + 8 ]  ; <-- array
	mov ESI, 0 ; ������� ������ ����������������� ����� �������
sortingCycle: 
	
	; ��������� ��������� �� ����� �������
	dec ECX
	cmp ECX, 0
	je sortingCycle
	
	pop EBP
ret 8

;========================================================
;================>> �������� ��������� <<================          
;========================================================
polygon struct  ; (12 ����)
	numberOfSides dd ?
	lengthOfSides dq ?
polygon end
;========================================================

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