import sequtils,strutils,algorithm,math

var S = stdin.readline()
for i,s in S:
  var diff = s.ord - 'A'.ord
  diff -= (i+1) mod 26
  diff += 26
  diff = diff mod 26
  S[i] = (diff + 'A'.ord).chr
echo S