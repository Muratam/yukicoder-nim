import sequtils,strutils
let S = stdin.readLine().split()
let a = S[0] in ["Sat","Sun"]
let b = S[1] in ["Sat","Sun"]
if a and b : echo "8/33"
elif a : echo "8/32"
else: echo "8/31"
