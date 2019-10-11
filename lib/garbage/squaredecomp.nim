# 平方分割
# √N毎のパケットに分けてそこに集約値を保存する
# O(√N) だがメモリがキャッシュに乗りやすいのと、~1e6程度の問題しかでないのとで悪くても1000倍.普通に10倍くらいの差で済む
# 変なクエリに対して臨機応変に対応しやすい.
# https://kujira16.hateblo.jp/entry/2016/12/15/000000

# verify 用のコードが無いとやる気が起きないね！
import math
type SquareDecomposition*[T] = ref object
  n,bucketLen,bucketNum*:int # bucketLen:バケットの長さ, bucketNum: バケットの個数
  data*,bucket*:seq[T]
  apply*:proc(x,y:T):T # モノイド
  unit*:T # 単位元
  # inv*:proc(x:T):T # applyの逆元があると,1点更新がO(1)になる

proc sqrt(x:int):int {.inline.} = x.float.sqrt.int
proc newSquareDecomposition*[T](n:int,apply:proc(x,y:T):T,unit:T) :SquareDecomposition[T]=
  new(result)
  result.n = n
  result.bucketLen = n.sqrt
  result.bucketNum = (n + 1) div result.bucketLen
  result.unit = unit
  result.apply = apply
  result.data = newSeq[T](n)
  result.bucket = newSeq[T](result.bucketNum)
  # 単位元が 0 ではない場合初期化しておく
  for i in 0..<n: result.data[i] = unit
  for i in 0..<result.bucketNum: result.bucket[i] = unit
proc newSquareDecomposition*[T](data:seq[T],apply:proc(x,y:T):T,unit:T) :SquareDecomposition[T] =
  new(result)
  result.n = data.len
  result.bucketLen = data.len.sqrt
  result.bucketNum = (result.n + 1) div result.bucketLen
  result.unit = unit
  result.apply = apply
  result.data = data
  result.bucket = newSeq[T](result.bucketNum)
  var j = 0
  for ki in 0..<result.bucketNum:
    var sum = unit
    for i in 0..<result.bucketLen:
      sum = apply(sum,result.data[j])
      j += 1
    result.bucket[ki] = sum
# proc `[]`*[T](self:SquareDecomposition[T],slice:Slice[int]): T =
# proc `[]=`*[T](self:SquareDecomposition[T],slice:Slice[int]): T =
