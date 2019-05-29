import sequtils,math,strutils
# template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
proc `^`(n:int) : int{.inline.} = (1 shl n)

proc getchar_unlocked():char {. discardable,importc:"getchar_unlocked",header: "<stdio.h>"   .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
let h = scan()
let w = scan()
proc encode(x,y:int) : int = x * h + y
var C = 0
proc flip(n,x,y:int) : int =
  result = n
  const dxdy9 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0),(1,1),(1,-1),(-1,-1),(-1,1),(0,0)]
  for d in dxdy9:
    let nx = x + d.x
    let ny = y + d.y
    if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
    result = result xor ^encode(nx,ny)
for y in 0..<h:
  for x in 0..<w:
    if getchar_unlocked() == '1': C = C or ^encode(x,y)
    getchar_unlocked()
# 一番上を決めてしまうと1通りしかなくなる
for ix in 0 ..< ^w:
  var c = C