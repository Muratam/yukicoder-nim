template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc gets(str: untyped){.header: "<stdio.h>", varargs.}
proc puts(str: untyped){.header: "<stdio.h>", varargs.}

proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
var S : array[1_00010,char]

proc reduce(x,y,size:int) =
  if x == -1:
    puts(S)
    return
  let sx = S[x]
  let sy = S[y]
  S[x] = '\0'
  S[y] = '\0'
  puts(S)
  S[y] = sy
  S[x] = sx
  # for i in 0..<x:
  #   putchar_unlocked(S[i])
  block:
    var carry = 1
    for i in y.countdown(x):
      let c = S[i].ord - '0'.ord
      let d = c + carry
      if d < 10 :
        S[i] = "0123456789"[d]
        carry = 0
      else:
        S[i] = '0'
        carry = 1
    if carry == 1: putchar_unlocked('1')
  puts(S + cast[ptr int](x))
  for i in x..<size:
    putchar_unlocked(S[i])
proc impl() =
  gets(S)
  var i = 0
  var x = -1
  var y = -1
  var preIsAlpha = true
  for i,k in S:
    if k == '\0':
      reduce(x,y,i)
      putchar_unlocked('\n')
      return
    let isAlpha = k < '0' or '9' < k
    if not isAlpha:
      y = i
      if preIsAlpha : x = i
    preIsAlpha = isAlpha

scan().times: impl()