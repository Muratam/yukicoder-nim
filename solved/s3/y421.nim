import sequtils,times
template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")

type BipartiteMatch = seq[seq[int]]
proc initBipartiteMatch(maxSize:int): BipartiteMatch = newSeqWith(maxSize,newSeq[int]())
proc add(B:var BipartiteMatch,src,dst:int) = (B[dst] &= src;B[src] &= dst)
proc bipartiteMatching(B:BipartiteMatch) : int =
  var match = newSeqWith(B.len,-1)
  var used : seq[bool]
  proc dfs(src:int) : bool =
    # 交互にペアを結んでいく
    used[src] = true
    for dst in B[src]:
      if match[dst] >= 0 :
        if used[match[dst]] : continue
        if not dfs(match[dst]) : continue
      match[src] = dst
      match[dst] = src
      return true
    return false
  for src in 0..<B.len:
    if match[src] >= 0 : continue
    used = newSeq[false](B.len)
    if dfs(src) : result += 1



proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

stopwatch:
  let h = scan()
  let w = scan()
  proc encode(x,y:int):int = x * h + y
  let n = h * w
  var C = newSeqWith(w,newSeqWith(h,'.'))
  for y in 0..<h:
    for x in 0..<w:
      C[x][y] = getchar_unlocked()
    discard getchar_unlocked()
  var F = initBipartiteMatch(n)
  var wSum = 0
  var bSum = 0
  for x in 0..<w:
    for y in 0..<h:
      if C[x][y] == '.' : continue
      const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
      if C[x][y] == 'w' : wSum += 1
      else : bSum += 1
      if C[x][y] != 'w' : continue
      for d in dxdy4:
        let nx = x + d.x
        let ny = y + d.y
        if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
        if C[nx][ny] == '.' : continue
        F.add(encode(x,y),encode(nx,ny))
stopwatch:
  var ans = F.bipartiteMatching()
  wSum -= ans
  bSum -= ans
  ans *= 100
  let pair = min(bSum,wSum)
  ans = ans + 10 * pair
  wSum -= pair
  bSum -= pair
  echo ans + wSum + bSum