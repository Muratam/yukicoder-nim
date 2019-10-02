import complex,math
# 幾何
# http://www.deqnotes.net/acmicpc/2d_geometry/ 参考
# 線分交差 / 多角形面積 / (頂点を複素数で表して,直線や線分を複素ベクトルで表すべき)
# 頂点の回転などの一次変換や内積・外積が複素数の積で表せたり、方程式で直線・線分を表現したときに現れる例外ケースがベクトルには少ない

# complex : abs(=距離) sqrt exp ln pow sin phase polar rect
when NimMajor * 100 + NimMinor >= 18: discard
else:
  type Complex64 = Complex
  proc complex(x,y:float):Complex64 = (x,y)

const EPS = 1e-6
proc `$`*(a:Complex64):string = ($a.re)[0..<min(($a.re).len,9)] & " + " & ($a.im)[0..<min(($a.im).len,9)] & "i"
proc `~~` *(x, y: float): bool = abs(x - y) < EPS # ≒
proc `~~<` *(x, y: float): bool = x < y + EPS # ≒
proc `~~` *(x, y: Complex64): bool = abs(x.re - y.re) ~~ 0.0 and abs(x.im - y.im) ~~ 0.0
proc conj*(a:Complex64):Complex64 = a.conjugate # 共役
proc unit*(a:Complex64):Complex64 = a / a.abs() # 単位ベクトル
proc norm*(a:Complex64):Complex64 = complex(-a.im,a.re).unit # 法線ベクトル
proc dot*(a,b:Complex64):float = a.re * b.re + a.im * b.im # |a||b|cosθ
proc cross*(a,b:Complex64):float = a.re * b.im - a.im * b.re # |a||b|sinθ,z=0
proc isVertical*(a,b:Complex64) : bool = a.dot(b) ~~ 0.0 # 垂直判定
proc isHorizontal*(a,b:Complex64):bool = a.cross(b) ~~ 0.0 # 平行判定
type Line = tuple[a,b:Complex64]
proc dir*(l:Line):Complex64 = l.b-l.a
proc isOn*(x:Complex64,l:Line):bool = l.dir.cross(x-l.a) ~~ 0.0 # x が a-b 直線状
proc isOnAsSegment*(x:Complex64,l:Line):bool = abs(l.a-x) + abs(x-l.b) ~~< l.dir.abs() # x が a-b の線分上
proc distance*(x:Complex64,l:Line):float = l.dir.cross(x-l.a).abs() / l.dir.abs() # 直線と点との距離
proc distanceAsSegment*(x:Complex64,l:Line):float = # 線分との距離
  if l.dir.cross(x - l.a) ~~< 0.0 : return (x-l.a).abs()
  if l.dir.cross(x - l.b) ~~< 0.0 : return (x-l.b).abs()
  return x.distance(l)
proc isIntersected*(l1,l2:Line):bool = # 線分の交差判定
  l1.dir.cross(l2.a - l1.a) * l1.dir.cross(l2.b - l1.a) ~~< 0.0 and
    l2.dir.cross(l1.a - l2.a) * l2.dir.cross(l1.b - l2.a) ~~< 0.0
proc interSectedPoint*(l1,l2:Line):Complex64 = # 直線の交点
  l1.a + l1.dir * l2.dir.cross(l2.a - l1.a) / l2.dir.cross(l1.dir)




when isMainModule:
  import unittest
  test "geometry(complex)":
    let a = complex(1.0,-2.0)
    check: a.unit ~~ complex(0.4472135 , -0.894427)
    check: a.norm ~~ complex(0.8944271 , 0.4472135)
    check: a.norm * a.unit ~~ complex(0.7999999 , -0.6)
    check: a.norm.dot(a.unit) ~~ 0.0
    check: a.norm.isVertical(a.unit)
    check: not a.norm.isHorizontal(a.unit)
    check: not a.unit.isVertical(a.unit+1e-9)
    check: a.unit.isHorizontal(a.unit+1e-9)
