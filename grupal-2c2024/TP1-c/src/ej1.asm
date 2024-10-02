section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
align 16
red_mask:   db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00
            db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00

green_mask: db 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 
            db 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00

blue_mask:  db 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00
            db 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00 

red:    dd 0.2126, 0.2126, 0.2126, 0.2126  

green:  dd 0.7152, 0.7152, 0.7152, 0.7152

blue:   dd 0.0722, 0.0722, 0.0722, 0.0722

shufl_msk:  db 0x00, 0x00, 0x00, 0xFF, 0x01, 0x01, 0x01, 0xFF
			db 0x02, 0x02, 0x02, 0xFF, 0x03, 0x03, 0x03, 0xFF
align 16		   
suma_mask: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF
		   db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Convierte una imagen dada (`src`) a escala de grises y la escribe en el
; canvas proporcionado (`dst`).
;
; Para convertir un píxel a escala de grises alcanza con realizar el siguiente
; cálculo:
; ```
; luminosidad = 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul 
; ```
;
; Como los píxeles de las imágenes son RGB entonces el píxel destino será
; ```
; rojo  = luminosidad
; verde = luminosidad
; azul  = luminosidad
; alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej1
ej1:
	; r/m64 = rgba_t*  dst[rdi]
	; r/m64 = rgba_t*  src[rsi]
	; r/m32 = uint32_t width[edx]
	; r/m32 = uint32_t height[ecx]
	push rbp
	mov rbp, rsp

	imul rdx, rcx; cantidad total de pixeles
	imul rdx, 0x04;   cantidad total de bytes
ciclo:
	cmp rdx, 0
	je end
	movdqu xmm0, [rsi] ; rojo 
	movdqu xmm1, xmm0  ; verde
	movdqu xmm2, xmm0  ; azul

	;rojo 
	PAND xmm0, [red_mask] ; pongo 0 en todos lados menos donde esta el rojo
	cvtdq2ps xmm0 , xmm0
	mulps xmm0 , [red]  ; multiplico los rojos por 0.2126


	;verde
	PAND xmm1, [green_mask]
	PSRLDQ xmm1, 0x01 ; shifteo para alinear
	cvtdq2ps xmm1, xmm1
	mulps xmm1, [green]

	;blue
	PAND xmm2, [blue_mask]
	PSRLDQ xmm2, 0x02
	cvtdq2ps xmm2, xmm2
	mulps xmm2, [blue]
	
	;manipulacion de bytes
	addps xmm0, xmm1
	addps xmm0, xmm2 ; sumo registros para obtener luminosidad pedida
	cvttps2dq xmm0, xmm0 ; los convierto a enteros de 32 bits
	PACKUSDW xmm0, xmm0 ; convierto de 32 bits a 16 (ojo me los guarda en la parte baja uno pegado a otro)
	PACKUSWB xmm0, xmm0 ; convierto de 16 bits a 8
	pshufb xmm0, [shufl_msk] ; ordeno la suma se los colores de cada pixel donde corresponde
	paddb xmm0, [suma_mask] ; sumo byte a byte para agregar el 255

	movdqu [rdi], xmm0
	add rdi, 16
	add rsi, 16
	sub rdx, 16
	jmp ciclo
end:
	mov rsp, rbp
	pop rbp
	ret

