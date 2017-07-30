import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
#proc popcount(n:int):cint{.importC: "__builtin_popcount", noDecl .} # sum of "1"

#close = initTable[int,int]() # hash is slow
#if not (succ in close): # hash is slow
#let diff = n.toBin(64).count('1') # string is slow

let N = get().parseInt
var
  open = initQueue[int]() # n
  close = newSeqWith(N+1,-1)# depth
  resdepth = 0
open.add(1)  # 1 *-> N
close[1] = 1
while open.len > 0:
  let
    n = open.pop()
    depth = close[n]
  if n == N:
    echo depth
    quit()
  let diff = countBits32(n.int32)
  for succ in @[n + diff,n - diff]:
    if succ > N or succ < 1:
      continue
    if close[succ] == -1:
      close[succ] = depth + 1
      open.enqueue(succ)
echo -1
