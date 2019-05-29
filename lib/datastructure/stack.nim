# stack
type Stack*[T] = ref object
  data: seq[T]
  size: int
  index: int
proc newStack*[T](size: int = 64): Stack[T] =
  new(result)
  result.data = newSeq[T](size)
  result.size = size
  result.index = -1
proc deepCopy*[T](self: Stack[T]): Stack[T] =
  new(result)
  result.size = self.size
  result.index = self.index
  result.data = self.data
proc isEmpty*[T](self: Stack[T]): bool = self.index < 0

proc len*[T](self: Stack[T]): int =
  if self.isEmpty(): return 0
  return self.index + 1
proc top*[T](self: Stack[T]): T =
  assert self.index >= 0 and self.index < self.size
  return self.data[self.index]
proc pop*[T](self: var Stack[T]): T {.discardable.} =
  assert self.index >= 0
  result = self.top()
  self.index -= 1
proc push*[T](self: var Stack[T], elem: T) =
  self.index += 1
  if self.index < self.size:
    self.data[self.index] = elem
  else:
    self.data.add(elem)
    self.size += 1
proc `$`*[T](self: Stack[T]): string = $(self.data[..self.index])



# unit test
when isMainModule:
  import unittest
  suite "stack": test "stack":
    var S = newStack[int]()
    check: S.isEmpty()
    S.push(2)
    S.push(3)
    S.push(4)
    var S2 = S.deepCopy()
    check: S.top == 4
    check: S.len == 3
    S.pop()
    check: S.top == 3
    check: S.pop() == 3
    S.pop()
    check: S.isEmpty
    check: S2.len == 3
    check: S2.top == 4
    S2.pop()
    check: S2.top == 3
    S2.push(5)
    check: S2.len == 3
    check: S2.top == 5
