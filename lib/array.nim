# 配列操作
proc argMax[T](arr:seq[T]):int =
  result = 0
  var val = arr[0]
  for i,a in arr:
    if a <= val: continue
    val = a
    result = i
proc argMin[T](arr:seq[T]):int =
  result = 0
  var val = arr[0]
  for i,a in arr:
    if a >= val: continue
    val = a
    result = i

proc find*[T](arr: seq[T],item: T,start,fin:int): int {.inline.}=
  for i in start..<fin:
    if arr[i] == item : return i
  return -1


iterator chair(w,h:int): tuple[x,y:int] = # [0,w), [0,h) までを 和が等しい順に回す
  for n in 0..w + h:
    for x in 0.max(n-h+1)..n.min(w-1):
      yield (x,n-x)

proc toArray(s:string) :seq[char]= toSeq(s.items)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)

proc overWrite[T](dst,src:seq[T],index:int) : seq[T] =
  result = dst
  for i,s in src:
    if index+i >= dst.len : result &= s
    else: result[index+i] = s
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
proc getNeignborDiff[T](arr:seq[T]) : seq[T] =
  if arr.len == 0 : return @[]
  result = newSeq[T](arr.len()-1)
  for i in 1..<arr.len(): result[i-1] = arr[i] - arr[i-1]

proc toAlphabet(a:int) : string = # 26進数(A..Z,AA..ZZ,...)
  proc impl(a:int) : seq[char] =
    let c = a mod 26
    let s = ('A'.ord + c).chr
    if a < 26: return @[s]
    result = impl(a div 26 - 1)
    result &= s
  return cast[string](impl(a))
