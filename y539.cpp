#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include "bits/stdc++.h"

using namespace std;
// #define int long long
#define REPI(i) for (int i = 0;; i++)
#define REP(i, n) for (int i = 0; i < (n); i++)
#define FOR(i, a, b) for (int i = (a); i < (b); i++)
#define FORR(i, a, b) for (int i = (b - 1); i >= (a); i--)
#define ALL(a) begin(a), end(a)
#define let const auto
int scan() {
  int result = 0;
  while (true) {
    auto k = getchar_unlocked();
    if (k < '0' || k > '9') return result;
    result = 10 * result + k - '0';
  }
}
char S[100010];
void reduce(int x, int y, int size) {
  if (x == -1) {
    puts(S);
    return;
  }
  let sx = S[x];
  let sy = S[y];
  S[x] = '\0';
  S[y] = '\0';
  fputs(S, stdout);
  S[y] = sy;
  S[x] = sx;
  auto carry = 1;
  FORR(i, x, y + 1) {
    let c = S[i] - '0';
    let d = c + carry;
    if (d < 10) {
      S[i] = "0123456789"[d];
      carry = 0;
    } else {
      S[i] = '0';
      carry = 1;
    }
  }
  if (carry == 1) putchar_unlocked('1');
  puts(S + x);
}
signed main() {
  let n = scan();
  REP(_, n) {
    gets(S);
    auto i = 0;
    auto x = -1;
    auto y = -1;
    auto preIsAlpha = true;
    let size = strlen(S);
    FORR(i, 0, size) {
      let k = S[i];
      let isAlpha = k < '0' || '9' < k;
      if (!isAlpha) {
      }
    }
    REPI(i) {
      let k = S[i];
      if (k == '\0') {
        reduce(x, y, i);
        break;
      }
      let isAlpha = k < '0' || '9' < k;
      if (!isAlpha) {
        y = i;
        if (preIsAlpha) x = i;
      }
      preIsAlpha = isAlpha;
    }
  }
}
