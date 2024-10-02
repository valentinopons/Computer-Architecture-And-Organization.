#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int is_vowel(char c) {
	if (c >= 'A' && c <= 'Z') c = c + ('a' - 'A'); //Magia de la practica con ascii
	if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u') return 1;
	return 0;
}

void classify_chars_in_string(char* string, char** vowels_and_cons) {
	// Asumo que todo en el string está entre 'a' y 'Z'.
	char* vowels = vowels_and_cons[0];
	char* cons = vowels_and_cons[1];

	while(*string) {
		if (is_vowel(*string)) {
			*vowels = *string;
			vowels++;
		} else {
			*cons = *string;
			cons++;
		}
		string++;
	}
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
	for (uint64_t i = 0; i < size_of_array; i++) {
		char** vowels_and_cons = (char**)calloc(2, sizeof(char*));

		int max_size = 64;
		vowels_and_cons[0] = calloc(max_size+1, sizeof(char));
		vowels_and_cons[1] = calloc(max_size+1, sizeof(char));

		array[i].vowels_and_consonants = vowels_and_cons;
		classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);
	}
}
