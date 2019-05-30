import sequtils,macros

# seq[T] <=> string countTable tuple seq[seq[T]]
template useTranslating() =
  proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)
  # seq[seq[T]] -> seq[T]
  proc flatten[T](x:seq[seq[T]]): seq[T] = (result = @[];for ix in x: result &= ix)
  # seq[T] -> (T,T,T...)
  macro unpack*(arr: auto,cnt: static[int]): auto =
    let t = genSym(); result = quote do:(let `t` = `arr`;())
    for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])

# find / argMin / argMax
template useFindIndex() =
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

  proc quickSort[T](a: var openarray[T], inl = 0, inr = -1) =
    var r = if inr >= 0: inr else: a.high
    var l = inl
    let n = r - l + 1
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


# chair / permutation / ペア順列
template useIteration() =
  template permutationIter[T](arr:var seq[T],body) =
    # arr.sort()
    while true:
      body
      if not arr.nextPermutation() : break
  # ペア順列(半分無視)
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

# cmp[seq[int]] / count...
template useOtherArrays() =
  proc `*`(str:string,t:int):string = str.repeat(t)
  proc overWrite[T](dst,src:seq[T],index:int) : seq[T] =
    result = dst
    for i,s in src:
      if index+i >= dst.len : result &= s
      else: result[index+i] = s
