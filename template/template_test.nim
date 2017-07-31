#[
{.emit: """
template <class T> struct Vector { struct Iterator {}; };
""".}
type
  Vector {.importcpp: "Vector".} [T] = object
  VectorIterator {.importcpp: "Vector<'0>::Iterator".} [T] = object
var it: VectorIterator[int]
]#
#[
{.emit: """
template <class T>
class Wrap{
  T hoge;
  Wrap(T x):hoge(x){}
};
""".}
type
  Wrap {.importcpp: "Wrap".} [T] = object
proc newWrap(x: int): Wrap {.importcpp: "new Wrap(@)", nodecl.}
var wrap: Wrap[int]
]#

#[
type
  MyIntObj {.importcpp: "MyInt", nodecl.} [T]= object
  MyInt = ptr MyIntObj

proc newMyInt(x: cint): MyInt {.importcpp: "new MyInt(@)", nodecl.}
proc inc(this: MyInt) {.importcpp: "#.inc(@)", nodecl.}
proc get(this: MyInt): int {.importcpp: "#.get(@)", nodecl.}

var mi = newMyInt(5)
mi.inc()
mi.inc()
echo mi.get()
]#


#[
{.emit: """
#include <queue>
#include <cmath>
class MyInt {
public:
  int num;
  MyInt(int x): num(x) {
    std::priority_queue<int> que;
    que.push(3);
    num += que.top();
  }
  void inc() { num++; }
  int get() { return num + (int)(std::fabs(-10.0f)); }
};
""".}

type
  MyIntObj {.importcpp: "MyInt", nodecl.} [T]= object
  MyInt = ptr MyIntObj

proc newMyInt(x: cint): MyInt {.importcpp: "new MyInt(@)", nodecl.}
proc inc(this: MyInt) {.importcpp: "#.inc(@)", nodecl.}
proc get(this: MyInt): int {.importcpp: "#.get(@)", nodecl.}

var mi = newMyInt(5)
mi.inc()
mi.inc()
echo mi.get()
]#
