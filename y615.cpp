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
  int result = 0;
  while (true) {
    auto k = getchar_unlocked();
    if (k < '0' || k > '9')
      break;
    else
      result = 10 * result + k - '0';
  }
  return result;
}
int A[50010];
signed main() {
  let n = scan();
  let k = scan();
  REP(i, n) A[i] = scan();
  sort(A, A + n);
  REP(i, n - 1) A[i] = A[i + 1] - A[i];
  sort(A, A + n - 1);
  int ans = 0;
  REP(i, n - k) ans += A[i];
  printf("%lld\n", ans);
}