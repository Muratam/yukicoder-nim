import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc putchar_unlocked(c :char) {. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc path(n:int) : string =
  if n == 0 : return "??"
  if n == 1 : return "L"
  if n == 2 : return "R"
  if n mod 2 == 1: return path(n div 2) & "L"
  return path((n-1) div 2) & "R"

const pathes = toSeq(0..4096).mapIt((it.path & "\n").cstring)
let m = scan()
m.times: printf(pathes[scan()])
