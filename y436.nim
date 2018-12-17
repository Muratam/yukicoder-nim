import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let S = get()
let c = S.count('c')
let w = S.len() - c
echo min(c-1,w)
