{.pragma:vecheader, header:"<vector>".}
type vector {.importcpp:"std::vector", vecheader.}[T] = object
proc newVector[T]():vector[T] {.importcpp:"std::vector<'*0>()", vecheader.}
proc newVector[T](size:int):vector[T] {.importcpp:"std::vector<'*0>(#)", vecheader.}
proc newVector[T](size:int, val:T):vector[T] {.importcpp:"std::vector<'*0>(@)", vecheader.}
proc `[]`[T](base:var vector[T], idx:int):var T {.importcpp:"#[#]", vecheader.}
proc `[]=`[T](base:var vector[T], idx:int, val:T) {.importcpp:"#[#]=#", vecheader.}
proc push_back[T](base:var vector[T], val:T){.importcpp:"#.push_back(@)", vecheader.}
proc size[T](base:vector[T]):int {.importcpp:"#.size()", vecheader.}
iterator items[T](v:var vector[T]): T =
   for i in 0..<size(v):
      yield v[i]
iterator mitems[T](v:var vector[T]):var T =
   for i in 0..size(v):
      yield v[i]

var vec = newVector[string](3)
for i in 1..size(vec):
   vec[i-1]="astring"
# for item in vec.mitems:
#    echo item