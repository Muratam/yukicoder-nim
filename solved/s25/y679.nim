import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc topologicalSort(E:seq[seq[int]]) : seq[int] =
  # E : [n->[m1,m2,m3], ... ]の隣接リスト を ソート
  var visited = newSeq[bool](E.len)
  var answer = newSeq[int]()
  proc visit(src:int) =
    if visited[src] : return
    visited[src] = true
    for dst in E[src]: visit(dst)
    answer &= src # 葉から順に追加される
  for src in 0..<E.len: visit(src)
  return answer


let n = scan()
let m = scan()
var E = newSeqWith(n+1,newSeq[int]())
m.times:
  let g = scan()
  let r = scan()
  r.times: E[g] &= scan()
var bought = newSeq[bool](n+1)
var ans = 0
for e in E.topologicalSort():
  if e == 0 : continue
  if E[e].len == 0 or E[e].allIt(bought[it]):
    ans += 1
    bought[e] = true
echo ans