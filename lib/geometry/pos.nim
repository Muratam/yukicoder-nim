# 二次元座標 整数位置管理用
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
const dxdy8 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0),(1,1),(1,-1),(-1,-1),(-1,1)]
type Pos = tuple[x,y:int]
proc `+`(p,v:Pos):Pos = (p.x+v.x,p.y+v.y)
proc dot(p,v:Pos):int = p.x * v.x + p.y * v.y
