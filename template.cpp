#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include "bits/stdc++.h"

using namespace std;
#define int long long
#define REP(i, n) for (int i = 0; i < (n); i++)
#define FOR(i, a, b) for (int i = (a); i < (b); i++)
#define FORR(i, a, b) for (int i = (b); i >= (a); i--)
#define ALL(a) begin(a), end(a)
#define let const auto
int scan() {
  auto minus = false;
  int result = 0;
  while (true) {
    auto k = getchar_unlocked();
    if (k == '-')
      minus = true;
    else if (k < '0' || k > '9')
      break;
    else
      result = 10 * result + k - '0';
  }
  return result * (minus ? -1 : 1);
}
signed main() {
  let n = scan();
  let m = scan();
  printf("%lld", n);
}
