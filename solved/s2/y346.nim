import sequtils,strutils,algorithm,math,sugar,macros,strformat

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}

let S = stdin.readLine()
var w = 0
var ans = 0
for s in S.reversed():
  if s == 'w':
    w += 1
    continue
  if s != 'c' : continue
  ans += w * (w-1) div 2
echo ans