import sequtils,strutils,algorithm,math,sugar,macros,strformat
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  var minus = false
  while true:
    var k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1

let n = scan()
let xLB = scan()
let xRB = scan()
let LRD = toSeq(0..<n)
  .mapIt((let t = (scan(),scan(),scan(),scan()) ;(it,t[0],t[2],t[3])))
  .sortedByIt(-it[3])
var limits : array[1281,int]
var hits = newSeq[bool](n)
for ilrd in LRD:
  let (i,l,r,d) = ilrd
  for x in xLB.max(l)..xRB.min(r):
    if limits[x] >= d: continue
    limits[x] = d
    hits[i] = true
for hit in hits:
  if hit : echo 1
  else:echo 0