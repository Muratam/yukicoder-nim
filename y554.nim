import strutils
const A = (proc():seq[int]=
  var evenSum = 0
  var oddSum = 1
  result = @[0,1]
  for i in 2..<1e5.int+10:
    template impl(X,Y) =
      let a = (X * i) mod 1_0000_0000_7
      result &= a
      Y = (Y + a) mod 1_0000_0000_7
    if i mod 2 == 0: impl(oddSum,evenSum)
    else: impl(evenSum,oddSum)
)()
echo A[stdin.readLine().parseInt()]