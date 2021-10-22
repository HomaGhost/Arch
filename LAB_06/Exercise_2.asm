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
	operand_1 dq 0
	operand_2 dq 0
	
	inputOperand_1Message db "input a: ", 0 
	inputOperand_2Message db "input b: ", 0
	
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

	;-------------- получение operand_1 -----------------
	push offset inputOperand_1Message 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset inputOperand_1Message 
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

	; преобразование строки в дробное число
	push offset operand_1
	push offset inputBuffer
	call StrToFloat
	;----------------------------------------------------
        ;-------------- получение operand_2 -----------------
	push offset inputOperand_2Message 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset inputOperand_2Message 
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

	; преобразование строки в дробное число
	push offset operand_2
	push offset inputBuffer
	call StrToFloat
	;----------------------------------------------------
        
.data 
	result dq 0
	
        finalOutputTemplate db "(%s + %s)^2/(%s - %s) = %s", 10, 13, 0
        finalOutput db 256 dup(0) 
        operand_1Str db 256 dup(0)
        operand_2Str db 256 dup(0)
        resultStr db 256 dup(0)
.code 
        push offset operand_1Str
	push dword ptr operand_1 + 4
	push dword ptr operand_1
	call FloatToStr 
	push offset operand_2Str
	push dword ptr operand_2 + 4
	push dword ptr operand_2
	call FloatToStr                   ; подготовка строк, содержащх значения операндов
	  
        ; вычисления с использованием сопроцессора
        finit
        fld operand_1          ; a в ST(0)
        fsub operand_2         ; a - b в ST(0)
        fld operand_1          ; a в ST(0), a - b в ST(1)
        fadd operand_2         ; a + b в ST(0), a - b в ST(1)
        fmul ST(0), ST(0)      ; (a + b)^2 в ST(0), a - b в ST(1)
        fdiv ST(0), ST(1)      ; (a + b)^2 / (a - b) в ST(0), a - b в ST(1)
        fstp result
        fstp operand_1

	push offset resultStr
	push dword ptr result + 4
	push dword ptr result
	call FloatToStr             ; получение строки, содержащей ответ
	
       	push offset resultStr
	push offset operand_2Str
	push offset operand_1Str
	push offset operand_2Str
	push offset operand_1Str
	push offset finalOutputTemplate
	push offset finalOutput
	call wsprintf 
	
       	push offset finalOutput
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset finalOutput
	push outputHandle
	call WriteConsole
	
	; в качестве паузы
	push NULL
	push offset numberOfChars
	push 1
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	push 0
	call ExitProcess

end entryPoint 

;||||||||||||||||||||||| DEBUG |||||||||||||||||||||||||||	
.data
	debugTemplate db "read value is %s", 10, 13, 0  
	debugMessage db 256 dup(0)
	operand_1Str db 256 dup(0)
.code   
	push offset operand_1Str 
	push dword ptr operand_1 + 4
	push dword ptr operand_1
	call FloatToStr

	push offset operand_1Str
	push offset debugTemplate
	push offset debugMessage
	call wsprintf
	
       	push offset debugMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset debugMessage 
	push outputHandle
	call WriteConsole
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||