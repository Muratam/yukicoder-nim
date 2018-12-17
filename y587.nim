import sequtils,strutils,algorithm,math,sugar,tables
let S = toSeq(stdin.readline.toCountTable().pairs).sorted((x,y)=>x[1]-y[1])
if S[^1][1] == 2 and S[0][1] == 1 and S[1][1] == 2 : echo S[0][0]
else: echo "Impossible"
