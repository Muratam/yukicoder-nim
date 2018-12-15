import sequtils,strutils,strscans,algorithm,math,future,macros
import sets,tables
template get*():string = stdin.readLine() #.strip()
template `max=`*(x,y:typed):void = x = max(x,y)
template optPow{`^`(2,n)}(n:int) : int = 1 shl n
template If*(ex:untyped):untyped = (if not(ex) : continue)
proc enumerate[T](arr:seq[T]): seq[tuple[i:int,val:T]] =
  result = @[]; for i,a in arr: result &= (i,a)

let
  N = get().parseInt()
  A = get().split().map(parseInt).sorted(cmp,Descending)
  M = get().parseInt()
  B = get().split().map(parseInt).sorted(cmp,Descending)

var state = newSeqWith(2^N,0)
for n in 0 ..< 2^N:
  for ia in 0 ..< N:
    If: (n and 2^ia) == 2^ia
    state[n] += A[ia] # 各状態の体積の和

# bitDP (set)
proc getOKState(b:int): HashSet[int] =
  state.enumerate().filterIt(b-it.val >= 0).mapIt(it.i).toSet()
var ans = B[0].getOKState()
if 2^N-1 in ans:
  echo 1
  quit()
for i,b in B[1..^1]:
  var n_ans = ans
  for x in b.getOKState().items:
    for y in ans.items:
      if not (x and y) == 0 : continue
      n_ans.incl(x xor y)
  ans = n_ans
  if 2^N-1 in ans:
    echo i + 2
    quit()
echo -1

#[
# bitDP (seq)
var ans = state.mapIt(B[0] - it >= 0)
if ans[2^N - 1] :
  echo 1
  quit()
for i,b in B[1..^1]:
  var n_ans = state.mapIt(false)
  for x,a in ans:
    If: a
    for y,s in state: #ここ
      If: (x and y) == 0
      If: b - s >= 0
      n_ans[x xor y] = true
  ans = n_ans
  if ans[2^N - 1] :
    echo i+2
    quit()
echo -1
]#

#[
# 大きい順に貪欲に入れるのを時間内検索
var ans = newSeq[int]()
let start = cpuTime()
proc check(i:int,bs:seq[tuple[vol:int,use:bool]]):void =
  if i == A.len():
    ans &= bs.mapIt(it.use.int).sum()
    if cpuTime() - start > 0.002:
      echo ans.min()
      quit()
    return
  for j,b in bs:
    if b.vol < A[i] :
      if not b.use : break
      else: continue #!
    var nbs = bs
    nbs[j].vol -= A[i]
    nbs[j].use = true
    check(i+1,nbs)
  return
check(0,B.mapIt((it,false)))
if ans.len() > 0: echo ans.min()
else: echo -1
]#