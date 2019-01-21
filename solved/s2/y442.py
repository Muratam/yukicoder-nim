import math
s = input().split(" ")
a = int(s[0])
b = int(s[1])
print(math.gcd(a + b, a * b))
