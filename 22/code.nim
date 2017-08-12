import sequtils,strutils,strscans,algorithm,math,future,macros
#import sets,queues,tables,nre,pegs
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine() #.strip()

let
  (N,K) = get().split().map(parseInt).unpack(2)
  S = get()
if S[K-1] == '(':
  var cnt = 1
  for i in K..<N:
    let s = S[i]
    if s == '(': cnt += 1
    else: cnt -= 1
    if cnt == 0:
      echo i+1
      quit()
else:
  var cnt = 1
  for i in countdown(K-2,0):
    let s = S[i]
    if s == ')': cnt += 1
    else: cnt -= 1
    if cnt == 0:
      echo i+1
      quit()