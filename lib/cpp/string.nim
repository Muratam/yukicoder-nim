# TODO: string
#[
import macros
{.experimental: "dotOperators".}
type
  stdString {.importcpp: "std::string", header: "<string>".} = object
  stdUniquePtr[T] {.importcpp: "std::unique_ptr", header: "<memory>".} = object
proc c_str*(a: stdString): cstring {.importcpp: "(char *)(#.c_str())", header: "<string>".}
proc len*(a: stdString): int {.importcpp: "(#.length())", header: "<string>".}
proc `[]=`*(a: var stdString, i: int, c: char) {.importcpp: "(#[#] = #)", header: "<string>".}
proc `*`*[T](this: stdUniquePtr[T]): var T {.noSideEffect, importcpp: "(* #)", header: "<memory>".}
proc make_unique_str(a: cstring): stdUniquePtr[stdString] {.importcpp: "std::make_unique<std::string>(#)", header: "<string>".}
macro `.()`*[T](this: stdUniquePtr[T], name: untyped, args: varargs[untyped]): untyped =
  result = nnkCall.newTree(
    nnkDotExpr.newTree(
      newNimNode(nnkPar).add(prefix(this, "*")),
      name
    )
  )
  copyChildrenTo(args, result)

when isMainModule:
  import unittest
  test "C++ string":
    var str = make_unique_str("test1")
    echo str.c_str()
    str[0] = 'x'
    echo str.c_str()
]#
