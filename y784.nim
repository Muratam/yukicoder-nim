proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
setStdIoUnbuffered()
let S = stdin.readLine()
if S.len <= 3: quit S,0
for i,s in S:
  if (S.len - i) mod 3 == 0 and i != 0: putchar_unlocked(',')
  putchar_unlocked(s)
putchar_unlocked('\n')