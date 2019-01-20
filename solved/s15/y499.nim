import sequtils,strutils,algorithm
var n = stdin.readline.parseInt()
if n == 0 : quit("0",0)
var res = newSeq[int]()
while n > 0:
  res &= n mod 7
  n = n div 7
echo res.reversed().mapIt($it).join("")