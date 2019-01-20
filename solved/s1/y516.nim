import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

if newSeqWith(3,if get() == "RED": 1 else: 0).sum() > 1: echo "RED"
else: echo "BLUE"

