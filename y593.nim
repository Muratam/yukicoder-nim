proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
var S : array[2e6.int+10,char]
scanf("%s",addr S)
var x3 = 0
var x5 = 0
var isOdd = true
for s in S:
  if s < '0': break
  let c = s.ord - '0'.ord
  x3 += c
  if isOdd: x5 += c
  else: x5 -= c
  isOdd = not isOdd
if x3 mod 3 == 0:
  if x5 mod 5 == 0: echo "FizzBuzz"
  else: echo "Fizz"
elif x5 mod 5 == 0 : echo "Buzz"
else :
  printf("%s\n",addr S)


# var S : array[2e6.int+10,char]
# var n = 0
# var x3 = 0
# var x5 = 0
# while true:
#   let k = getchar_unlocked()
#   if k < '0' or k > '9': break
#   let c = k.ord - '0'.ord
#   x3 += c
#   if n mod 2 == 0: x5 += c
#   else: x5 -= c
#   S[n] = k
#   n += 1

# if x3 mod 3 == 0:
#   if x5 mod 5 == 0: echo "FizzBuzz"
#   else: echo "Fizz"
# elif x5 mod 5 == 0 : echo "Buzz"
# else :
#   for i in 0..<n: putchar_unlocked(S[i])
#   putchar_unlocked('\n')