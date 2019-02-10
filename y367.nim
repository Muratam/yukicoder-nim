import sequtils,strutils
var
 hw=stdin.readLine.split.map parseInt
 h=hw[0]
 w=hw[1]
 M=newSeqWith h:stdin.readLine
 g,o:int
 qi=0
 q=newSeq[(int,int,int,int)]()
 D=newSeqWith w:newSeqWith h*2:[9999,9999]
for y in 0..<h:(for x in 0..<w:(if M[y][x]=='S':(D[x][y][0]=0;q&=(x,y,1,0));if M[y][x]=='G':(g=x;o=y)))
while q.len-qi>0:(let(x,y,k,f)=q[qi];qi+=1;for d in[@[(1,1),(-1,-1),(1,-1),(-1,1)],@[(1,2),(2,1),(-1,-2),(-2,-1),(-1,2),(-2,1),(1,-2),(2,-1)]][k]:(let(n,m)=(x+d[0],y+d[1]);if n in 0..<w and m in 0..<h:(if n==g and m==o:quit $(f+1),0;var z=k;if M[m][n]=='R':z=1-k;if D[n][m][z]>f+1:(D[n][m][z]=f+1;q&=(n,m,z,f+1)))))
echo -1