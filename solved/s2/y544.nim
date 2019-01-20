import strutils
let S = stdin.readLine()
var A = ""
var B = ""
for s in S:
  if s == '7':
    A &= "3"
    B &= "4"
  else:
    A &= s
    B &= "0"
echo A," ",$B.parseInt()
