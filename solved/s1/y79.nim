import sequtils,strutils,strscans,algorithm,math,future,macros
import sets,tables,hashes
template get*():string = stdin.readLine() #.strip()

proc enumerate[T](arr:seq[T]): seq[tuple[i:int,val:T]] =
  result = @[]; for i,a in arr: result &= (i,a)

template fgets(f:File,buf:untyped,size:int):void =
  proc c_fgets(c: cstring, n: int, file: File): void {.importc: "fgets", header: "<stdio.h>", tags: [ReadIOEffect].}
  var buf: array[size, char]
  c_fgets(buf,sizeof(buf),f)

let N = get().parseInt
stdin.fgets(buf,100000 * 2 + 2)
var ans = newSeqWith(7,0)
for b in buf:
  if b < '0' or b > '9' : continue
  ans[b.ord - '0'.ord] += 1
echo ans.enumerate()
  .sorted((x,y) => (if x[1] != y[1] : x[1] - y[1] else: x[0] - y[0]),Descending)[0].i
