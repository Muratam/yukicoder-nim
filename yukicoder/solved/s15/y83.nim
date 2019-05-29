import sequtils,strutils
let N = stdin.readLine().strip().parseInt()
echo((if N mod 2 == 0 : "1" else: "7") & "1".repeat((N-2) div 2))

# 2:1
# 3:7
# 4:11
# 5:71
# 6:111
# 7:711
# 8:1111
# 9:7111
#10:11111