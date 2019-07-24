#[
# custom class
import ./priority_queue
type CTuple {.importcpp: "std::tuple", header: "<tuple>".} [A,B,C] = object
# proc cInitCTuple(A,B,C: typedesc): CTuple[A,B,C] {.importcpp: "std::tuple<'*1,'*2,'*3>()", nodecl.}
{.importc, header:"<tuple>".}
proc makeTuple*[A,B,C](a:A,b:B,c:C): CTuple[A,B,C] {.importc:  "std::make_tuple", header: "<tuple>", nodecl.}
when isMainModule:
  import unittest
  test "Nim tuple => C++":
    type Pos = tuple[x,y,z:int]
    let a = makeTuple(10,20,30)
    # var pq = initPriorityQueue[Pos]()
    # pq.add((10,10,10))
    # echo pq
    # var poses : seq[Pos] = newSeqWith(5,(0,0))
    # var posVec  = poses.toVector()
    # echo posVec
]#
