import sequtils,strutils,math
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
proc parseRoman(S:string): int =
  return S.replace("CM"," 900 ").replace("CD"," 400 ")
   .replace("XC"," 90 ").replace("XL"," 40 ")
   .replace("IX"," 9" ).replace("IV"," 4 ")
   .replace("M"," 1000 ").replace("D"," 500 ")
   .replace("C"," 100 ").replace("L"," 50 ")
   .replace("X"," 10 ").replace("V"," 5 ")
   .replace("I"," 1 ").replace("  "," ").strip().split().map(parseInt).sum()

proc toRoman(n:int):string =
  if n < 10:
    if n == 4 : return "IV"
    if n == 9 : return "IX"
    if n < 4: return "I".repeat(n)
    return "V" & "I".repeat(n-5)
  if n < 100:
    let left = (n mod 10).toRoman()
    let my = n div 10
    if my == 4 : return "XL" & left
    if my == 9 : return "XC" & left
    if my < 4 : return "X".repeat(my) & left
    return "L" & "X".repeat(my-5) & left
  if n < 1000:
    let left = (n mod 100).toRoman()
    let my = n div 100
    if my == 4 : return "CD" & left
    if my == 9 : return "CM" & left
    if my < 4 : return "C".repeat(my) & left
    return "D" & "C".repeat(my-5) & left
  if n < 4000:
    let left = (n mod 1000).toRoman()
    let my = n div 1000
    return "M".repeat(my) & left
  return "ERROR"
let n = scan()
let r = stdin.readLine.split().map(parseRoman).sum()
echo r.toRoman()
