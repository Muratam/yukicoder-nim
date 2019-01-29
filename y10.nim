import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let total = scan()
var dp = newSeqWith(total+1,"")
var next = dp
dp[scan()] = "a"
(n-1).times:
  let a = scan()
  for i in 0..total:
    if dp[i] == "": continue
    if i + a <= total:
      let s = dp[i] & '+'
      if next[i+a].len < s.len or (next[i+a].len == s.len and next[i+a] < s) : next[i+a] = s
    if i * a <= total:
      let s = dp[i] & '*'
      if next[i*a].len < s.len or (next[i*a].len == s.len and next[i*a] < s) : next[i*a] = s
  dp = next
echo dp[total][1..^1]