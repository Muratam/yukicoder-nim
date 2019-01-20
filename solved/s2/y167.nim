proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

proc scanN(): int =
  var pre : char
  while true:
    var k = getchar_unlocked()
    if k < '0' : break
    pre = k
  return pre.ord - '0'.ord

let n = scanN()

if n in [0,1,5,6]:
  if getchar_unlocked() == '0': echo 1
  else: echo n
  quit 0

var c = getchar_unlocked()
if c == '0': quit "1", 0
if n in [4,9]:
  while true:
    let k = getchar_unlocked()
    if k < '0' :
      let last = (c.ord - '0'.ord) mod 2
      if n == 4: echo [6,4][last]
      elif n == 9: echo [1,9][last]
      quit 0
    c = k
else:
  var d = '0'
  while true:
    let k = getchar_unlocked()
    if k < '0' :
      let last = ((d.ord - '0'.ord) * 10 + (c.ord - '0'.ord)) mod 4
      if n == 2: echo [6,2,4,8][last]
      elif n == 3: echo [1,3,9,7][last]
      elif n == 7: echo [1,7,9,3][last]
      elif n == 8: echo [6,8,4,2][last]
      quit 0
    d = c
    c = k
