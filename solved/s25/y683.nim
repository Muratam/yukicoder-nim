proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc solve(ain,bin:int):bool =
  let a = min(ain,bin)
  let b = max(ain,bin)
  if a == 0 : return true
  if a mod 2 == 1 :
    if b mod 2 == 1 : return false
    return solve(a-1,b div 2)
  if b mod 2 == 1 : return solve(a div 2,b - 1)
  if solve(a div 2 , b - 1) : return true
  return solve(a - 1 , b div 2)

let a = scan()
let b = scan()
if solve(a,b) : echo "Yes"
else: echo "No"