import strutils,math
template get*():string = stdin.readLine().strip()
proc sqrt(n:uint):uint = n.float.sqrt.uint
let n = get().parseInt().uint
let c = 1u + 8u * n
if c.sqrt * c.sqrt != c or c.sqrt mod 2 == 0: quit "NO",0
echo "YES\n",(c.sqrt - 1 ) div 2
# x * (x+1) div 2 == n
# 1999999905000001128
# 9223372036854775807 == int.high