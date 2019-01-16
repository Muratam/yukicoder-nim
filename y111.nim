import strutils
let s = stdin.readLine().parseInt()
let f = s div 2 - 1
echo f*(f+1)+(s mod 2)*(s div 2)