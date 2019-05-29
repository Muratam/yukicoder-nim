import strutils
const zs = (proc():seq[int] =
  result = @[0]
  var zs = 0
  for i in 1..15:
    let r =
      if i == 15: 4
      elif i mod 3 == 0: 2
      elif i mod 5 == 0: 2
      else: 0
    result &= result[^1] + r
  )()
let n = stdin.readLine().parseInt()
echo zs[^1] * (n div 15) + zs[n mod 15]