import sequtils,strutils
proc L:any=stdin.readLine.parseInt
proc R:any=stdin.readLine.split.map parseInt
var
 w=L()
 n=L()
 J=R()
 m=L()
 C=R()
 s=n+m
 F=newSeqWith(s+2,newSeq[tuple[t,p,r:int]]())
 U:seq[int]
 z=0
proc a(s,t,p:int)=(F[s]&=(t,p,F[t].len);F[t]&=(s,0,F[s].len-1))
for i,j in J:a s,i,j
for i,c in C:a n+i,s+1,c
for c in n..<n+m:(let X=R()[1..^1].mapIt:it-1;for j in toSeq(0..<n).filterIt(it notin X):a j,c,9999)
proc q(s,t,f:int):int=(if s==t:return f;U[s]=1;for i,e in F[s]:(if U[e.t]!=1 and e.p>0:(let d=q(e.t,t,f.min e.p);if d>0:(F[s][i].p-=d;F[e.t][e.r].p+=d;return d))))
while true:(U=newSeq[int]s+2;let f=q(s,s+1,9999);if f==0:(if w>z:quit "BANSAKUTSUKITA",0 else:quit "SHIROBAKO",0);z+=f)