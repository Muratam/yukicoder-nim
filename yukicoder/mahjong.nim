{.checks:off.}
import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
var sum = 0
for a in 0..<36:
  for b in 0..<a:
    for c in 0..<b:
      let x4 = 83 - a - b - c
      if x4 < 0: break
      let x3 = c - x4
      let x2 = b - c
      let x1 = a - b
      assert x1 + x2 + x3 + x4 == 83
