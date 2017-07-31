var ap*: ptr cint

var a*: cint = 0

ap = addr(a)
ap[] = 222
var b*: cint = 111 + ap[]
