#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
	lista_t* l = malloc(sizeof(lista_t));
	l->head = NULL;
	return l;
}

uint32_t longitud(lista_t* lista) {
	int amount = 0;
	nodo_t* nodo = lista->head;
	while(nodo) {
		amount++;
		nodo = nodo->next;
	}
	return amount;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
	nodo_t* new_node = malloc(sizeof(nodo_t));
	new_node->longitud = longitud;
	new_node->next = NULL;	
	uint32_t* miArreglo = calloc(longitud, sizeof(uint32_t));
	memcpy(miArreglo, arreglo, longitud*sizeof(uint32_t));
	new_node->arreglo = miArreglo;
	
	// Should put this at the end smhw
	nodo_t* pointer = lista->head;
	if (!pointer) {
		lista->head = new_node;	
	} else {
		while(pointer->next) {
			pointer = pointer->next;
		}

		pointer->next = new_node;
	}
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
	nodo_t* n = lista->head;
	for (uint32_t j = 0; j < i; j++) {
		n = n->next;
	}
	return n;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
	nodo_t* n = lista->head;
	uint64_t amount = 0;
	while(n) {
		amount += n->longitud;
		n = n->next;
	}
	return amount;
}

void imprimir_lista(lista_t* lista) {
	nodo_t* n = lista->head;
	while(n) {
		printf("| %ld |", n->longitud);
		printf(" -> ");
		n = n->next;
	}
	printf("null");
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
	for (uint64_t i = 0; i < size_of_array; i++) {
		if (*array == elemento_a_buscar) return 1;
		array++;
	}
	return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
	nodo_t* n = lista->head;
	while(n) {
		if (array_contiene_elemento(n->arreglo, n->longitud, elemento_a_buscar)) return 1;
		n = n->next;
	}
	return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
	nodo_t* n = lista->head;
	while (n) {
		nodo_t* temp = n;
		n = n->next;
		free(temp->arreglo);
		free(temp);
	}
	free(lista);
}
