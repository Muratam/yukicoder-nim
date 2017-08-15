import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()

let N = get().parseInt()
echo newSeqWith(N,get().split().mapIt(it.split(":").map(parseInt)))
     .mapIt((g:60*it[0][0]+it[0][1], w:60*it[1][0]+it[1][1]))
     .mapIt(if it.g < it.w: it.w - it.g else: 1440 + it.w - it.g)
     .sum()