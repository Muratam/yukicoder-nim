import sequtils,algorithm,sets,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
var used = initSet[string]()
block:
  var cache = "inabameguru"
  n.times:
    for i in 0..<cache.len: cache[i] = getchar_unlocked()
    used.incl cache
    discard getchar_unlocked()
var S = "inabameguru".sorted(cmp).join("")
proc impl() =
  const consonant = ['n','b','m','g','r']
  if S[^1] in consonant : return
  for i in 1..<S.len:
    if S[i] in consonant and S[i-1] in consonant: return
  if S notin used: quit S, 0

while true:
  impl()
  if not S.nextPermutation(): break
echo "NO"
