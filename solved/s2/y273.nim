template `max=`*(x,y) = x = max(x,y)

proc check(S:string) : bool =
  for i in 0..<S.len div 2:
    if S[i] != S[^(1+i)] : return false
  return true
let S = stdin.readLine()
var ans = 1
for i in 0..<S.len:
  for j in (i+1)..<S.len:
    if i == 0 and j == S.len - 1 : continue
    if S[i..j].check() : ans .max= j - i + 1
echo ans