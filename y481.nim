import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let B = get().split().map(parseInt).sorted(cmp)
for i,b in B:
  if i + 1 != b:
    echo i + 1
    quit(0)
echo 10