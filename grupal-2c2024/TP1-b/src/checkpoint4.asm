extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	mov al, [rdi]
	mov cl ,[rsi]	  
	cmp al, cl ; comparo primer caracter  de a con el de b
	jl a_menor
	jg b_menor
	je iguales

a_menor:
	mov rdi , 1
	mov rax , rdi
	ret
b_menor:
	mov rdi , -1
	mov rax , rdi
	ret 
iguales:
	cmp al , 0
	jne siguiente_caracter
	mov rax , 0 
	ret
	
siguiente_caracter:
	add rsi , 1 ;muevo un byte al siguiente caracter de a
	add rdi , 1 ; "		"		"		"		"		b
	jmp strCmp
	


; char* strClone(char* a)
strClone:
; primero voy a contar cuantos elementos tiene el string original
	push rbp; prologo
	mov rbp,rsp
	sub rsp , 32 ; 16 bytes para el rbp y rpi , 16 bytes variables locales

	mov [rbp + 16] , rdi ; [rbp + 16] = puntero a char (a)
	CALL strLen
	mov rdi , rax ; rdi = longitud del string
;reservo memoria en el heap
	add rdi , 1 ; sumo 1 para el caracter de terminacion "\0"
	CALL malloc ; rax = puntero a primer direccion de memoria en el heap
	mov r8 , rax ; guardo en r8 el puntero al primer elemento de la copia en el heap
	mov r9 , r8  ; r9 va a hacer el puntero el cual voy a ir iterando sobre la memoria del heap a la cual pedimos 
	mov rdi, [rbp+16] ; vuelvo a poner en rdi al puntero a
	jmp condicion1
	
condicion1:
	mov al , [rdi] ; al =  char que es apuntado por  "a"
	cmp al , 0 ; si estoy parado en el char terminal salto sino sigo
	je termina1
	mov [r9], al ; agrego char a mi copia en el heap
	add rdi , 1	; muevo puntero en 1 byte hacia el siguiente caracter
	add r9 , 1 ; muevo puntero en 1 byte en mi copia
	jmp condicion1

termina1:
	mov byte [r9] , 0 ; pongo simbolo de terminacion del string (\0)
	mov rax , r8 ;recordar que r8 es puntero al primer elemento de la copia
	;epilogo
	mov rsp, rbp 
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	CALL free
	ret


; void strPrint(char* a, FILE* pFile)
strPrint:
; voy a utilizar syscall para escribir el archivo
	; prologo
	push rbp
	mov rbp,rsp
	sub rsp , 32 ;
	mov [rbp +16] , rdi ; guardo parametros de la funcion para no perderlos luego del CALL
	mov [rbp +24] , rsi

	;preparo parametros del syscall
	CALL strLen
	mov rdx , rax ; rdx = la cantidad de bytes que voy a necesitar en el syscall
	mov rax , 1 ; rax = 1 indica a syscall la funcion de write
	mov rsi , [rbp+16] ; en rsi va el puntero al comienzo del string a escribir
	mov rdi , [rbp+24]  ; en rdi va el puntero al archivo a escribir
	syscall

	;epilogo
	mov rsp, rbp ;epilogo
	pop rbp

	;termino ejecucion del syscall
	mov rax, 60
	xor rdi, rdi
	syscall


; uint32_t strLen(char* a)
strLen:

	mov r8 , 0 ; inicializo contador
	jmp condicion2
condicion2: 
	mov al , [rdi] ; [rdi] = char
	cmp al , 0 ;
	je termina2
	add r8 , 1
	add rdi , 1
	jmp condicion2

termina2: 
	mov rax, r8
	ret
	


