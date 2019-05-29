import sequtils,bitops,strutils
proc r:any=stdin.readLine.parseInt
proc R:any=stdin.readLine.split.map parseInt
var
 n=r()
 E=newSeqWith n:newSeq[int]0
 A=E
 m=n.fastLog2+1
 d=newSeq[int]n
 p=newSeqWith m:newSeq[int]n
for _ in 0..<n-1:(let t=R();E[t[0]]&=t[1];E[t[1]]&=t[0])
var
 C=newSeqWith n:r()
 I=newSeqWith n: -1
 a=0
proc i(e,w:int)=(for t in E[w]:(if t!=e:(A[w]&=t;i(w,t))))
i -1,0
E=A
proc fp(s,e,cd:int)=(p[0][s]=e;d[s]=cd;for t in E[s]:(if t!=e:fp t,s,cd+1))
fp 0,-1,0
for k in 0..<m-1:(for v in 0..<n:(if p[k][v]<0:p[k+1][v]= -1 else:p[k+1][v]=p[k][p[k][v]]))
proc x(u,v:int):int=(var(u,v)=(u,v);if d[u]>d[v]:swap u,v;for k in 0..<m:(if(((d[v]-d[u])shr k)and 1)!=0:v=p[k][v]);if u==v:return u;for k in(m-1).countdown 0:(if p[k][u]!=p[k][v]:(u=p[k][u];v=p[k][v]));return p[0][u])
proc ff(i,c:int)=(I[i]=C[i]+c;for t in E[i]:ff t,I[i])
ff 0,0
for _ in 0..<r():(let t=R();let y=x(t[0],t[1]);a+=(I[t[0]]+I[t[1]]-2*I[y]+C[y])*t[2])
echo a