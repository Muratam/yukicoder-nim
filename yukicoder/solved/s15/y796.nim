import macros
template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
proc puts(str: cstring){.header: "<stdio.h>", varargs.}
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}

let n = scan()
# 1 3   + [1 1 1]
# 1 3 3 + [1 1 1]
# 1 1 2 3 + [1 1 1]
if n mod 3 == 2: printf("1 3")
elif n mod 3 == 0: printf("1 3 3")
else:printf("1 1 2 3")
(n-[3,4,2][n mod 3]).times:
  putchar_unlocked(' ')
  putchar_unlocked('1')
putchar_unlocked('\n')
