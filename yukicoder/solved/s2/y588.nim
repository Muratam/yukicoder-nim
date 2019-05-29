template `max=`*(x,y) = x = max(x,y)
let S = stdin.readLine()
if S.len <= 2 : quit "-1",0
var ans = 1
for i in 1..<S.len-1:
  block:
    var iAns = 1
    for j in 1..S.len:
      if i-j < 0 or i+j >= S.len: break
      if S[i-j] == S[i+j] : iAns += 2
    ans .max= iAns
  block:
    var iAns = 0
    if i+1<S.len and S[i] == S[i+1] : iAns += 2
    for j in 1..S.len:
      if i-j < 0 or i+1+j >= S.len: break
      if S[i-j] == S[i+1+j] : iAns += 2
    ans .max= iAns
echo ans