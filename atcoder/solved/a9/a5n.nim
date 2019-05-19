import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let A = newSeqWith(n,scan())
var cans = initTable[int,Table[int,int]]()
var xsum = 0
for i,a in A:
  if i == n - 1 : break
  xsum = xsum xor a
  var ncans = initTable[int,Table[int,int]]()
  proc assign(key,index,val:int) =
    if key notin ncans: ncans[key] = initTable[int,int]()
    if index in ncans[key] : ncans[key][index] += val
    else : ncans[key][index] = val
  assign(xsum,0,1)
  for key in cans.keys():
    for now in cans[key].keys():
      let cnt = cans[key][now]
      assign(key, now xor a,cnt)
      if (now xor a) == key:
        assign(key, 0,cnt)
  cans = ncans
  #echo cans

let last = A[^1]
var ans = 1
for key in cans.keys():
  for now in cans[key].keys():
    let cnt = cans[key][now]
    if (now xor last) == key:
      ans += cnt
      # echo "A:",key,":",now,":",cnt
    # if last == key and now == 0:
    #   ans += cnt
    #   echo "B:",key,":",now,":",cnt
    # if key != now : continue
echo(ans mod 1000000007)
