template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

scan().times:
  var isOk = true
  var gcount = 0
  while true:
    let k = getchar_unlocked()
    if k < 'A' or k > 'Z': break
    if k == 'G': gcount += 1
    if k == 'R':
      if gcount == 0 : isOk = false
      gcount -= 1
  if not isOk or gcount > 0: echo "impossible"
  else: echo "possible"
