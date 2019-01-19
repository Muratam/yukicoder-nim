import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template `max=`*(x,y) = x = max(x,y)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)
proc overWrite[T](dst,src:seq[T],index:int) : seq[T] =
  result = dst
  for i,s in src:
    if index+i >= dst.len : result &= s
    else: result[index+i] = s
proc toArray(s:string) :seq[char] = toSeq(s.items)
proc countContinuity[T](arr:seq[T]) : seq[tuple[key:T,cnt:int]] =
  if arr.len == 0 : return @[]
  result = @[]
  var pre = arr[0]
  var cnt = 0
  for a in arr:
    if a == pre: cnt += 1
    else:
      result &= (pre,cnt)
      cnt = 1
      pre = a
  result &= (pre,cnt)
template countMax(x) : int = x.countContinuity().filterIt(it.key == 'o').mapIt(it.cnt).max()
let n = stdin.readLine().parseInt()
let S = stdin.readLine() & stdin.readLine()
var ans = 0
let T = S.toArray()
let O = "o".repeat(n).toArray()
for i in 0..14-n:
  echo T.overWrite(O,i)
  ans .max= T.overWrite(O,i).countMax()
ans .max= (T & O).countMax()
ans .max= (O & T).countMax()
echo ans