import strutils,math
let n = stdin.readLine.parseInt()
# n = pi * r * r -> r = sqrt(n / pi)
echo sqrt(n / 3).int + 1