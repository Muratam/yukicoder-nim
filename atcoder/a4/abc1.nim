import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let N = get().split().map(parseInt).sorted(cmp)
if N[0] == 1 and N[1] == 4 and N[2] == 7 and N[3] == 9:
  echo "YES"
else:
  echo "NO"

