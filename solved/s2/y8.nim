import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)

# N(以上)を宣言してはいけない, 1~kを宣言する me:先行, 0から
# 21,3 => lose:20,17,14,11,8,5,2 ,win:19,18,16,15
# lose: N-1,N-1-K,N-1-2K... => (N-1 -x == 0) mod K -> lose

let P = get().parseInt
P.times:
  var N,K = 0
  (N,K) = get().split().map(parseInt)
  echo if (N-1) mod (K+1) == 0 : "Lose" else: "Win"
