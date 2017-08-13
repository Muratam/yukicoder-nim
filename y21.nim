import sequtils,strutils,algorithm,math,future
template get():string = stdin.readLine()

let
  N = get().parseInt
  K = get().parseInt
  nums = newSeqWith(N,get().parseInt)
echo nums.max - nums.min
