import sequtils
proc combination(n,k:int):int = # nCk
  result = 1
  let x = k.max(n - k)
  let y = k.min(n - k)
  for i in 1..y: result = result * (n+1-i) div i
proc solve(n:int):int =
  result =  (6*n+7).combination(7) #全数
  result -= 8.combination(1) * (5*n-1 + 7).combination(7) # 1つがn+1以上ある
  result += 8.combination(2) * (4*n-2 + 7).combination(7) # 2つが
  result -= 8.combination(3) * (3*n-3 + 7).combination(7) # 3つが
  if n < 2 : return
  result += 8.combination(4) * (2*n-4 + 7).combination(7) # 4つが
  if n < 5 : return
  result -= 8.combination(5) * (1*n-5 + 7).combination(7) # 5つが
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
const ans = toSeq(0..100).mapIt(it.solve())
echo ans[scan()]