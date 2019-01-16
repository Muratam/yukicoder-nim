proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}


var n :int32
scanf("%d\n",addr n)
var p = 0
var pre : char
while true:
  var c = getchar_unlocked()
  if c.ord <= 32:
    if (cast[int16](pre) and 1) == 0: p += 1
    else: p -= 1
  if c.ord == 255: break
  pre = c
printf("%d\n",p.abs)