#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include "bits/stdc++.h"

using namespace std;
#define int long long
#define REP(i, n) for (int i = 0; i < (n); i++)
#define FOR(i, a, b) for (int i = (a); i < (b); i++)
#define FORR(i, a, b) for (int i = (b - 1); i >= (a); i--)
#define ALL(a) begin(a), end(a)
#define let const auto
const int N = 300010;
struct IsNotPrimes {
  bool data[N];
  constexpr IsNotPrimes() : data() {
    data[0] = true;
    data[1] = true;
    for (int i = 2; i * i < N; i++) {
      if (data[i]) continue;
      for (int j = i * 2; j < N; j += i) data[j] = true;
    }
  }
};

int scan() {
  int result = 0;
  while (true) {
    auto k = getchar_unlocked();
    if (k < '0' || k > '9') return result;
    result = 10 * result + k - '0';
  }
}
constexpr auto isNotPrimes = IsNotPrimes();
signed main() {
  let n = scan();
  let p = scan();
  if (p == 1 || (p >= n / 2 && !isNotPrimes.data[p])) {
    printf("1\n");
    return 0;
  }
  int ans = n / 2 - 1;
  FOR(i, n / 2 + 1, n + 1) {
    if (isNotPrimes.data[i]) ans += 1;
  }
  printf("%lld\n", ans);
}
