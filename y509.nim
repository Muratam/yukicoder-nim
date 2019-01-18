const counts = [3,2,2,2,3, 2,3,2,4,3]
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    result += counts[k.ord - '0'.ord]
  result += 1
echo scan()
