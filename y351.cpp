#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include "bits/stdc++.h"

using namespace std;
#define REP(i, n) for (int i = 0; i < (n); i++)
#define FOR(i, a, b) for (int i = (a); i < (b); i++)
#define FORR(i, a, b) for (int i = (b - 1); i >= (a); i--)
#define ALL(a) begin(a), end(a)
#define let const auto
int scan() {
  int result = 0;
  while (true) {
    auto k = getchar_unlocked();
    if (k < '0') return result;
    result = 10 * result + k - '0';
  }
}
int ops[1000010];  // 16bit?
bool isC[1000010];
signed main() {
  let h = scan();
  let w = scan();
  let n = scan();
  REP(i, n) {
    isC[i] = getchar_unlocked() == 'C';
    getchar_unlocked();
    ops[i] = scan();
  }
  int x = 0;
  int y = 0;
  FORR(i, 0, n) {
    let op = ops[i];
    if (isC[i]) {
      if (x != op) continue;
      if (y == 0)
        y = h - 1;
      else
        y -= 1;
    } else {
      if (y != op) continue;
      if (x == 0)
        x = w - 1;
      else
        x -= 1;
    }
  }
  if (x % 2 == y % 2)
    printf("white\n");
  else
    printf("black\n");
}
