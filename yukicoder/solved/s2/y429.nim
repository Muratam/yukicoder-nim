import sequtils,strutils
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord.int32 - '0'.ord.int32

let n = scan()
let k = scan()
let x = scan()
var C : array[100010,int32]
var XC: array[100010,int32]
for i in 0.int32..<n.int32: C[i] = i + 1

for ik in 1..k:
  if ik == x :
    XC = C
    4.times : discard getchar_unlocked()
    continue
  let a = scan() - 1
  let b = scan() - 1
  swap(C[a],C[b])
var diff = newSeq[int]()
for i in 0..<n:
  let d = scan()
  if C[i] == d : continue
  diff &= C[i]
  if diff.len == 2: break
var answers = newSeq[int]()
for i,xc in XC:
  if xc != diff[0] and xc != diff[1] : continue
  answers &= i + 1
  if answers.len == 2: break
echo answers.mapIt($it).join(" ")