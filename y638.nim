import strutils,bitops

let n = stdin.readLine.parseInt()
if n in [1,2,3,4,5,7]: quit "-1", 0
for x in 3..<n:
  if x.popcount() == 1 : continue
  let y = n - x
  if y.popcount() == 1 : continue
  echo x," ",y
  break