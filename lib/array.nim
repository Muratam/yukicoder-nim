# 配列変換
proc toArray(s:string) :seq[char]= toSeq(s.items)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)
proc flatten[T](x:seq[seq[T]]): seq[T] = (result = @[];for ix in x: result &= ix)

macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])

proc find*[T](arr: seq[T],item: T,start,fin:int): int {.inline.}=
  for i in start..<fin:
    if arr[i] == item : return i
  return -1

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

proc cmp(x,y:seq[int]):int = # 数の配列のソート用
  for i in 0..<min(x.len,y.len):
    if x[i] != y[i] : return x[i] - y[i]
  return x.len - y.len


# イテレーション
template permutationIter[T](arr:var seq[T],body) =
  # arr.sort()
  while true:
    body
    if not arr.nextPermutation() : break

template pairPermutationIter[T](arr:var seq[T],body) =
  # arr.sort()
  while true:
    body
    arr.reverse(arr.len div 2,arr.len - 1)
    if not arr.nextPermutation() : break


iterator chair(w,h:int): tuple[x,y:int] = # [0,w), [0,h) までを 和が等しい順に回す
  for n in 0..w + h:
    for x in 0.max(n-h+1)..n.min(w-1):
      yield (x,n-x)


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

