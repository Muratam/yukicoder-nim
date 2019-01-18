# Vec2
template useVector2() =
  const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
  const dxdy8 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0),(1,1),(1,-1),(-1,-1),(-1,1)]
  type Vec2 = tuple[x,y:int]
  proc `+`(p,v:Vec2):Vec2 = result.x = p.x+v.x; result.y = p.y+v.y
  proc `-`(p,v:Vec2):Vec2 = result.x = p.x-v.x; result.y = p.y-v.y
  proc `*`(p,v:Vec2):int = p.x * v.x + p.y * v.y
  proc sqlen(p:Vec2):int = p.x * p.x + p.y * p.y
# 二次元行列
template useMatrix() =
  proc transpose*[T](mat:seq[seq[T]]):seq[seq[T]] =
    result = newSeqWith(mat[0].len,newSeq[T](mat.len))
    for x,xs in mat: (for y,ys in xs:result[y][x] = mat[x][y])
  proc `+`[T](mat1,mat2:seq[seq[T]]):seq[seq[T]] = #matIt(mat1,mat2, a + b)
    result = mat1; for x,xs in mat2: (for y,ys in xs:result[x][y] += mat2[x][y])
  proc `-`[T](mat1,mat2:seq[seq[T]]):seq[seq[T]] =
    result = mat1; for x,xs in mat2: (for y,ys in xs:result[x][y] -= mat2[x][y])
  template matOpIt*[T](matA,matB:seq[seq[T]],op):seq[seq[T]] =
    var result = matA
    for x {.inject.},xs in mat:
      for y{.inject.},ys in xs:
        let a {.inject.} = matA[x][y]
        let b {.inject.} = matB[x][y]
        result[x][y] = op
    result
