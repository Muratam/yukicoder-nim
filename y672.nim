proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
# 3 -2 5 -2 8 -4
#[
var alen = 0
var blen = 0
var ans = 0
var preIsA = false
var preIsB = false
while true:
  let c = getchar_unlocked()
  if c != 'A' and c != 'B' : break
  if c == 'A':
    if preIsB :
      ans .max= alen.min(blen) * 2
      alen = 0
    alen += 1
    preIsA = true
    preIsB = false
  else:
    if preIsA :
      ans .max= alen.min(blen) * 2
      blen = 0
    blen += 1
    preIsB = true
    preIsA = false

ans .max= alen.min(blen) * 2
echo ans
]#