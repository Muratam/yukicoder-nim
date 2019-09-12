a, b = map(int, input().split())
x = a * int(10**50) // b
print(f"{a // b}.{('0'*50+str(x))[-50:]}")
