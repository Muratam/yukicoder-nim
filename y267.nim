import sequtils,strutils,algorithm

proc sortCard(x,y:string):int =
  proc toN(c:char):int =
    if c == 'A' : return 1
    if c == 'T' : return 10
    if c == 'J' : return 11
    if c == 'Q' : return 12
    if c == 'K' : return 13
    return c.ord - '0'.ord
  proc toA(c:char):int =
    if c == 'D': return 0
    if c == 'C': return 1
    if c == 'H': return 2
    if c == 'S': return 3
  if x[0] != y[0]: return x[0].toA() - y[0].toA()
  return x[1].toN() - y[1].toN()

let n = stdin.readLine().parseInt()
echo stdin.readLine().split().sorted(sortCard).join(" ")
