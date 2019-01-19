import sequtils,algorithm,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

type Pos = tuple[x,y:int]
proc `+`(p,v:Pos):Pos = result.x = p.x+v.x; result.y = p.y+v.y

const oks = (proc():seq[Pos] =
  var oks = newSeq[Pos]()
  const diffs : seq[Pos] = @[(1,2),(2,1),(-1,-2),(-2,-2),(-1,2),(-2,1),(1,-2),(2,-1)]
  oks &= (0,0)
  for i in 0..<3:
    for ok in toSeq(oks.items):
      for p in diffs: oks &= p + ok
  return oks.deduplicate()
)()
echo oks
let x = scan()
let y = scan()
let pos :Pos = (x,y)
for p in oks:
  if p == pos:
    echo "YES"
    quit 0
echo "NO"
# template times*(n:int,body) = (for _ in 0..<n: body)
# template `max=`*(x,y) = x = max(x,y)
# template `min=`*(x,y) = x = min(x,y)
# proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)
# var rgb = newSeqWith(3,scan())
# rgb = rgb.filterIt(it > 0)
# var ans = 0
# if rgb.len == 3:
#   var del = rgb.min()
#   rgb = rgb.mapIt(it - del)
#   ans += del
#   rgb = rgb.filterIt(it > 0)
# if rgb.len == 2:


# echo rgb
# echo ans