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
using ll = long long;
using ull = unsigned long long;

ull seed;
ll next() {
  seed ^= (seed << 13);
  seed ^= (seed >> 7);
  seed ^= (seed << 17);
  return (seed >> 33);
}
const int len = 1 << 20;
const int divi = 11;
int B[len];
int AA[len];
int AALen[len] = {};
int A[200000];
signed main() {
  int n, q;
  cin >> n >> q >> seed;
  REP(i, 10000) next();
  // vector<int> A(n);
  REP(i, n) A[i] = next();
  sort(A, A + n);
  // AA
  REP(i, n) {
    let xi = A[i] >> divi;
    if (AALen[xi] == 0) AA[xi] = i;
    // AALen[xi] += 1;
  }
  int cnt = 0;
  REP(i, len) {
    B[i] = cnt;
    // cnt += AALen[i];
  }
  // impl
  ll sm = 0;
  REP(i, q) {
    ll x = next();
    auto xi = x >> divi;
    ll cnt = B[xi];
    if (AALen[xi] != 0) {
      if (AALen[xi] == 1) {
        if (A[AA[xi]] < x) cnt++;
      } else {
        REP(j, AALen[xi]) {
          if (A[AA[xi] + j] < x)
            cnt++;
          else
            break;
        }
      }
    }
    sm ^= cnt * i;
  }
  cout << sm << endl;
  return 0;
}