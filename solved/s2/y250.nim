template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}

proc impl() =
  template OK() =
    printf("AC\n")
    return
  template NG() =
    printf("ZETUBOU\n")
    return
  var d = scan() - 1 # 深さ
  var x = scan()
  let t = scan()
  if t == 0: NG()
  if d == 0: OK()
  var ans = 1
  if d > x : swap(x,d)
  for i in 1..d:
    ans = ans * (x+i) div i
    if ans <= t : continue
    NG()
  OK()

let q = scan()
q.times: impl()