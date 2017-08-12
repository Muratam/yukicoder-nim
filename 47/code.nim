import strutils,math
proc ctz(n:int):cint{.importC: "__builtin_ctz", noDecl .}
echo stdin.readLine().parseInt().nextPowerOfTwo().ctz()