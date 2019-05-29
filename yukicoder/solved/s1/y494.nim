import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let s = get()
for i in 0..< s.len():
  if s[i] != '?' : continue
  echo "yukicoder"[i]
  break