# 複数のsetを組み合わせる.
import "./priorityqueue"
import "../segmenttree/bit"
# 中央値を取れる Priority Queue
type MediumQueue*[T] = ref object
  greater*,less* : PriorityQueue[T]
# K番目の値のみを取れるPriority Queue
type KthQueue*[T] = ref object
  greater*,less* : PriorityQueue[T]
# 1e7 くらいまでならこっちでも行ける.
# 任意番目の値を取れる
type KthBIT* = BinaryIndexedTree[int]
