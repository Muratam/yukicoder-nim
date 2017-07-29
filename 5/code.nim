import sequtils,strutils,algorithm,math,future
proc get():string = stdin.readLine()
proc int(s:string) :int = s.parseInt()

let
  L = get().int
  N = get().int
  ws = get().split(' ').map(int).sorted(cmp)
var
  cnt = 0
  width = 0

for w in ws:
  width += w
  if width <= L:
    cnt += 1
  else:
    break
echo cnt
