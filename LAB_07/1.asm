.486
.model flat, stdcall
option casemap :none ; ���������������� � �������� ���� � ���������������
include windows.inc
include kernel32.inc
includelib kernel32.lib

.data
	messageString db "Hello, World!!!"
	inputBuffer db 0

.data?
	inputHandle dd ?
	outputHandle dd ?
	numberOfChars dd ?

.code
entryPoint:
	
	push STD_INPUT_HANDLE     ; �������� ��������� � �������
	call GetStdHandle         ; ����� ��������� �������
	mov inputHandle, EAX      ; ���������� ���������� �������
	
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX
	
	push NULL                 ; 5-�� �������� �������, ��������� ���������
	push offset numberOfChars ; 4-�� �������� �������, ����� ����������
	push 15                   ; 3-�� �������� �������, ������������� ���������
	push offset messageString ; 2-�� �������� �������, ����� ������� ��������
	push outputHandle         ; 1-�� �������� �������, ���������� ���������� �������
	call WriteConsole

	push NULL
	push offset numberOfChars
	push 1
	push offset inputBuffer
	push inputHandle
	call ReadConsole

	push 0
	call ExitProcess

end entryPoint