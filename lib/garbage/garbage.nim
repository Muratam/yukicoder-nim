# 加算なら
proc findMinKey*[T](self:SegmentTree[T],cond:proc(x:T):bool) : int =
  if not cond(self.data[0]): return -1

# 単純な二部探索を外側に噛ますと O((logN)^2) になるので、セグツリで検索する
# この木の中に解がある.isRightならなるべく右を,isLeftならなるべく左を探す.
proc findSubTree*[T](self:SegmentTree[T],cond:proc(x:T):bool,i:int,v:T,isRight:bool) : int =
  var i = i
  var v = v
  while i < self.n - 1: # 葉に着くまで
    let nextI = (2*i) + (if isRight:2 else:1)
    let next =
      if isRight: self.apply(self.data[nextI],v)
      else: self.apply(v,self.data[nextI])
    if cond(next): i = nextI
    else:
      v = next
      i = (2*i) + (if isRight:1 else:2)
  return i - self.size + 1
# [offset..x] の中で条件を満たす最小のキー
proc findMinKey*[T](self:SegmentTree[T],cond:proc(x:T):bool,offset:int=0) : int =
  var offset = 0.max(offset)
  # 全ての範囲は割とよく探すので特別扱い
  if offset == 0:
    if cond(self.data[0]):
      return self.findSubTree(cond,0,self.unit,false)
    return -1
  offset += self.n-1
  while offset > 0: # 葉から登っていく
    if cond(self.data[offset]):
      return self.findSubTree(cond,offset,self.unit,false)
    offset = (offset-1) shr 1
