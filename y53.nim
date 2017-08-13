import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine()
#  3^n / 4^(n-1)
# == exp(nlog3 - (n-1)log4 )
const ans = toSeq(0..100).mapIt(exp(it.float*ln(3.0) - (it.float-1.0)*ln(4.0)))
let N = get().parseInt()
echo ans[N]
