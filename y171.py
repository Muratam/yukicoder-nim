S = input()
I = dict()
for s in S:
    I[s] = I.get(s, 0) + 1
A = []
for k, v in I.items():
    A.append(v)
ans = 1
for i in range(1, sum(A) + 1):
    ans *= i
for a in A:
    for i in range(1, a + 1):
        ans = ans // i
print((ans - 1) % 573)
