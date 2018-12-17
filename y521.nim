import sequtils,strutils
let (n,k) = (let t = stdin.readline.split().map(parseInt);(t[0],t[1]))
if k == 0 or k > n : echo 0
elif k * 2 - 1 == n : echo n - 1
else: echo n - 2