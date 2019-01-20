proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}

proc printAsciis(a:int) =
  const bound = 'z'.ord - 'a'.ord
  if a == 0:
    putchar_unlocked('a')
    return
  var n = a
  while n > 0:
    var c = chr('a'.ord + (n mod bound))
    if c == 'n' : c = 'z'
    putchar_unlocked(c)
    n = n div bound

template put(c:char) =
  if c == 'n' : putchar_unlocked('z')
  else: putchar_unlocked(c)
var n : int
scanf("%d",addr n)
var src = 0
var dst = 1
var ascii = 0
for i in 0..<n div 2:
  var dstC = chr('a'.ord + dst)
  put(chr('a'.ord + src))
  ascii.printAsciis()
  put(dstC)
  putchar_unlocked('\n')
  put(dstC)
  ascii.printAsciis()
  dst += 1
  if dst == 25:
    src += 1
    dst = src + 1
    if src == 23:
      ascii += 1
      src = 0
      dst = 1
  if n mod 2 == 0 and i == n div 2 - 1:
    putchar_unlocked('n')
  else:
    put(chr('a'.ord + src ))
  putchar_unlocked('\n')

if n mod 2 == 1:
  putchar_unlocked('a')
  (n div 2).printAsciis()
  putchar_unlocked('n')
  putchar_unlocked('\n')