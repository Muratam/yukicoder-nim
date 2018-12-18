#include <stdio.h>
#include <stdlib.h>
#include <time.h>
char str[12];
int used[999] = {};
int check[5] = {};
int oks[] = {123, 999, 114, 514, 99};
int main() {
  for (size_t k = 0; k < 1000000; k++) {
    srand(k);
    for (int i = 0; i < 1000; i++) used[i] = 0;
    for (int i = 0; i < 5; i++) check[i] = 0;
    for (int n = 0; n < 100; n++) {
      int i = 0;
      while (used[i]) i = rand() % 1000;
      used[i] = 1;
    }
    int ok = 1;
    for (int j = 0; j < 5; j++) {
      if (!used[oks[j]]) ok = 0;
    }
    if (ok) {
      printf("ok ! %d\n", k);
      return 0;
    } else {
      printf("%d\n", k);
    }
  }
}