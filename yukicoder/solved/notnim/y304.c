#include <stdio.h>
#include <stdlib.h>
#include <time.h>
char str[12];
int used[999] = {};
int main() {
  srand(10262980);
  while (1) {
    int i = 0;
    while (used[i]) i = rand() % 1000;
    used[i] = 1;
    if (i < 10)
      printf("00%d\n", i);
    else if (i < 100)
      printf("0%d\n", i);
    else
      printf("%d\n", i);
    fflush(stdout);
    scanf("%s", str);
    if (str[0] == 'u') return 0;
  }
}