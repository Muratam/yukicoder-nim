import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)

# 素数テーブル生成なし (106ms)
# 探索枝刈り breakなし (22ms)
# 最もコスパのいい速度 (5ms)
# コンパイル時素数テーブル生成 : 速度2倍 コンパイル時間4倍
# 結論テーブル生成 (2ms)

proc getIsPrimes(n:int) :seq[bool] =
  result = newSeqWith(n+1,true)
  result[0] = false
  result[1] = false
  for i in 2..n.float.sqrt.int :
    if not result[i]: continue
    for j in countup(i*2,n,i):
      result[j] = false

proc getPrimes(n:int):seq[int] =
  let isPrime = getIsPrimes(n)
  result = newSeq[int](0)
  for i,p in isPrime:
    if p : result.add(i)


# lose 2 3 ... <=> win 0 1 4 5 6 7 ...
let N = get().parseInt
let primes = getPrimes(N)
var win = newSeqWith(N,false)
win[0] = true
win[1] = true
for i in 2..N:
  for p in primes:
    if i - p < 0 : break
    if not win[i-p]:
      win[i] = true
      break
echo if win[N]: "Win" else: "Lose"