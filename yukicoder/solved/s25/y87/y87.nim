import sequtils

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

# うるう年以外 : +1 | うるう年 : +2
let n = scan()
proc solve(n:int,start:int=2014,x:int = 0):int =
  var x = x
  for i in (start+1)..n:
    if i mod 4 == 0 :
      if i mod 100 == 0 :
        if i mod 400 == 0 : x += 2
        else: x += 1
      else: x += 2
    else: x += 1
    if x == 7 : result += 1
    x = x mod 7

let start = 2800
if n <= start: quit $(solve(n)),0
let ans = 111 + 57 * (n div 400 - 7)
echo ans + solve(n,(n div 400) * 400,4)
# var pre = 0
# for i in countup(2400,100_000,400):
#   var next = solve(i)
#   echo i,":",next,": +",next - pre
#   pre = next
