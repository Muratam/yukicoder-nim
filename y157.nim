import sequtils

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let w = scan() # 20
let h = scan() # 20
let C = newSeqWith(h,toSeq(stdin.readLine().items))
# 2つ
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
var A = newSeqWith(h,newSeqWith(w,-1))
proc embA()=
  proc toA(x,y:int) =
    if A[y][x] != -1 or C[y][x] != '.': return
    A[y][x] = 0
    for d in dxdy4: toA(x+d.x,y+d.y)
  for y in 1..h-1:
    for x in 1..w-1:
      if C[y][x] == '.':
        toA(x,y)
        return
embA()

for lv in 0..<400:
  for y in 1..<h-1:
    for x in 1..<w-1:
      let a = A[y][x]
      if lv != a : continue
      for d in dxdy4:
        let y1 = y+d.y
        let x1 = x+d.x
        if A[y1][x1] != -1 : continue
        A[y1][x1] = lv + 1
        for d2 in dxdy4:
          let x2 = x + d.x + d2.x
          let y2 = y + d.y + d2.y
          if x2 < 0 or y2 < 0 or x2 >= w or y2 >= h : continue
          if C[y2][x2] == '.' and A[y2][x2] == -1:
            echo lv + 1
            quit 0