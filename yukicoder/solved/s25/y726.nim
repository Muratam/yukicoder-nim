proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let y = scan() #
let x = scan() # x より大きい素数を見つけるゲーム
proc isFirstWin(): bool =
  if x == 2 or y == 2: return false
  if x == 1 and y == 1: return false
  if x == 1 : return y mod 2 != 0
  if y == 1 : return x mod 2 != 0
  return (x + y) mod 2 != 0
if isFirstWin(): echo "First"
else: echo "Second"