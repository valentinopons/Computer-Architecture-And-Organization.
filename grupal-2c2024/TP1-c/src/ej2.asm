section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
align 16
red_mask:   db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00
            db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00

green_mask: db 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 
            db 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00

blue_mask:  db 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00
            db 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00 
mask_0_3:   dd 3.0, 3.0, 3.0, 3.0
mask_64:    dd 64, 64, 64, 64
mask_128:   dd 128, 128, 128, 128
mask_192:    dd 192, 192, 192, 192
mask_384:   dd 384, 384, 384, 384
mask_4:      dd 4, 4, 4, 4
mask_0:		dd 0x00000000, 0x00000000, 0x00000000, 0x00000000
mask_255:   dd  255, 255, 255, 255, 255
alpha_mask:  db 0x00, 0x00, 0x00, 255, 0x00, 0x00, 0x00, 255
             db 0x00, 0x00, 0x00, 255, 0x00, 0x00, 0x00, 255 
section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Aplica un efecto de "mapa de calor" sobre una imagen dada (`src`). Escribe la
; imagen resultante en el canvas proporcionado (`dst`).
;
; Para calcular el mapa de calor lo primero que hay que hacer es computar la
; "temperatura" del pixel en cuestión:
; ```
; temperatura = (rojo + verde + azul) / 3
; ```
;
; Cada canal del resultado tiene la siguiente forma:
; ```
; |          ____________________
; |         /                    \
; |        /                      \        Y = intensidad
; | ______/                        \______
; |
; +---------------------------------------
;              X = temperatura
; ```
;
; Para calcular esta función se utiliza la siguiente expresión:
; ```
; f(x) = min(255, max(0, 384 - 4 * |x - 192|))
; ```
;
; Cada canal esta offseteado de distinta forma sobre el eje X, por lo que los
; píxeles resultantes son:
; ```
; temperatura  = (rojo + verde + azul) / 3
; salida.rojo  = f(temperatura)
; salida.verde = f(temperatura + 64)
; salida.azul  = f(temperatura + 128)
; salida.alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej2
ej2:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  src
	; r/m32 = uint32_t width
	; r/m32 = uint32_t height
	push rbp 
	mov rbp, rsp
	imul rdx, rcx; cantidad total de pixeles
	xor rax, rax
	shr rdx, 2
	jmp .ciclo

.ciclo:
	cmp rdx, 0
	je .end
	movdqu xmm0, [rsi + rax ] ; rojo 
	movdqu xmm1, xmm0  ; verde
	movdqu xmm2, xmm0  ; azul

	;rojo 
	PAND xmm0, [red_mask] ; pongo 0 en todos lados menos donde esta el rojo

	;verde
	PAND xmm1, [green_mask]
	PSRLDQ xmm1, 0x01 ; shifteo a la drecha para alinear

	;blue
	PAND xmm2, [blue_mask]
	PSRLDQ xmm2, 0x02

	paddd xmm0, xmm1
	paddd xmm0, xmm2 

	cvtdq2ps xmm0, xmm0
	movdqa xmm4, [mask_0_3]; 
	divps xmm0, xmm4; multiṕlico por 0.3 obteniendo la temperatura
	cvttps2dq xmm0, xmm0
	;green
	movdqu xmm1, xmm0; copia de temperatura en xmm1 
	movdqa xmm4, [mask_64]
	paddd xmm1, xmm4 ; sumo a cada temperatura 64 segun el enunciado

	;blue
	movdqu xmm2, xmm0; 
	movdqa xmm4, [mask_128]
	paddd xmm2, xmm4 ; sumo a cada temperatura 128 segun el enunciado

	;computo x-192 segun la funcion
	movdqa xmm4, [mask_192]
	psubd xmm0, xmm4
	psubd xmm1, xmm4
	psubd xmm2, xmm4
	; calculo su modulo
	pabsd xmm0,xmm0
	pabsd xmm1,xmm1
	pabsd xmm2,xmm2

	;multiplico por 4 segun la funcion
	movdqa xmm4, [mask_4]
	pmulld xmm0, xmm4
	pmulld xmm1, xmm4
	pmulld xmm2, xmm4

	movdqa xmm4, [mask_384]
	psubd xmm4, xmm0
	movdqu xmm0, xmm4
	movdqa xmm4, [mask_384]
	psubd xmm4, xmm1
	movdqu xmm1, xmm4
	movdqa xmm4, [mask_384]
	psubd xmm4, xmm2
	movdqu xmm2, xmm4
	; maximo entre 0 y 384 - 4|x-192|
	movdqa xmm4, [mask_0]
	pmaxsd xmm0, xmm4
	pmaxsd xmm1, xmm4
	pmaxsd xmm2, xmm4
	;minimo entre 255 y lo de arriba. Notar que el resultado de lo de arriba es si o si positivo 
	movdqa xmm4, [mask_255]
	pminud xmm0, xmm4 ; como son dos valores positivos uso unsigned
	pminud xmm1, xmm4
	pminud xmm2, xmm4

	;los valores que nos interesan estan todos en la pocicion del "rojo"
	;aplico mascara del rojo las 3 veces
	movdqa xmm4, [red_mask]
	PAND xmm0, xmm4
	PAND xmm1, xmm4
	PAND xmm2, xmm4

	psllq xmm1, 8 ; desplazo el verde 1 byte hacia la parte mas significativa
	psllq xmm2, 16 ; lo mismo con el azul pero 2 bytes

	PADDUSB xmm0, xmm1
	PADDUSB xmm0, xmm2
	movdqu xmm4, [alpha_mask]
	PADDUSB xmm0, xmm4

	movdqa [rdi + rax], xmm0

	add rax , 16
	dec rdx 
	jmp .ciclo

.end:
	mov rsp, rbp
	pop rbp 
	
	ret

