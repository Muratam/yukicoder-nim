template `max=`*(x,y) = x = max(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let n2 = n div 2
proc f(x:int):int = (x + ((x+1) mod 1000007) * ((n-x) mod 1000007)) mod 1000007
let a = n2 * 2 - 1
let b = n
let c = 2 * n - 2 * n2 - 1
if a < b and b > c : echo f(n div 2)
elif b < a and a > c : echo f(n div 2 - 1)
else: echo f(n div 2 + 1)
