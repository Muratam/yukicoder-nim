# {.checks:off.}
import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
let S = stdin.readLine()
var P = newSeq[int]()
var pre = S[0]
var now = 0
for c in S:
  if pre == c:
    now += 1
  else:
    P.add now
    now = 1
  pre = c
P.add now
var ans = 0
if S[0] == '>':
  ans += (P[0] * (1 + P[0])) div 2
  if P.len == 1:
    echo ans
    quit 0
  P = P[1..^1]
for i in 0..<P.len:
  ans += (P[i] * (1 + P[i])) div 2
for i in 0.countup(P.len-1,2):
  if i+1 >= P.len: continue
  ans -= P[i].min(P[i+1])
echo ans
