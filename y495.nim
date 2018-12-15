import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let s = get().replace("(^^*)","A").replace("(*^^)","B")[0..^2]
echo s.count('A')," ",s.count('B')
