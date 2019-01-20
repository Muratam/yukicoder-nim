import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let nm = get().split().map(parseInt) # 1000
let (n,m) = (nm[0],nm[1])
let A = get().split().map(parseInt).sorted(cmp) # n
let B = get().split().map(parseInt).sorted(cmp) # m
var C = newSeqWith(n,newSeqWith(m,0))
for y,b in B:
  for x in 0..<n:
    C[x][y] = b

for x,a in A:
  if a notin C[x]:
    for y in 0..<m:
      C[x][y] .min= a
  else:
    for y in 0..<m:
      if C[x][y] == a:
        C[x][y] = -a
        for x2 in 0..<n:
          C[x2][y] .min= a-1
      else:
        C[x][y] .min= a-1


# 1.
# 2.


echo A
echo B
for x in 0..<n:
  for y in 0..<m:
    stdout.write C[x][y],"\t"
  echo ""
# どちらもあるものは必ずそこで固定

#[
1
    D E F G
A:  1 2 3 A
B:  4 5 6 B
D:  D 8 9 7
G:  C E F *

    - x x -
    - x x -
    D - - -
    - - - G

16! / 16
G は絶対に固定

]#