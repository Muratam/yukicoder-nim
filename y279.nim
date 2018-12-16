import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let s = get()
echo min([s.count('t'),s.count('r'),s.count('e') div 2])