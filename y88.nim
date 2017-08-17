import sequtils,strutils,math
template get*():string = stdin.readLine().strip()
proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)
let
  starter = get() == "yukiko"
  frames = newSeqWith(8,get().toSeq().filterIt(it!='.').len())
  players = ["oda","yukiko"]
echo players[starter.int xor (frames.sum() mod 2)]