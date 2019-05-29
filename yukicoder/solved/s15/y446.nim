import sequtils,strutils,algorithm,math,macros,strformat
template get*():string = stdin.readLine().strip()
let a = get()
let b = get()
if a.isDigit() and b.isDigit() and a.parseInt >= 0 and a.parseInt <= 12345 and b.parseInt >= 0 and b.parseInt <= 12345:
  if a.parseInt != 0 and a[0] == '0' or b.parseInt != 0 and b[0] == '0': echo "NG"
  elif a.parseInt == 0 and a != "0" or b.parseInt == 0 and b != "0": echo "NG"
  else: echo "OK"
else: echo "NG"