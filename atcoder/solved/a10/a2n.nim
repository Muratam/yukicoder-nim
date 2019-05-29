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

var A = newSeqWith(4,getchar_unlocked().ord - '0'.ord)
let B = A[0] * 10 + A[1]
let C = A[2] * 10 + A[3]
if 1 <= B and B <= 12 and 1 <= C and C <= 12 :
  echo "AMBIGUOUS"
  quit 0
if (B > 12 or B == 0) and 1 <= C and C <= 12 :
  echo "YYMM"
  quit 0
if (C > 12 or C == 0) and 1 <= B and B <= 12 :
  echo "MMYY"
  quit 0
echo "NA"
# YY(00~99)MM(01~12)
# MMYY


# echo toSeq(0..10)
# echo toSeq("123".items)
# let (n,m) = stdin.readLine().split().map(parseInt).unpack(2)
# let A = stdin.readLine().split().map(parseInt)
# let n = stdin.readLine().parseInt()
# let B = newSeqWith(n,stdin.readLine().parseInt())
