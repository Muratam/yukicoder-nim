#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include <stdio.h>
#include <vector>
// #include <bits/stdc++.h>

using namespace std;
#define int long long
#define REP(i, n) for (int i = 0; i < (n); i++)
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
int get_median(int* A, int start, int end) {
  int len = end - start;
  if (len <= 5) {
    int ls[len];
    for (int i = 0; i < len; i++) ls[i] = A[start + i];
    nth_element(ls, ls + len / 2, ls + len);
    return ls[len / 2];
  }
  int l = (end - start) / 5;
  int ls[l + 1];
  for (int i = 0; i < l; i++)
    ls[i] = get_median(A, start + i * 5, start + (i + 1) * 5);
  int left_len = (end - start) % 5;
  int x = 0;
  if (left_len == 0)
    x = get_median(ls, 0, l);
  else {
    int left[left_len];
    for (int i = 0; i < left_len; i++) left[i] = A[start + 5 * l + i];
    ls[l + 1] = get_median(left, 0, left_len);
    x = get_median(ls, 0, l + 1);
    l += 1;
  }
  // x で配列を分割
  // ls[l] 有る.
}

int Y[1000010];
signed main() {
  int n = scan();
  REP(i, n) Y[i] = scan();
  int mid = get_median(Y, 0, n);
  // nth_element(Y, Y + n / 2, Y + n);  クイックセレクト
  // int mid = Y[n / 2];
  int ans = 0;
  REP(i, n) ans += abs(Y[i] - mid);
  printf("%lld\n", ans);
}
