import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
# (((*((^^*)))))
var x = newSeqWith(5,0) # ( * ^ ^ を満たした数
var y = newSeqWith(5,0) # ( ^ ^ *を満たした数
while true:
  let c = getchar_unlocked()
  if c == '(':
    x[0] += 1
    y[0] += 1
  elif c == '^':
    x[3] += x[2]
    x[2] = x[1]
    x[1] = 0
    y[2] += y[1]
    y[1] = y[0]
    y[0] = 0
  elif c == '*':
    x[1] += x[0]
    x[0] = 0
    y[3] += y[2]
    y[2] = 0
  elif c == ')':
    x[4] += x[3]
    y[4] += y[3]
  else: break
echo y[4]," ",x[4]