#include <stdio.h>

// Każdy projekt powinien posiadać interfejs napisany
// w języku C (wprowadzanie danych z klawiatury, wypisywanie
// ich na ekran, nieskończona pętla programu itp.) oraz mieć
// logikę biznesową napisaną w asemblerze z wykorzystaniem
// FPU. Dodatkowo, każdy projekt powinien móc przyjąć
// dodatkowy argument w postaci liczby miejsc po przecinku, do
// której ma być zaokrąglony wynik. Liczbę tę podaje użytkownik
// z klawiatury.
// Napisać program, który oblicza e^x, gdzie x jest
// argumentem podanym przez użytkownika.

#define MAX_VAL(type) ((type)((1U << (sizeof(type) * 8 - 1)) - 1))

void clearInvalidInput() {
  while (getchar() != '\n')
    ;
}

extern float cos_asm(float x, int accuracy) asm(
    "cos_asm"); // explicitly tell GCC name of the asm function to use

int main() {
  printf("Cosinus calculator");
  do {
    long double x;
    unsigned int accuracy, isInputValid;
    printf("\nArgument: ");
    isInputValid = scanf("%Lf", &x);

    if (isInputValid == 0) {
      printf("Couldn't parse x!\n");
      clearInvalidInput();
      continue;
    } else if (x < 0 || x > MAX_VAL(float)) {
      printf("Value of x must be greater than 0 and less than %f\n",
             MAX_VAL(float));
      continue;
    }

    printf("Input accuracy (number of taylor series terms)\n");
    printf("Value: ");
    isInputValid = scanf("%d", &accuracy);

    if (isInputValid == 0) {
      printf("Couldn't parse accuracy!\n");
      clearInvalidInput();
      continue;
    } else if (accuracy < 0 || accuracy > MAX_VAL(unsigned int)) {
      printf("Accuracy must be greater than 0 and less than %d\n",
             MAX_VAL(unsigned int));
      continue;
    }

    float result = cos_asm(x, accuracy);
    printf("e^x = ~%.*f\n", accuracy, result);

    printf("Continue? (y/n) ");
    char c;
    scanf(" %c", &c);
    if (c != 'y' && c != 'Y') {
      break;
    }
  } while (1);

  return 0;
}