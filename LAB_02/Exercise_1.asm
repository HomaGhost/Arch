.486
.model flat, stdcall
option casemap :none
include windows.inc
include kernel32.inc
includelib kernel32.lib

.data
        numberOfCharsToRead dd 255 
        numberOfCharsRead dd 0
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
	
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset inputBuffer + 1 ; <-- ?????? ?????? ??????? ??? ???????? ??????
	push inputHandle
	call ReadConsole
	
	mov EBX, offset inputBuffer
	mov EAX, numberOfChars
	mov numberOfCharsRead, EAX
	mov byte ptr [ EBX ], "{"     
	mov byte ptr [ EBX + EAX - 1 ], "}"
		
	push NULL               
	push offset numberOfChars 
	push numberOfCharsRead                 
	push offset inputBuffer
	push outputHandle     
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
