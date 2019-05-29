var res = 0
var aNum = 0
for i,s in stdin.readLine:
  if s == 'A':
    res += i - aNum
    aNum += 1
echo res