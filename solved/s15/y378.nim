import strutils
let n = stdin.readLine.parseInt()
var pred = 0
block:
  var now = n
  while now > 0:
    pred += now
    now = now div 2
var iikanji = 0
block:
  var now = n
  while now > 0:
    if now mod 2 == 1:
      iikanji += now * 2
      break
    iikanji += now
    now = now div 2
echo iikanji - pred