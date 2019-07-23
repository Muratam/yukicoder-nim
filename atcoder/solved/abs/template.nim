proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan(): int = scanf("%lld\n",addr result)
let n = scan()
var (ct,cx,cy) = (0,0,0)
for _ in 0..<n:
  let (t,x,y) = (scan(),scan(),scan())
  let (dt,dx,dy) = (t-ct,x-cx,y-cy)
  if dx.abs + dy.abs > dt or abs(dx + dy) mod 2 != dt mod 2: quit "No",0
  (ct,cx,cy) = (t,x,y)
echo "Yes"
# let TXY = newSeqWith(n,(t:scan(),x:scan(),y:scan())) # .sortedByIt(it.t) # 制約により不要
# # for i,(t,x,y) in TXY : # Nim 0.20.0 ではこう書ける
# for txy in TXY:
#   let (t,x,y) = txy




# let n = scan()
# let y = scan()
# for ia in 0..n:
#   for ib in 0..(n-ia):
#     let ic = n - ia - ib
#     if ic >= 0 and ia * 10000 + ib * 5000 + ic * 1000 == y :
#       echo ia," ",ib," ",ic
#       quit 0
# echo "-1 -1 -1"
# var ans = 0
# for i in 0..<(n-1):
#   if D[i] != D[i+1] : ans += 1
# echo ans
# proc getchar():char {. importc:"getchar",header: "<stdio.h>",discardable .}
# echo newSeqWith(3,getchar()).filterIt(it=='1').len
# echo stdin.readLine.toSeq().count('1')
# let S = toSeq(stdin.readLine().items)
# echo S
# strutils
# algorithm,math
# import sets,tables,intsets,queues,macros
# template times*(n:int,body) = (for _ in 0..<n: body)
# template `max=`*(x,y) = x = max(x,y)
# template `min=`*(x,y) = x = min(x,y)
# let a = scan()
# let b = scan()
# echo toSeq(stdin.readLine()).count('1')
# echo S
