import sequtils,strutils,algorithm,math,sugar,macros,strformat
let a = stdin.readLine.parseInt()
if a < 15: echo -1
else: echo a - 7
