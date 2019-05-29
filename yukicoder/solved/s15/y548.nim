import sequtils,strutils,algorithm,tables
template get*():string = stdin.readLine().strip()
let s = stdin.readLine.sorted(cmp)
if s.join("") == "abcdefghijklm":
  echo s.join("\n")
elif s[0] < 'a' or s[^1] > 'm' or s.toCountTable().len < 12:
  echo "Impossible"
else:
  for c in 'a'..'m':
    if c notin s : echo c