extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4:
	push rbp; prologo
	mov rbp,rsp

	sub rdi,rsi ; rdi = x1-x2
	sub rdx,rcx ; rdx = x3-x4
	add rdi,rdx ; rdi = (x1-x2) + (x3-x4)
	mov rax,rdi ; rax = valor de retorno

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	mov rsp,rbp;  restablezco el sp al base adress
	pop rbp	   ; popeo el valor del base adress (valor de funcion previa)
	ret        ;(retorno a la funcion previa)

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	CALL restar_c
	mov r8,rax   ; r8 = (x1-x2)

	mov rdi,rdx  ; rdi = x3
	mov rsi,rcx  ; rsi = x4
	CALL restar_c
	mov r9,rax  ; r9 = (x3-x4)
	
	mov rdi,r8
	mov rsi,r9
	CALL sumar_c

	;epilogo
	mov rsp, rbp
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_simplified:

	sub rdi,rsi ; rdi = x1-x2
	sub rdx,rcx ; rdx = x3-x4
	add rdi,rdx ; rdi = (x1-x2) + (x3-x4)
	mov rax,rdi ; rax = valor de retorno

	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+16], x8[rbp+24]
alternate_sum_8:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	sub rsp , 0x30 ; guardo 48 bytes 32 bytes para rip, x7 y x8. 16 bytes para (x1-x2+x3-x4)
	CALL alternate_sum_4
	mov [rbp + 32], rax
	mov rdi, r8
	mov rsi, r9
	mov rdx, [rbp+16]
	mov rcx, [rbp+24]
	CALL alternate_sum_4
	add rax, [rbp+32]

	;epilogo
	mov rsp, rbp
	pop rbp
	ret

; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:
    cvtsi2ss xmm1, rsi          ; Convierte el entero en RSI a float (32 bits) y almacena en XMM1  
    mulss xmm0, xmm1            ; Multiplica el valor en xmm0 (float) por el valor en xmm1 (float)

    ; Convertir el resultado de la multiplicación a entero truncando la parte fraccionaria
	cvttss2si rax, xmm0
    
    mov [rdi], eax              ; Guardar el resultado entero en la dirección de memoria apuntada por rdi
    
    ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[[rbp+16]], f6[xmm5], x7[[rbp+24]], f7[xmm6], x8[[rbp+32]], f8[xmm7],
;	, x9[[rbp+40]], f9[[rbp+48]]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp
	sub rsp, 64
	;convertimos los flotantes de cada registro xmm en doubles
	cvtss2sd xmm0,xmm0
	cvtss2sd xmm1,xmm1
	cvtss2sd xmm2,xmm2
	cvtss2sd xmm3,xmm3
	cvtss2sd xmm4,xmm4
	cvtss2sd xmm5,xmm5
	cvtss2sd xmm6,xmm6
	cvtss2sd xmm7,xmm7
	;me falta un float (el f9)
    

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0,xmm1
	mulsd xmm0,xmm2
	mulsd xmm0,xmm3
	mulsd xmm0,xmm4
	mulsd xmm0,xmm5
	mulsd xmm0,xmm6
	mulsd xmm0,xmm7
	movss xmm1 ,[rbp+48] ;agrego float faltante a xmm1, luego lo multiplico
	cvtss2sd xmm1,xmm1
	mulsd xmm0,xmm1

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	cvtsi2sd xmm1,rsi
	mulsd xmm0, xmm1
	cvtsi2sd xmm1,rdx
	mulsd xmm0, xmm1
	cvtsi2sd xmm1,rcx
	mulsd xmm0, xmm1
	cvtsi2sd xmm1,r8
	mulsd xmm0, xmm1
	cvtsi2sd xmm1,r9
	mulsd xmm0, xmm1
	cvtsi2sd xmm1,[rbp+16]
	mulsd xmm0, xmm1
	cvtsi2sd xmm1,[rbp+24]
	mulsd xmm0, xmm1
	cvtsi2sd xmm1,[rbp+32]
	mulsd xmm0, xmm1
	cvtsi2sd xmm1,[rbp+40]
	mulsd xmm0, xmm1

	movsd [rdi],xmm0
	; epilogo
	mov rsp, rbp
	pop rbp
	ret



