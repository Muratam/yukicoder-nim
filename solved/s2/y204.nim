import sequtils,strutils,algorithm
template `max=`*(x,y) = x = max(x,y)
proc toArray(s:string) :seq[char] = toSeq(s.items)
proc countMax[T](arr:seq[T],item:T) : int =
  if arr.len == 0 : return 0
  var pre = arr[0]
  var cnt = 1
  for i in 1..<arr.len:
    let a = arr[i]
    if a == pre: cnt += 1
    else:
      if pre == item : result .max= cnt
      cnt = 1
      pre = a
  if arr[^1] == item : result .max= cnt
let n = stdin.readLine().parseInt()
let S = stdin.readLine() & stdin.readLine()
let X = "x".repeat(n)
let O = "o".repeat(n).toArray()
let T = (X & S & X).toArray()
proc overWrite(n:int,dst:seq[char],startIndex:int) : seq[char] =
  result = dst
  for i in 0..<n:
    if startIndex + i >= dst.len : return @[]
    if result[startIndex + i ] == 'o' : return @[]
    result[startIndex + i] = 'o'
var ans = 0
for i in 0..T.len:
  for ni in 1..n:
    ans .max= overWrite(ni,T,i).countMax('o')
ans .max= T.countMax('o')
echo ans