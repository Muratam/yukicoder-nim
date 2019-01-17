import strutils
proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
let n = stdin.readLine.parseInt()
if n == 0: quit "0", 0
putchar_unlocked('0')
putchar_unlocked('.')
const cycle = ['1','4','2','8','5','7']
for i in 0..<n: putchar_unlocked(cycle[i mod 6])
putchar_unlocked('\n')
