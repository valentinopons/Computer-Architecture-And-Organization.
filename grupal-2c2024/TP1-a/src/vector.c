#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
	vector_t* v = malloc(sizeof(vector_t));
	uint32_t* array = calloc(4, sizeof(uint32_t));
	v->size = 0;
	v->capacity = 4;
	v->array = array;
	return v;
}

uint64_t get_size(vector_t* vector) {
	return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
	// 2 Casos: size+1 <= capacity o lo contrario
	if (vector->size+1 > vector->capacity) {
		vector->array = (uint32_t*)realloc(vector->array, (vector->capacity+4) *sizeof(uint32_t));
		vector->capacity += 4;
	}
	vector->array[vector->size] = elemento;
	vector->size++;
}

int son_iguales(vector_t* v1, vector_t* v2) {
	if(v1->size != v2->size) return 0;

	int res = memcmp(v1->array, v2->array, v1->size*sizeof(uint32_t));
	if (!res) return 1; //memcmp devuelve 0 si son iguales
	return 0;
}

uint32_t iesimo(vector_t* vector, size_t index) {
	if (index >= vector->size) return 0;
	return vector->array[index];
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out)
{
	*out = iesimo(vector, index);
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
	vector_t* max = array_de_vectores[0];
	for(size_t i = 1; i < longitud_del_array; i++) {
		vector_t* v = array_de_vectores[i];
		if (max->size < v->size) max = v;
	}
	return max;
}
