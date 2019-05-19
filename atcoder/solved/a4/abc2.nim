import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)


let S = stdin.readLine()
let k = "keyence"
if S.startsWith(k) or S.endsWith(k):
  echo "YES"
  quit 0
for i in 1..<k.len():
  if S.startsWith(k[0..(i-1)]) and S.endsWith(k[i..^1]):
    echo "YES"
    quit 0
echo "NO"
