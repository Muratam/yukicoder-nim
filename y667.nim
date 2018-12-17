proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
proc printInt(a:int,skipLeavingZeros:bool = false) =
  # https://stackoverflow.com/questions/18006748/using-putchar-unlocked-for-fast-output
  if a == 0:
    putchar_unlocked('0')
    return
  var n = a
  var rev = a
  var cnt = 0
  while rev mod 10 == 0:
    cnt += 1
    rev = rev div 10
  rev = 0
  while n != 0:
    rev = (rev shl 3) + (rev shl 1) + n mod 10
    n = n div 10
  while rev != 0:
    putchar_unlocked((rev mod 10 + '0'.ord).chr)
    rev = rev div 10
  if not skipLeavingZeros:
    while cnt != 0:
      putchar_unlocked('0')
      cnt -= 1

proc printFloat(a,b:int) =
  if a == 0:
    putchar_unlocked('0')
  else:
    printInt(a div b)
    if a mod b != 0:
      putchar_unlocked('.')
      const leaving = 100000
      let r = (a * leaving div b) mod leaving
      var l = leaving div 10
      while l > r :
        putchar_unlocked('0')
        l = l div 10
      printInt(r,true)
  putchar_unlocked('\n')

var S : array[100002,char]
var left = 0
var l = 0
while true:
  l += 1
  let c = getchar_unlocked()
  S[l] = c
  if c == 'o' : left += 1
  elif c != 'x': break
left *= 100
for i in 1..<l:
  printFloat(left,l-i)
  if S[i] == 'o' : left -= 100