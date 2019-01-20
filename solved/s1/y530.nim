import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
echo 2017 - get().parseInt()