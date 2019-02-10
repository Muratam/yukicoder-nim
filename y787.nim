import strutils,sequtils
setStdIoUnbuffered()
let (p,q) = (let t = stdin.readLine().split().map(parseFloat);(t[0],t[1]))
let u = p * q
let d = p * q + (100-p) * (100-q)
echo (100 * u).float / d.float