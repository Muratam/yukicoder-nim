from itertools import permutations

n = int(raw_input())
a = map(int, raw_input().split())
m = int(raw_input())
b = map(int, raw_input().split())

a.sort()
b.sort()
b.reverse()

res = m + 1
for perm in permutations(a, n):
    print res
    temp = b[:]
    i, j = 0, 0
    while i < n and j < m:
        if temp[j] >= perm[i]:
            temp[j] -= perm[i]
            i += 1
        else:
            j += 1
    res = min(res, j + 1)

if res < m + 1:
    print res
else:
    print -1
