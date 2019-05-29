proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}

var C = [20104, 20063, 19892, 20011, 19874, 20199, 19898, 20163, 19956, 19841]
block:
  let k = getchar_unlocked()
  C[k.ord - '0'.ord] -= 1
  discard getchar_unlocked()
while true:
  let k = getchar_unlocked()
  if k < '0':
    for i in 0..<10:
      if C[i] == -1 :
        printf("%d ",i)
        break
    putchar_unlocked(' ')
    for i in 0..<10:
      if C[i] == 1 :
        printf("%d\n",i)
        quit(0)
  C[k.ord - '0'.ord] -= 1