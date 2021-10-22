.486
.model flat, stdcall
option casemap :none ; чувствительность к регистру букв в идентификаторах
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
	
	push STD_INPUT_HANDLE     ; передача параметра в функцию
	call GetStdHandle         ; вызов системной функции
	mov inputHandle, EAX      ; сохранение результата функции
	
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX
	
	push NULL                 ; 5-ый параметр функции, системная константа
	push offset numberOfChars ; 4-ый параметр функции, адрес переменной
	push 15                   ; 3-ий параметр функции, целочисленная константа
	push offset messageString ; 2-ой параметр функций, адрес массива символов
	push outputHandle         ; 1-ый параметр функции, дескриптор системного объекта
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