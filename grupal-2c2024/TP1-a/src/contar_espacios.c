#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
	if (string == NULL) return 0;
	int i = 0;
	while(*string) {
		i++;
		string++;
	}
	return i;
}

uint32_t contar_espacios(char* string) {
	if (string == NULL) return 0;
	int i = 0;
	while(*string) {
		if (*string == ' ') {
			i++;
		}
		string++;
	}
	
	return i;
}


// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("should be 5. %d\n", contar_espacios("hola   como andas? "));

    printf("should be algo. %d\n", contar_espacios(NULL));

    printf("should be 2. %d\n", contar_espacios(" holaaaa orga2"));
    return 0;
}
*/
