import sequtils
proc toArray(s:string) :seq[char]= toSeq(s.items) # string -> seq[char]
proc enumerate[T](arr:seq[T]): seq[tuple[i:int,val:T]] =
  result = @[]; for i,a in arr: result &= (i,a)
proc cmp(x,y:seq[int]):int = # 数の配列のソート用
  for i in 0..<min(x.len,y.len):
    if x[i] != y[i] : return x[i] - y[i]
  return x.len - y.len
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] =
  toSeq(x.toCountTable().pairs)
proc deduplicated[T](arr: seq[T]): seq[T] = # Nim標準 の deduplicate はO(n^2)なので注意
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result &= a
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
