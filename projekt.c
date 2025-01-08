#include <stdio.h>

/*
nasm -f elf32 projekt.asm -o projekt.o
gcc -m32 projekt.c projekt.o -o projekt.exe
clear
./projekt.exe
*/

#define MAX_VAL(type) ((type)((1U << (sizeof(type) * 8 - 1)) - 1))

void clearInvalidInput() {
  while (getchar() != '\n')
    ;
}

extern float cos_asm(float x, int accuracy) asm("cos_asm");

int main() {
  printf("Kalkulator funkcji cos(x) z wykorzystaniem rozwinięcia w szereg "
         "Taylora\n");
  do {
    long double x = 0;
    unsigned int accuracy = 0, isInputValid = 0;
    printf("\nArgument funkcji cosinus: ");
    isInputValid = scanf("%Lf", &x);

    if (isInputValid == 0) {
      printf("Nie można przetworzyć argumentu!\n");
      clearInvalidInput();
      continue;
    }

    printf("Liczba cyfr po przecinku: ");
    isInputValid = scanf("%d", &accuracy);

    if (isInputValid == 0) {
      printf("Nie można przetworzyć liczby cyfr po przecinku!\n");
      clearInvalidInput();
      continue;
    } else if (accuracy < 0 || accuracy > MAX_VAL(unsigned int)) {
      printf("Liczba cyfr po przecinku musi być z zakresu [0, %u]!\n",
             MAX_VAL(unsigned int));
      continue;
    }

    float result = cos_asm(x, 20);
    printf("cos(x) = ~%.*f\n", accuracy, result);

    printf("Czy kontynuować? (y/n) ");
    char c;
    scanf(" %c", &c);
    if (c != 'y' && c != 'Y') {
      break;
    }
  } while (1);

  return 0;
}