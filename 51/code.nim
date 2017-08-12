import sequtils,strutils,strscans,algorithm,math,future,macros
#import sets,queues,tables,nre,pegs
template get*():string = stdin.readLine() #.strip()

let
  W = get().parseInt()
  D = get().parseInt()
var left = W
for d in countdown(D,0):
  if d == 1:
    echo left
    quit()
  left -= left div (d * d)
