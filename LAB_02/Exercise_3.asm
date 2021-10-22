.486
.model flat, stdcall
option casemap :none
include windows.inc
include kernel32.inc
includelib kernel32.lib

.data
        numberOfCharsToRead dd 100
        firstString db 100 dup(" ")
        secondString db 100 dup(" ")
        thirdString db 100 dup(" ")
.data?
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
	
	;================== ���� ������ ������ ==================
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset firstString + 2
	push inputHandle
	call ReadConsole
	
	; ���������� � ������ � �������
	mov EBX, offset firstString    
	mov EAX, numberOfChars
	mov byte ptr [ EBX + 2 + EAX - 2 ], " "  ; �������� �������� �������� ������
	mov byte ptr [ EBX + 2 + EAX - 1 ], " "  ; � �������� �������
	mov byte ptr [ EBX ], " " ; ������ � �������� ������� � ������
	mov byte ptr [ EBX + 1 ], 186 ; ������ ������������ ����� �����
	mov byte ptr [ EBX + 12 ], 186 ; ������ ������������ ����� ������
	mov byte ptr [ EBX + 13 ], 10 ; ������ �������� �������	 
        ;========================================================
        
        ;================== ���� ������ ������ ==================
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset secondString + 2
	push inputHandle
	call ReadConsole
	
	; ���������� � ������ � �������
	mov EBX, offset secondString    
	mov EAX, numberOfChars
	mov byte ptr [ EBX + 2 + EAX - 2 ], " "  ; �������� �������� �������� ������
	mov byte ptr [ EBX + 2 + EAX - 1 ], " "  ; � �������� �������
	mov byte ptr [ EBX ], " " ; ������ � �������� ������� � ������
	mov byte ptr [ EBX + 1 ], 186 ; ������ ������������ ����� �����
	mov byte ptr [ EBX + 12 ], 186 ; ������ ������������ ����� ������
	mov byte ptr [ EBX + 13 ], 10 ; ������ �������� �������	   
        ;========================================================
        
        ;================== ���� ������� ������ =================
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset thirdString + 2
	push inputHandle
	call ReadConsole
	
	; ���������� � ������ � �������
	mov EBX, offset thirdString    
	mov EAX, numberOfChars
	mov byte ptr [ EBX + 2 + EAX - 2 ], " "  ; �������� �������� �������� ������
	mov byte ptr [ EBX + 2 + EAX - 1 ], " "  ; � �������� �������
	mov byte ptr [ EBX ], " " ; ������ � �������� ������� � ������
	mov byte ptr [ EBX + 1 ], 186 ; ������ ������������ ����� �����
	mov byte ptr [ EBX + 12 ], 186 ; ������ ������������ ����� ������
	mov byte ptr [ EBX + 13 ], 10 ; ������ �������� �������	 	  
        ;========================================================
		
.data
        tempString db " ", 214, 10 dup(196), 183, 10
.code
        push NULL                                     ; <-- 1 ������
        push offset numberOfChars
        push 14
	push offset tempString
	push outputHandle
	call WriteConsole    
	
	push NULL                                     ; <-- 2 ������
        push offset numberOfChars
        push 14
	push offset firstString
	push outputHandle
	call WriteConsole
        
        mov EAX, offset tempString                    ; <-- 3 ������     
        mov byte ptr [ tempString + 1 ], 199
        mov byte ptr [ tempString + 12 ], 182
        push NULL                                     
        push offset numberOfChars
        push 14
	push offset tempString
	push outputHandle
	call WriteConsole
        
        push NULL                                     ; <-- 4 ������
        push offset numberOfChars
        push 14
	push offset secondString
	push outputHandle
	call WriteConsole
	
	push NULL                                     ; <-- 5 ������
        push offset numberOfChars
        push 14
	push offset tempString
	push outputHandle
	call WriteConsole
	
	push NULL                                     ; <-- 6 ������
        push offset numberOfChars
        push 14
	push offset thirdString
	push outputHandle
	call WriteConsole
	
	mov EAX, offset tempString                    ; <-- 7 ������     
        mov byte ptr [ tempString + 1 ], 211
        mov byte ptr [ tempString + 12 ], 189
        push NULL                                     
        push offset numberOfChars
        push 14
	push offset tempString
	push outputHandle
	call WriteConsole       
        
                         
        
	; ����� ����� �����������
	push NULL
	push offset numberOfChars
	push 1
	push offset tempString
	push inputHandle
	call ReadConsole

	push 0
	call ExitProcess

end entryPoint