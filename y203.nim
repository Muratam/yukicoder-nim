import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
template `max=`*(x,y) = x = max(x,y)

let C = get() & get()
var res = 0
var pre = 0
for c in C:
  if c == 'o':
    pre += 1
    res .max= pre
  else:
    pre = 0
echo res