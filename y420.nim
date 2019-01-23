import sequtils
proc combination(n,k:int):int =
  result = 1
  let x = k.max(n - k)
  let y = k.min(n - k)
  for i in 1..y: result = result * (n+1-i) div i

proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
const counts = (proc():seq[string] =
  var ans = newSeq[int](32)
  for n in 0..31: ans[n] = 31.combination(n)
  return ans.mapIt($it)
)()
const answers = (proc():seq[string] =
    var ans = newSeq[int](32)
    for n in 1..31:
      let k = (31-1).combination(n-1)
      for i in 0..<31: ans[n] += k * (1 shl i)
    ans[0] = 0
    return ans.mapIt($it)
)()

let n = scan()
if n >= 32 : quit "0 0",0
printf("%s %s\n",counts[n],answers[n])
