import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let S = get().split().map(parseInt).sorted(cmp)[1..^2]
echo fmt"{S.sum() / S.len():.2f}"

