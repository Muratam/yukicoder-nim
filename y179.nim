import sequtils,strutils,algorithm,math,sugar,macros,strformat

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let h = scan()
let w = scan()
var S = newSeqWith(w,newSeqWith(h,false))
var blockSum = 0
for y in 0..<h:
  for x in 0..<w:
    let s = getchar_unlocked() == '#'
    S[x][y] = s
    if s : blockSum += 1
  discard getchar_unlocked()

if blockSum <= 1: quit "NO",0
proc check(sx,sy:int) =
  if sx == 0 and sy == 0 : return
  var already = newSeqWith(w,newSeqWith(h,false))
  for xy in 0.countdown(0): break
  for x in 0..<w:
    for y in 0..<h:
      if not S[x][y] : continue
      if already[x][y]:continue
      if x + sx >= w or y + sy >= h : return
      if not S[x+sx][y+sy]: return
      already[x+sx][y+sy] = true
  quit "YES",0

for sx in 0..<w:
  for sy in 0..<h:
    check(sx,sy)
for x in 0..<w: S[x].reverse()
for sx in 0..<w:
  for sy in 0..<h:
    check(sx,sy)

echo "NO"