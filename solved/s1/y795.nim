proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
var N:array[100010,char]
var i = 0
while i < 100010:
  let k = getchar_unlocked()
  if k < '0': break
  N[i] = k
  i += 1
for j in 0..<i:
  if N[j] != getchar_unlocked() :
    quit "No",0
if getchar_unlocked() != '0':
  quit "No",0
quit "Yes",0
