import sequtils,bitops
template `max=`*(x,y) = x = max(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a:int32) =
  if a == 0:
    putchar_unlocked('0')
    return
  template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
  template mod10(a:int32) : int32 = a - (a.div10 * 10)
  var n = a
  var rev = a
  var cnt = 0
  while rev.mod10 == 0:
    cnt += 1
    rev = rev.div10
  rev = 0
  while n != 0:
    rev = rev * 10 + n.mod10
    n = n.div10
  while rev != 0:
    putchar_unlocked((rev.mod10 + '0'.ord).chr)
    rev = rev.div10
  while cnt != 0:
    putchar_unlocked('0')
    cnt -= 1

var S = newSeq[int]()
while true:
  let k = getchar_unlocked()
  if k < '0': break
  S &= k.ord - '0'.ord

var dp = newSeqWith(1 shl S.len,-1)
proc bitDP(s:int,popcnt:int) : int =
  if dp[s] >= 0 : return dp[s]
  if popcnt + 3 > S.len : return 0
  for a in (not s).countTrailingZeroBits()..<S.len:
    let sa = 1 shl a
    if (sa or s) == s or S[a] == 0 : continue
    for b in (a+1)..<S.len:
      let sb = 1 shl b
      if (sb or s) == s or S[a] == S[b] : continue
      for c in (b+1)..<S.len:
        let sc = 1 shl c
        if (sc or s) == s or S[b] != S[c] : continue
        let s2 = sa or sb or sc or s
        result .max= 100 * S[a] + 10 * S[b] + S[c] + bitDP(s2,popcnt+3)
  dp[s] = result
bitDP(0,0).int32.printInt()
putchar_unlocked('\n')
