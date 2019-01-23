template `max=`*(x,y) = x = max(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
proc f(x:int):int = x + (x+1) * (n-x)
# for i in 1..<n: ans .max= f(i)
echo @[f(n div 2),f(n div 2 + 1),f(n div 2 - 1)].max()