import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  var minus = false
  while true:
    let k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1

let n = scan()
let m = scan()
var A = newSeqWith(m+1,newSeqWith(m+1,0))
for y in 1..m:
  for x in 1..m:
    A[x][y] = scan() + A[x-1][y] + A[x][y-1] - A[x-1][y-1]

proc calcSum(ax,ay,bx,by:int):int = A[bx][by] - A[bx][ay] - A[ax][by] + A[ax][ay]


n.times:
  let y = scan()
  let x = scan()
  var ans = 0
  for ax in 0..<x:
    for ay in 0..<y:
      let axay = A[ax][ay]
      for bx in x..m:
        let bxay = A[bx][ay]
        for by in y..m:
          if A[bx][by] - A[ax][by] - bxay + axay == 0:
            ans += 1
  echo ans