import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let C = newSeqWith(1 + 'Z'.ord - 'A'.ord,scan())
proc get(c:char):int = C[c.ord - 'A'.ord]

let S : seq[tuple[cnt,req:int]] = @[
  (get('H'),1),
  (get('E'),1),
  (get('L'),3),
  (get('O'),2),
  (get('W'),1),
  (get('R'),1),
  (get('D'),1),
]
for s in S:
  if s.cnt >= s.req : continue
  quit "0",0
var ans = 1
for s in S:
  if s.req == 1: ans *= s.cnt
  elif s.req == 2:
    ans *= (s.cnt div 2) * (s.cnt div 2 + s.cnt mod 2)
  elif s.req == 3:
    var tmp = 1
    for x in 2..<s.cnt:
      tmp = tmp.max(x * (x-1) * (s.cnt-x) div 2)
    ans *= tmp
    continue
echo ans