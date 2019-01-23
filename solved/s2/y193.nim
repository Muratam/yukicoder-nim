import sequtils,algorithm,math,tables

proc evalPlusMinusExpression(S:string): tuple[ok:bool,val:int] = # 012+223-123+...
  if S[0] == '+'  or S[0] == '-'  : return (false,0)
  if S[^1] == '+' or S[^1] == '-' : return (false,0)
  var minus = false
  var val = 0
  var ans = 0
  for i,s in S:
    if '0' <= s and s <= '9' :
      val = 10 * val + s.ord - '0'.ord
      if i != S.len - 1 : continue
    if minus : ans -= val
    else: ans += val
    val = 0
    minus = s == '-'
  return (true,ans)

let S = stdin.readLine()
var ans = newSeq[int]()
for i in 0..<S.len:
  let (ok,val) = evalPlusMinusExpression( S[i..^1] & S[0..<i])
  if ok : ans &= val
echo ans.max()
