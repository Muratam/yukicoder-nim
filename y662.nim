import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
let i2v = newSeqWith(5,(let t = get().split();(t[0],t[1].parseInt())))
let realsTable = newSeqWith(3,(let t = get().parseInt();newSeqWith(t,get()))).mapIt(it.toCountTable())
let reals = toSeq(0..<3).mapIt:
  var real = newSeq[int]()
  for i,v in i2v:
    if v[0] notin realsTable[it] : real &= 0
    else: real &= realsTable[it][v[0]]
  real
let values = i2v.mapIt(it[1])
let oks = toSeq(0..<5).mapIt(reals[0][it] * reals[1][it] * reals[2][it]*5 )
let weights = toSeq(0..<5).mapIt(oks[it] * values[it])
echo weights.sum() / reals.mapIt(it.sum()).foldl(a*b,1)
echo oks.join("\n")