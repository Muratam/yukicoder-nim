import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let s = get()
if s.endsWith("ai") : echo s[0..^3],"AI"
else: echo s,"-AI"