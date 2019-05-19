import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let n = get().parseInt()
let A = get().split().map(parseInt)
var C = newSeq[int](n + 1)
block:
  C[0] = 0
  for i in 0..<n: C[i+1] = C[i] + A[i]

if true:
  var result = 1e14.int
  for i in 0..<(n-1):
    for j in (i+1)..<(n-1):
      for k in (j+1)..<(n-1):
        let P = C[i] - C[0]
        let Q = C[j] - C[i]
        let R = C[k] - C[j]
        let S = C[^1] - C[k]
        let diff = [P,Q,R,S].sorted(cmp)
        let answer = diff[^1] - diff[0]
        if answer < result:
          result = answer
  echo result
if false:
  var answer = 1e14.int
  proc calc(i,j,k:int):int =
    let P = C[i] - C[0]
    let Q = C[j] - C[i]
    let R = C[k] - C[j]
    let S = C[^1] - C[k]
    let diff = [P,Q,R,S].sorted(cmp)
    result = diff[^1] - diff[0]
    answer .min= result
  var i = 0
  var j = i + 1
  var k = j + 1
  var pre = calc(i,j,k)
  while true:
    var updates = newSeq[tuple[index:int,pro:int]]()
    if k < n - 2:
      updates &= (0,calc(i,j,k+1))
      if j < k - 1:
        updates &= (1,calc(i,j+1,k+1))
        if i < j - 1:
          updates &= (2,calc(i+1,j+1,k+1))
    if j < k - 1:
      updates &= (3,calc(i,j+1,k))
      if i < j - 1:
        updates &= (4,calc(i+1,j+1,k))
    if i < j - 1:
      updates &= (5,calc(i+1,j,k))
      if k < n - 2:
        updates &= (6,calc(i+1,j,k+1))
    if updates.len() == 0: break
    echo [i,j,k]
    echo updates
    let minarg = updates.sorted((a,b)=>b.pro - a.pro)[0]
    if minarg.pro > pre : break
    pre = minarg.pro
    case minarg.index :
    of 0: k += 1
    of 1: k += 1;j += 1
    of 2: k += 1;j += 1;i += 1
    of 3: j += 1
    of 4: j += 1;i += 1
    of 5: i += 1
    of 6: i += 1;k += 1
    else:discard
  echo answer



