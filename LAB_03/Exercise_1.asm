.486
.model flat, stdcall
option casemap :none 
include windows.inc
include kernel32.inc
include masm32.inc
includelib kernel32.lib
includelib masm32.lib

; ѕ–ќ√–јћћј ¬≈ƒ≈“ —≈Ѕя Ќ≈јƒ≈ ¬ј“Ќќ, ≈—Ћ» Ќ≈ ”„»“џ¬ј“№:
; «ƒ≈—№ ќѕ≈–јЌƒџ ¬ћ≈ўјё“ ћј —»ћ”ћ 2^32 !
; «ƒ≈—№ ѕ–» ”ћЌќ∆≈Ќ»» „»—≈Ћ, ≈—Ћ» –≈«”Ћ№“ј“ ЅќЋ№Ў≈ 2^32, “≈–яё“—я –ј«–яƒџ !

.data 
	numberOfCharsToRead dd 255
	operand_1 dd 0
	operand_2 dd 0 
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
	
	;==================== получение 1 числа ======================  
	; чтение первого числа из потока
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	; добавление 0 в конец строки
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0 
	
	push offset inputBuffer
	call atodw
	; как срабатывает:
	; если вводить не только цифры, тогда будет
	; (на заметку: у " " значение 240)
	; " " - это 240
	; " 1" - это 2401
	; "1 " - это 250
	; "1 1" - это 2501	
	
	; помещение полученного числа от функции atodw в переменную
	mov operand_1, EAX
	;=============================================================
	
	;==================== получение 2 числа ====================== 
	; чтение второго числа из потока
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	; добавление 0 в конец строки
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0 
	
	push offset inputBuffer
	call atodw
	
	; помещение полученного числа от функции atodw в переменную
	mov operand_2, EAX
	;============================================================= 
	
.data
     	resultOfAdd db 10 dup(" ") ; строка дл€ вывода результата в консоль
	; максимальное значение результата операции будет 2^32 (4294967296)
	resultOfSub db 10 dup(" ") ; строка дл€ вывода результата в консоль
	; максимальное значение результата операции будет 2^32 (4294967296)
	resultOfMul db 10 dup(" ") ; строка дл€ вывода результата в консоль
	; максимальное значение результата операции будет 2^64, но буду считать , что 2^32
	resultOfDiv db 10 dup(" ") ; строка дл€ вывода результата в консоль
	; максимальное значение результата операции будет 2^16 (65536)
     	messageString db 10, "sum: "
.code
	;================ вычисление и вывод суммы =================== 
	mov EAX, operand_1
	add EAX, operand_2
	
	push offset resultOfAdd
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 6 ; <-- размер messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; размер строки resultOfAdd
	push offset resultOfAdd
	push outputHandle
	call WriteConsole	                                                              
	;============================================================= 
	
	;================ вычисление и вывод разности ================
	; изменение messageString на "sub: "
	mov EDX, offset messageString
	mov byte ptr [ EDX + 3 ], "b"
	
	mov EAX, operand_1
	sub EAX, operand_2
	
	push offset resultOfSub
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 6 ; <-- размер messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; размер строки resultOfSub
	push offset resultOfSub
	push outputHandle
	call WriteConsole
	;=============================================================
	
	;================ вычисление и вывод умножени€ ===============
	; изменение messageString на "mul: "
	mov EDX, offset messageString
	mov byte ptr [ EDX + 1 ], "m"
	mov byte ptr [ EDX + 3 ], "l"
	
	mov EAX, operand_1
	mul operand_2
	
	push offset resultOfMul
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 6 ; <-- размер messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; размер строки resultOfMul
	push offset resultOfMul
	push outputHandle
	call WriteConsole
	;=============================================================
	
	;================ вычисление и вывод делени€ =================
	; изменение messageString на "div: "
	mov EDX, offset messageString
	mov byte ptr [ EDX + 1 ], "d"
	mov byte ptr [ EDX + 2 ], "i"
	mov byte ptr [ EDX + 3 ], "v"    
	
        mov EAX, operand_1
        mov EDX, 0 ; этот регистр тоже используетс€ командой
        div operand_2

	push offset resultOfDiv
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 6 ; <-- размер messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; размер строки resultOfDiv
	push offset resultOfDiv
	push outputHandle
	call WriteConsole
	;=============================================================
	
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