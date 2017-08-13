import sequtils,strutils,strscans,algorithm,math,future,sets
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template FOR(i:untyped,a,b:int,body:untyped):untyped =
  if a < b: (var i = a; while i < b:( body; i += 1))
  else : (var i = a; while i >= b:( body; i -= 1))
template REP(i:untyped,n:int,body:untyped):untyped =
  block:(var i = 0; while i < n:( body; i += 1))
###################################################################

let
  N = get().parseInt()
var
  nums = toSeq(0..9).toSet()
N.times:
  let
    line = get().split()
    num = line[0..^2].map(parseInt).toSet()
    r = line[^1]
  if r == "NO":
    nums = nums - num
  else:
    nums = nums * num
echo toSeq(nums.items)[0]