import sequtils,strutils,algorithm,tables
let n =  stdin.readLine().parseInt()
let a = toSeq(newSeqWith(n,stdin.readLine()).sorted(cmp).toCountTable().values).sorted(cmp)[^1]
if n >= a * 2 - 1: echo "YES"
else: echo "NO"
