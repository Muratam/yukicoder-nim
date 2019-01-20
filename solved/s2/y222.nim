proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): (int,char) =
  var minus = false
  var n = 0
  var c = '0'
  var already = false
  while true:
    c = getchar_unlocked()
    if not already and c == '-' : minus = true
    elif not already and c == '+' : discard
    elif c < '0' or c > '9': break
    else: n = 10 * n + c.ord - '0'.ord
    already = true
  if minus: n *= -1
  return (n,c)
let (x,c) = scan()
let (y,d) = scan()
if c == '+' : echo x - y
else: echo x + y
