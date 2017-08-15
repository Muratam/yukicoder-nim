import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()

let
  N = get().parseInt()
  A = get().split().map(parseInt)
  height = A.sum().float.sqrt.int
  bottom = height * 2 - 1
  target = toSeq(0..<bottom).mapIt(height - abs(it-(bottom div 2)))
  dispose = A.sum() - target.sum()

if target.len <= A.len : # 222222 => 123210 012321
  var ans = newSeq[int]()
  for offset in 0..A.len - target.len:
    var target2 = newSeqWith(A.len-target.len, 0)
    target2.insert(target,offset)
    ans &= A.zip(target2).mapIt(abs(it.a-it.b)).sum() div 2
  echo ans.min() + (dispose + 1) div 2
else: # 410 => 121
  let
    A2 = A & newSeqWith(target.len - A.len,0)
    diff = A2.zip(target).mapIt(abs(it.a-it.b))
    ans = diff.sum() div 2 + (dispose + 1) div 2
  echo ans