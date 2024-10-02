extern esNill

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	8
LONGITUD_OFFSET	EQU	24

PACKED_NODO_LENGTH	EQU	8
PACKED_LONGITUD_OFFSET	EQU	17

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed
global funcionA

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	push rbp; prologo
	mov rbp,rsp
	sub rsp, 16
 
	mov qword [rbp-8] , 0 ; contador en la pila inicializado en 0 ([rbp -8])
	mov [rbp-16], rdi ; guardo en la pila a lista ([rbp -16])
	mov rcx, [rbp-16] ; rcx = lista
	mov rcx, [rcx]	  ; rcx = lista.head
	jmp condicion

condicion:
	cmp rcx, 0;   //  si rcx es 0 entonces la lista es vacia
	je end ;   // salto al final 

	;cargar nodo actual
	mov rsi, [rcx + 24]
	add [rbp-8], rsi
	
	;siguiente nodo
	mov rcx, [rcx] ; // rcx = (lista.head).next
 
	jmp condicion

end:
	mov rax, [rbp-8]
	mov rsp, rbp
	pop rbp
	ret

	

	

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	push rbp; prologo
	mov rbp,rsp
	sub rsp, 16
 
	mov qword [rbp-8] , 0 ; contador en la pila inicializado en 0 ([rbp -8])
	mov [rbp-16], rdi ; guardo en la pila a lista ([rbp -16])
	mov rcx, [rbp-16] ; rcx = lista
	mov rcx, [rcx]	  ; rcx = lista.head
	jmp condicion1

condicion1:
	cmp rcx, 0;   //  si rcx es 0 entonces la lista es vacia
	je end1 ;   // salto al final 

	;cargar nodo actual
	mov rsi, [rcx + 17]
	add [rbp-8], rsi
	
	;siguiente nodo
	mov rcx, [rcx] ; // rcx = (lista.head).next
 
	jmp condicion1
end1:
	mov rax, [rbp-8]
	mov rsp, rbp
	pop rbp
	ret
	


