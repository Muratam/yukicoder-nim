import sequtils,strutils,algorithm,math,sugar,macros,strformat
template times*(n:int32,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    else: result = 10 * result + k.ord.int32 - '0'.ord.int32

proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}

let n = scan()
let m = scan()
var S: array[10_0010,char]
for i in 0..<n:S[i] = getchar_unlocked()
discard getchar_unlocked()
var D = newSeq[int32]()
var C = newSeq[int32]()
var A = newSeq[int32]()
var ans = newSeq[int32](n)
m.times:
  var u = scan() - 1
  var v = scan() - 1
  if S[u] < S[v]: u.swap(v)
  if S[u] == 'P' and S[v] == 'D'   : ans[v] += 1
  elif S[u] == 'D' and S[v] == 'C' :
    D &= u
    C &= v
  elif S[u] == 'C' and S[v] == 'A' : A &= u
for i in 0..<D.len: ans[C[i]] += ans[D[i]]
echo A.mapIt(ans[it]).sum() mod 1000000007