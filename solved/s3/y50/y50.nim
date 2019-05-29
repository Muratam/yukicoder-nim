import sequtils,strutils,algorithm
proc q():any=stdin.readLine
proc R():any=q().split.map(parseInt).sorted cmp
var
 n=q().parseInt
 A=R()
 m=q().parseInt+1
 B=R().reversed
 a=m
while true:(var(T,i,j)=(B,0,0);while i<n and j<m-1:(if T[j]>=A[i]:(T[j]-=A[i];i+=1)else:j+=1);a=a.min j+1;if not A.nextPermutation:break)
if a<m:echo a else:echo -1