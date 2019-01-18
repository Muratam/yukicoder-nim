import sequtils,algorithm
proc get():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = get()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

template OK() = quit "SUCCESS", 0
template NG() = quit "FAILURE", 0

let S1 = [get(),get(),get()]
discard get()
let n = scan()
let S2 = [get(),get(),get()]
if S1.sorted(cmp) != S2.sorted(cmp) : OK()
if n == 0 :
  if S1 != S2 : OK()
  else: NG()
if S1 in [['o','o','o'], ['x','x','x']] : NG()
if n != 1 : NG()
if S1.reversed() == S2 : OK()
NG()