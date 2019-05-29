import sequtils,strutils,heapqueue
proc r():any=stdin.readLine.split.map parseInt
let
 t=r()
 n=t[0]
 v=t[1]
 oy=t[3]-1
 ox=t[2]-1
 L=newSeqWith(n,r())
proc T(sx,sy,sv,c:int)=
 var(C,O)=(newSeqWith(n,newSeq[int] n),newHeapQueue[(int,int,int)]())
 O.push (-sv,sx,sy)
 while O.len>0:
  let(v,x,y)=O.pop()
  if C[x][y]==1:continue
  C[x][y]=1
  if c==1 and x==ox and y==oy:T x,y,-v*2,0
  else:
   for d in[(x,y+1),(x+1,y),(x,y-1),(x-1,y)]:
    if d[0]notin 0..<n or d[1]notin 0..<n or-v-L[d[0]][d[1]]<=0 or C[d[0]][d[1]]==1:continue
    O.push (v+L[d[0]][d[1]],d[0],d[1])
    if d[0]==n-1 and d[1]==n-1:quit "YES",0
T 0,0,v,1
echo"NO"