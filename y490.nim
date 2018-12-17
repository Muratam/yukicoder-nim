import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
var A = get().split().map(parseInt)
# for i in 1..<(2*n-3):
#   for p in 0..<min(n,1 + (i-1) div 2):
#     let q = i - p
#     if q < n:
#       if A[p] > A[q] : swap(A[p],A[q])
# echo A.join(" ")

# n = 5
# 0 1
# 0 2
# 0 3 | 1 2
# 0 4 | 1 3
# 0 5 | 1 4 | 2 3
# ...
# 0 6 | 1 5 | 2 4 | 3 3
# [3 4] が交換されない => その順序のまま
var B = A.sorted(cmp)
echo