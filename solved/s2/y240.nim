import sequtils,algorithm,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  var minus = false
  while true:
    var k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1

type Pos = tuple[x,y:int]
proc `+`(p,v:Pos):Pos = (p.x+v.x,p.y+v.y)
proc `==`(p,v:Pos):bool = p.x == v.x and p.y == v.y

const oks = (proc():seq[Pos] =
  var oks = newSeq[Pos]()
  const diffs : seq[Pos] = @[(1,2),(2,1),(-1,-2),(-2,-1),(-1,2),(-2,1),(1,-2),(2,-1)]
  oks &= (0,0)
  for i in 0..<3:
    for ok in toSeq(oks.items):
      for p in diffs: oks &= p + ok
  return oks.mapIt((it.x.abs,it.y.abs)).deduplicate()
)()

let x = scan()
let y = scan()
let pos :Pos = (x.abs,y.abs)
for p in oks:
  if p == pos:
    echo "YES"
    quit 0
echo "NO"
