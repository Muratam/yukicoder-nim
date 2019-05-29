import sequtils,strutils,algorithm,math,future,macros
template get*():string = stdin.readLine().strip()
template `min=`*(x,y:typed):void = x = min(x,y)

#[
const INF = 1e6.int
proc getABCCost() : array[31,array[31,array[31,array[31,int]]]] =
  for A in 1..30:
    for B in 1..A:
      for C in 1..B:
        var dp = newSeqWith(30+1,INF) # v を ABC で 作るのに掛かるコストの最小値
        dp[0] = 0
        for v in 0..30-A:
          if dp[v] != INF: dp[v + A] .min= dp[v] + 1
        for v in 0..30-B:
          if dp[v] != INF: dp[v + B] .min= dp[v] + 1
        for v in 0..30-C:
          if dp[v] != INF: dp[v + C] .min= dp[v] + 1
        for v in 0..30: result[A][B][C][v] = dp[v]
let ABC = getABCCost()
#var ans : array[31,array[31,array[31,array[31,int]]]]
var ans = newSeqWith(30,newSeqWith(30,newSeqWith(30,newSeqWith(30,99))))
for A in 1..30:
  for B in 1..A:
    for C in 1..B:
      for v1 in 0..<30:
        for v2 in 0..v1:
          for v3 in 0..v2:
            for v4 in 0..v3:
              ans[v1][v2][v3][v4] .min= @[v1+1,v2+1,v3+1,v4+1].mapIt(ABC[A][B][C][it]).sum()
for v1 in 0..<30:
  for v2 in 0..<30:
    for v3 in 0..<30:
      if ans[v1][v2][v3].allIt(it == 99) :
        ans[v1][v2][v3] = @[0]
        continue
      for v4 in 0..<30:
        if ans[v1][v2][v3][v4] == 99 : ans[v1][v2][v3][v4] = 0
      for v4 in 0..<30: # ****0000 => ****
        if ans[v1][v2][v3][v4] == 99 : ans[v1][v2][v3][v4] = 0
echo ans
# import sequtils,strutils,algorithm,math,macros
# macro parse() : seq = result = "[[[[4]]]]".replace("[","@[").parseStmt
# let V = stdin.readLine.strip.split.map(parseInt).sorted(cmp,Descending)
# const ANS = parse()
# let (a0,a1,a2,a3) = (V[0]-1,V[1]-1,V[2]-1,V[3]-1)
# if ANS.len > a0 and ANS[a0].len > a1 and ANS[a0][a1].len > a2 and ANS[a0][a1][a2].len > a3: echo ANS[a0][a1][a2][a3]
# else: echo 4
# SPACE
# ,0]
# ,0]]
# default : 4 (,4]] delete)
]#



let V = get().split().map(parseInt).sorted(cmp) # 4 * [1,30]
const INF = 1e6.int
var ans = INF
# 30 * 30 * 30
for A in 1..V.max():
  for B in 1..A:
    for C in 1..B:
      var dp = newSeqWith(V.max()+1,INF) # v を ABC で 作るのに掛かるコストの最小値
      dp[0] = 0
      for v in 0..V.max()-A:
        if dp[v] != INF: dp[v + A] .min= dp[v] + 1
      for v in 0..V.max()-B:
        if dp[v] != INF: dp[v + B] .min= dp[v] + 1
      for v in 0..V.max()-C:
        if dp[v] != INF: dp[v + C] .min= dp[v] + 1
      ans .min= V.mapIt(dp[it]).sum()
echo ans
# 3 4 5 => 28 29 30
# 0_________________
# 0__1__2__3__4__5_
# 0__11___
