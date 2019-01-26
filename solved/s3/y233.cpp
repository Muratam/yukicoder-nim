#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include "bits/stdc++.h"
// #define _CRT_SECURE_NO_WARNINGS
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
    if (k < '0' || k > '9') break;
    result = 10 * result + k - '0';
  }
  return result;
}
char S[] = "aaeiuu";
char C[] = "bgmnr";
char SC[] = "aaeiuubgmnr";
auto used = unordered_set<size_t>();
auto used_end = used.end();
bool check(const char* str) {
  if (used.find(hash<string>()(str)) == used_end) {
    printf("%s\n", str);
    return true;
  }
  return false;
}
char cache[] = "inabameguru";
signed main() {
  let n = scan();
  if (n == 129600) {  // 最大値は計算で出せる
    printf("NO\n");
    return 0;
  }
  REP(_, n) {
    REP(i, 11) cache[i] = getchar_unlocked();
    used.insert(hash<string>()(cache));
    getchar_unlocked();
  };
  used_end = used.end();
  do {
    do {
      SC[0] = S[0];
      REP(i, 5) {
        SC[i * 2 + 2] = S[i + 1];
        SC[i * 2 + 1] = C[i];
      }
      REP(i, 5) {
        if (check(SC)) return 0;
        swap(SC[i * 2], SC[i * 2 + 1]);
      }
      if (check(SC)) return 0;
    } while (next_permutation(begin(C), end(C) - 1));
  } while (next_permutation(begin(S), end(S) - 1));
}