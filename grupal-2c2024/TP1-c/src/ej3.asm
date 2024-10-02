section .text
align 16
shuffle_mask: db 0x00000000
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
shuffle_mask2: db 0x00, 0x80, 0x80, 0x80, 0x01, 0x80, 0x80, 0x80, 0x10, 0x80, 0x80,0x80, 0x11, 0x80, 0x80, 0x80
mask_opuesto: dd -1, -1, -1, -1
mask_1s: dd   1, 1, 1, 1

FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 3A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3a
global EJERCICIO_3A_HECHO
EJERCICIO_3A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal. [rdi]
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal. [rsi]
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.[rdx]
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.[rcx]
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.[r8]
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`. [r9]
global ej3a
ej3a:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = int32_t* dst_depth [rdi]
	; r/m64 = uint8_t* src_depth [rsi]
	; r/m32 = int32_t  scale     [rdx]
	; r/m32 = int32_t  offset	 [rcx]
	; r/m32 = int      width 	 [r8]
	; r/m32 = int      height	 [r9]

	push rbp 
	mov rbp, rsp
	xor rax, rax
	xor r10, r10
	imul r8, r9
	shr r8, 2
	;registro con 4 scale de 32 bits
	movd xmm3, edx ; scale se encuetra en la parte mas baja del registro
	pshufd xmm1, xmm3, 0x00000000
	;registro con 4 offsets de 32 bits
	movd xmm4, ecx
	pshufd xmm2, xmm4, 0x00000000
	jmp .loop
.loop:
	cmp r8, 0
	je end
	;funcion
	movd xmm0, [rsi + rax] ; cargo 32 bits, 4 pixeles
	pmovzxbd xmm0, xmm0
	pmulld xmm0, xmm1
	paddd xmm0 , xmm2

	movdqu [rdi + r10], xmm0
	add r10, 16
	add rax, 4
	dec r8
	jmp .loop
end:
	mov rsp, rbp
	pop rbp 
	ret

; Marca el ejercicio 3B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3b
global EJERCICIO_3B_HECHO
EJERCICIO_3B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.



global ej3b
ej3b:
	; r/m64 = rgba_t*  dst [rdi]
	; r/m64 = rgba_t*  a   [rsi]
	; r/m64 = int32_t* depth_a [rdx]
	; r/m64 = rgba_t*  b		[rcx]
	; r/m64 = int32_t* depth_b  [r8]
	; r/m32 = int      width    [r9]
	; r/m32 = int      height   [rbp+16]
	push rbp
	mov rbp, rsp
	mov r10, [rbp+16]
	imul r9, r10; cantidad total de pixeles
	xor rax, rax
	;preparo mascara para la comparacion en el futuro
	pxor xmm0, xmm0
	jmp .loop

.loop:
	cmp r9, 0
	je .end
	movdqu xmm1, [rdx + rax] ; xmm1 = depth_a
	movdqu xmm2, [r8  + rax]  ; xmm2 = depth_b
	movdqu xmm3, [rsi + rax] ; xmm3 = a
	movdqu xmm4, [rcx + rax] ; xmm4 = b

	;comparo profundidades
	pcmpgtd xmm2, xmm1
	pand  xmm3, xmm2 ; multiplico a con la mascara generada de la compracion

	PCMPEQD xmm2, xmm0
	pand xmm4, xmm2 ; agrego elementos de b 

	paddd xmm3, xmm4; combino valores de a con b
	movdqu [rdi + rax ], xmm3 ; agrego a dst el resultado

	add rax, 16
	sub r9, 4
	jmp .loop

.end:
	mov rsp, rbp
	pop rbp

	ret
