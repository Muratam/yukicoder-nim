import sequtils,strutils,algorithm,math,sugar,macros,strformat
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc get(n:int): string =
  var res = newSeqWith(n,newSeqWith(n,0))
  var dx = 1
  var dy = 0
  var dir = 0
  const dirs = [(1,0),(0,1),(-1,0),(0,-1)]
  var x = 0
  var y = 0
  for i in 1..<n*n:
    res[x][y] = i
    while true:
      let nx = x + dx
      let ny = y + dy
      if nx >= 0 and ny >= 0 and nx < n and ny < n and res[nx][ny] == 0:
        x = nx
        y = ny
        break
      else:
        dir = (dir + 1) mod 4
        (dx,dy) = dirs[dir]
  res[x][y] = n*n
  result = ""
  for x in 0..<n:
    result &= toSeq(0..<n).mapIt(fmt"{res[it][x]:03d}").join(" ") & "\n"

proc gets(): seq[string] =
  result = @[]
  for i in 1..30:
    result &= get(i)

const reses = gets()
var n :int
scanf "%d",addr n
printf reses[n-1]
