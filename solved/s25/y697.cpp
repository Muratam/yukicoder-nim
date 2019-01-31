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
bool isWater[3001][3001];
const int dx[] = {1, -1, 0, 0};
const int dy[] = {0, 0, 1, -1};
void check(int sx, int sy, int w, int h) {
  auto X = queue<int>();
  auto Y = queue<int>();
  X.push(sx);
  Y.push(sy);
  while (X.size() > 0) {
    auto x = X.back();
    auto y = Y.back();
    X.pop();
    Y.pop();
    isWater[x][y] = false;
    REP(i, 4) {
      let nx = dx[i];
      let ny = dy[i];
      if (nx < 0 or nx >= w) continue;
      if (ny < 0 or ny >= h) continue;
      if (!isWater[nx][ny]) continue;
      X.push(nx);
      Y.push(ny);
      isWater[nx][ny] = false;
    }
  }
}
signed main() {
  let h = scan();
  let w = scan();
  REP(y, h) REP(x, w) {
    isWater[x][y] = getchar_unlocked() == '1';
    getchar_unlocked();
  }
  int ans = 0;
  REP(y, h) REP(x, w) {
    if (!isWater[x][y]) continue;
    check(x, y, w, h);
    ans++;
  }
  printf("%d\n", ans);
}