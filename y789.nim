import sequtils,algorithm,times,bitops
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

template useBinaryIndexedTree() = # 部分和検索 / 更新 O(log(N))
  type BinaryIndexedTree[T] = ref object
    data: seq[T] # 引数以下の部分和(Fenwick Tree)
  proc initBinaryIndexedTree[T](n:int):BinaryIndexedTree[T] =
    new(result)
    result.data = newSeq[T](n)
  proc len[T](self:BinaryIndexedTree[T]): int = self.data.len()
  proc update[T](self:var BinaryIndexedTree[T],i:int,val:T) =
    var i = i
    while i < self.len():
      self.data[i] += val
      i = i or (i + 1)
  proc `[]`[T](self:BinaryIndexedTree[T],i:int): T =
    var i = i
    while i >= 0:
      result += self.data[i]
      i = (i and (i + 1)) - 1
  proc `$`[T](self:BinaryIndexedTree[T]): string =
    result = "["
    for i in 0..<self.len.min(100): result &= $(self[i]) & ", "
    return result[0..result.len()-2] & (if self.len > 100 : " ...]" else: "]")


proc quickSort[T](a: var openarray[T], inl = 0, inr = -1) =
  var r = if inr >= 0: inr else: a.high
  var l = inl
  let n= r - l + 1
  if n < 2: return
  let p = a[l + 3 * n div 4]
  while l <= r:
    if a[l] < p:
      inc l
      continue
    if a[r] > p:
      dec r
      continue
    if l <= r:
      swap a[l], a[r]
      inc l
      dec r
  quickSort(a, inl, r)
  quickSort(a, l, inr)


proc deduplicated[T](arr: openarray[T]): seq[T] = # require sorted
  result = @[]
  for a in arr:
    if result.len > 0 and result[^1] == a : continue
    result &= a
useBinaryIndexedTree()
stopwatch:
  let n = scan()
  var X,Y,Q : array[100010,int]
  var V : array[200010,int]
  for i in 0..<n:
    Q[i] = scan()
    X[i] = scan()
    Y[i] = scan()
    V[i*2] = X[i]
    if Q[i] == 1 : V[i*2+1] = Y[i]
stopwatch:
  V.quicksort()
stopwatch:
  var V2 = V.deduplicated()
stopwatch:
  var bit = initBinaryIndexedTree[int](V.len + 1)
  var ans = 0
  for i in 0..<n:
    let x = V2.lowerBound(X[i])
    if Q[i] == 0: bit.update(x,Y[i])
    else:
      let y = V2.lowerBound(Y[i])
      if x == 0: ans += bit[y]
      else: ans += bit[y] - bit[x-1]
  echo ans