import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let S = get()
var x = 0
var y = 0
for s in S:
  case s
  of 'E': x += 1
  of 'W': x -= 1
  of 'N': y += 1
  of 'S': y -= 1
  else:discard
echo (x * x + y * y).float.sqrt()