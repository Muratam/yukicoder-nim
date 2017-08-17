import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine()

type
  ArrWrap*[T] = object
    nodes: seq[T]

proc getLast(arr:var ArrWrap[int]) :int =
  for i in 0..10:
    arr.nodes &= i
  return arr.nodes.len
emit ("1 * -p")
var a = ArrWrap[int](nodes: @[1,2])
echo 1
for i in 0..18000000:
  a.nodes &= i
  a.nodes &= a.getLast()
echo a.getLast()