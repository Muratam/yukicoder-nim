import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()

let
  N = get().parseInt()
  total = get().parseInt()
  A = get().split().map(parseInt)
type
  Op = enum Plus,Mul

# total div A[i] == 0  => search 2 (先に+から) / 右から処理
# .......+++++++++++++++ が多い方を優先してしまう
# 2や1に弱い
proc seek(i,total:int,op:Op): seq[Op] =
  echo i," ",total
  if total < 0 : return nil
  if i == 0:
    if total == A[i] : return @[]
    else : return nil
  let plus = seek(i-1,total - A[i],Plus)
  if plus != nil : return plus & Plus
  if total mod A[i] == 0 :
    let mul = seek(i-1,total div A[i],Mul)
    if mul != nil : return mul & Mul
  return nil

echo seek(N-1,total,Plus)