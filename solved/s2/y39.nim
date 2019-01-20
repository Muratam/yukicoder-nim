import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()
template `max=`*(x,y:typed):void = x = max(x,y)
proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)
proc split(n:int):auto = ($n).toSeq().mapIt(it.ord- '0'.ord)
proc join(n:seq[int]):int = n.mapIt($it).join("").parseInt()

let S = get().parseInt().split()
var ans = S.join()
for i in 0..< S.len:
  for j in i+1 ..< S.len:
    var s = S
    (s[i],s[j]) = (s[j],s[i])
    ans .max= s.join()
echo ans