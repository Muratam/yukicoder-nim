# 平方分割. 区間の処理が O(√n).
# セグメントツリーが MLE の時になど？
import math
type SquareDivision[T] = ref object
  raw:seq[T]
  bucket:seq[T]
  sqSize:int

proc newSquareDivision[T](data:seq[int]) : SquareDivision[T] =
  new(result)
  result.raw = data
  result.sqsize = 0.max(data.len - 1).float.sqrt.int + 1
  result.bucket = newSeq[T](result.sqSize)
proc toBucket[T](self:SquareDivision[T],i:int):int = i div self.sqSize
proc toRawLeft[T](self:SquareDivision[T],i:int):int = i * self.sqSize
