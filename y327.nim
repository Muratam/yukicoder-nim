proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc asAlphabet(a:int) : string =
  proc impl(a:int) : seq[char] =
    let c = a mod 26
    let s = ('A'.ord + c).chr
    if a < 26: return @[s]
    result = impl(a div 26 - 1)
    result &= s
  return cast[string](impl(a))

echo scan().asAlphabet()