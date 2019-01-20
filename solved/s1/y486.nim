import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let S = get()
var o = 0
var x = 0
for s in S:
  if s == 'O':
    o += 1
    x = 0
  else:
    x += 1
    o = 0
  if o >= 3:
    echo "East"
    quit(0)
  if x >= 3:
    echo "West"
    quit(0)
echo "NA"