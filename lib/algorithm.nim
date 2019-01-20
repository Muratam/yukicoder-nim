#
proc topologicalSort(edges:seq[seq[int]]) : seq[int] =
  # edges : n -> m の隣接リスト
  var visited = newSeqWith(edges.len,0)
  var tsorted = newSeq[int]()
  proc visit(node:int) =
    visited[node] += 1
    if visited[node] > 1: return
    for edge in edges[node]: visit(edge)
    tsorted &= node
  for n in 0..<edges.len: # 孤立点除去 ?
    visit(n)
  return tsorted.filterIt(visited[it] > 1 or edges[it].len > 0)
#
proc dijkestra(L:seq[seq[int]], startX,startY:int,
                diffSeq:seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]) :auto =
  type field = tuple[x,y,v:int]
  let (W,H) = (L.len,L[0].len)
  const INF = int.high div 4
  var cost = newSeqWith(W,newSeqWith(H,INF))
  var opens = newBinaryHeap[field](proc(a,b:field): int = a.v - b.v)
  opens.push((startX,startY,0))
  while opens.size() > 0:
    let (x,y,v) = opens.pop()
    if cost[x][y] != INF : continue
    cost[x][y] = v
    for d in diffSeq:
      let (nx,ny) = (d.x + x,d.y + y)
      if nx < 0 or ny < 0 or nx >= W or ny >= H : continue
      var n_v = v + L[nx][ny]
      if cost[nx][ny] == INF :
        opens.push((nx,ny,n_v))
  return cost



template imos2() =
  # array[-501..501,array[-501..501,int]]  => [x1..x2][y1..y2]
  proc imos2Reduce(field:typed) =
    for x in field.low + 1 .. field.high:
      for y in field[x].low .. field[x].high:
        field[x][y] += field[x-1][y]
    for x in field.low .. field.high:
      for y in field[x].low + 1 .. field[x].high:
        field[x][y] += field[x][y-1]

  proc imos2Regist(field:typed,x1,y1,x2,y2:int,val:typed) =
    field[x1][y1] += val
    field[x1][y2+1] -= val
    field[x2+1][y1] -= val
    field[x2+1][y2+1] += val
