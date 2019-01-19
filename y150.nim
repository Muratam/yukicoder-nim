import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template times*(n:int,body) = (for _ in 0..<n: body)
let n = stdin.readLine().parseInt()
n.times:
  let S = stdin.readLine()
  for i 0..<S.len():
