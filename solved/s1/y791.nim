proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
if getchar_unlocked() != '1' : quit "-1",0
var ans = 0
while true:
  let k = getchar_unlocked()
  if k < '0' or k > '9':
    if ans == 0 : quit "-1", 0
    quit $ans, 0
  if k != '3' : quit "-1",0
  ans += 1
