#pragma GCC optimize("O3")
#pragma GCC target("avx")
#include "bits/stdc++.h"

using namespace std;
#define REP(i, n) for (int i = 0; i < (n); i++)
#define FOR(i, a, b) for (int i = (a); i < (b); i++)
#define FORR(i, a, b) for (int i = (b)-1; i >= (a); i--)
int scan() {
  int result = 0;
  while (true) {
    auto k = getchar_unlocked();
    if (k < '0' || k > '9') break;
    result = 10 * result + k - '0';
  }
  return result;
}
double calc(int a, int b, double t) {
  if (a == 0) return exp(pow(t, 1.0 / b));
  if (b == 0) return pow(t, 1.0 / a);
  double x = log(11);
  double logt = log(t);
  REP(i, 10) {
    double h = a * exp(x);
    double f = h + b * x - logt;
    double g = h + b;
    x -= f / g;
  }
  return exp(exp(x));
}

int A[1000010], B[1000010];
double T[1000010], ANS[1000010];
int main() {
  auto m = scan();
  REP(i, m) {
    A[i] = scan();
    B[i] = scan();
    scanf("%lf\n", &T[i]);
  }
  // REP(i, m) printf("%d %d %.9lf\n", A[i], B[i], T[i]);
  REP(i, m) ANS[i] = calc(A[i], B[i], T[i]);
  REP(i, m) printf("%.9lf\n", ANS[i]);
}