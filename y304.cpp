#include <stdio.h>
#include <stdlib.h>
#include <iomanip>
#include <iostream>
#include <string>
using namespace std;
int used[999] = {};
string str;
int main() {
  ios::sync_with_stdio(false);
  cin.tie(0);
  cout.fill('0');
  srand(0);
  while (1) {
    int i = 0;
    while (used[i]) i = rand() % 1000;
    used[i] = 1;
    cout << setw(3) << i << endl;
    cin >> str;
    if (str[0] == 'u') return 0;
  }
}