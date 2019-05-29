#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include <iostream>
#include <vector>
using namespace std;
#define int long long
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

bool judge(int i0,int i1,int i2,int i3,int i4,int i5,int i6,int i7,int i8,int i9){
  auto ok = true;
  vector<int> F = {i0, i1, i2, i3, i4, i5, i6, i7, i8, i9};
  REP(mi, m) {
    auto num = 0;
    for (auto s : S[mi]) {
      if (F[s]) num += 1;
    }
    if (P[mi] != num % 2) {
      ok = false;
      break;
    }
  }
  if (ok) ans += 1;
}

signed main() {
  let n = scan();
  let m = scan();
  //電球mがつながっているswitch番号(0から)
  auto S = vector<vector<int>>(m);
  REP(i, m) {
    let k = scan();
    S[i] = vector<int>(k);
    REP(j, k) S[i][j] = scan() - 1;
  }
  auto P = vector<int>(m);
  REP(i, m) P[i] = scan();
  //全探索すればいい
  auto ans = 0;
  REP(i0, 2) {
    REP(i1, 2) {
      REP(i2, 2) {
        REP(i3, 2) {
          REP(i4, 2) {
            REP(i5, 2) {
              REP(i6, 2) {
                REP(i7, 2) {
                  REP(i8, 2) {
                    REP(i9, 2) {

                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  ans = ans >> (10 - n);
  cout << ans << endl;
}
