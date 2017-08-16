import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])

proc power(x,n:int): int =
  if n == 0: return 1
  if n == 1: return x
  let pow_2 = power(x,n div 2)
  return pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)


let
  N = get().parseInt()
  A = newSeqWith(N,get())

var nsum,decsum = 0
for a in A:
  let
    sign = if "-" in a : -1 else: 1
    astr = if "." in a : a else: a & ".0"
    (nstr,decstr) = astr.split(".").unpack(2)
    n = nstr.parseInt().abs() * sign
    dec = decstr.parseInt() * 10.power(9-decstr.len()).abs() * sign
  nsum += n
  decsum += dec

#nsum += decsum div 1e9.int
echo nsum
echo decsum
# decsum = decsum mod 1e9.int
# var leftzero = ""
# for i in 0..<10-($decsum).len: leftzero &= "0"
# echo nsum,".",decsum,leftzero
