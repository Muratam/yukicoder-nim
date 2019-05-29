template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord



let n = scan()
n.times:
  let S = stdin.readLine()
  var ans = 1e8.int
  for i in 0..S.len-11:
    var costG = 0
    for ii in 0..<4:
      if S[i+ii] != "good"[ii]: costG += 1
    var costP = 1e8.int
    for j in i+4..S.len-7:
      var costPi = 0
      for jj in 0..<7:
        if S[j+jj] != "problem"[jj]: costPi += 1
      costP .min= costPi
    ans .min= costG + costP
  echo ans
