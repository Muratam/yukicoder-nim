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
int scan() {
  int result = 0;
  while (true) {
    auto k = getchar_unlocked();
    if (k < '0' || k > '9') return result;
    result = 10 * result + k - '0';
  }
}

// proc build(P:seq[int]) : seq[int] =
//   var answer = newSeq[int](^P.len)
//   proc impl(n,x:int) = # 1つずつ
//     if n == P.len : return
//     answer[x or ^n] = answer[x] + P[n]
//     impl(n+1,x)
//     impl(n+1,x or ^n)
//   impl(0,0)
//   return answer
void impl(vector<int>& answer, int n, int x, int maxN) {
  if (n == maxN) return;
  answer[x | 1 << n] = answer[x] + P[n]
}
vector<int> build(const vector<int>& P) {
  auto answer = vector<int>(1 << P.size());
  impl(answer, 0, 0, P.size());
  return answer;
}
signed main() {
  let n = scan();
  let s = scan();
  if (n == 1) {
    printf("1\n");
    return 0;
  }
  let n2 = n / 2;
  auto P1 = vector<int>(n / 2);
  auto P2 = vector<int>(n - n / 2);
  REP(i, n / 2) P1[i] = scan();
  REP(i, n - n / 2) P2[i] = scan();

  printf("%lld", n);
}
/*

proc buildWithKey(P:seq[int]) : seq[tuple[k,v:int]] =
  var answer = newSeq[tuple[k,v:int]](^P.len)
  proc impl(n,x:int) =
    if n == P.len : return
    answer[x or ^n].v = answer[x].v + P[n]
    answer[x or ^n].k = x or ^n
    impl(n+1,x)
    impl(n+1,x or ^n)
  impl(0,0)
  return answer

proc binaryToIntSeq(n:int):seq[int] =
  result = @[]
  for i in 0..64:
    if (n and ^i) > 0: result &= i + 1
    if n < ^(i+1) : return
stopwatch:
  let I1 = P1.build()
  let I2 = P2.buildWithKey().sortedByIt(it.v)
stopwatch:
  var answers = newSeq[int]()
  for x,i1 in I1:
    let si = I2.binarySearch(s-i1,proc(K:tuple[k,v:int],V:int):int=K.v-V)
    if si == -1 : continue
    answers &= x or (I2[si].k shl n2)
    for i in (si+1)..<I2.len:
      if I2[i].v + i1 != s: break
      answers &= x or (I2[i].k shl n2)
    for i in (si-1).countdown(0):
      if I2[i].v + i1 != s: break
      answers &= x or (I2[i].k shl n2)
  for ans in answers.map(binaryToIntSeq).sorted(cmp):
    echo ans.mapIt($it).join(" ")
*/