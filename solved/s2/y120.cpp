#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include "bits/stdc++.h"

using namespace std;
// #define int long long
#define REP(i, n) for (int i = 0; i < (n); i++)
#define FOR(i, a, b) for (int i = (a); i < (b); i++)
#define FORR(i, a, b) for (int i = (b - 1); i >= (a); i--)
#define ALL(a) begin(a), end(a)
#define let const auto
int scan() {
  int result = 0;
  while (true) {
    auto k = getchar_unlocked();
    if (k < '0') break;
    result = 10 * result + k - '0';
  }
  return result;
}
int solve() {
  let n = scan();
  vector<int> L(n);
  REP(i, n) L[i] = scan();
  sort(ALL(L));
  vector<int> R;
  R.push_back(1);
  FOR(i, 1, n) {
    if (L[i - 1] == L[i])
      R[R.size() - 1] += 1;
    else
      R.push_back(1);
  }
  if (R.size() < 3) return 0;
  priority_queue<int> q;
  REP(i, R.size()) q.push(R[i]);
  int ans = 0;
  while (true) {
    let a = q.top() - 1;
    q.pop();
    let b = q.top() - 1;
    q.pop();
    let c = q.top() - 1;
    q.pop();
    if (a < 0 || b < 0 || c < 0) return ans;
    ans += 1;
    q.push(a);
    q.push(b);
    q.push(c);
  }
  return ans;
}
signed main() {
  let n = scan();
  REP(_, n) printf("%d\n", solve());
}
