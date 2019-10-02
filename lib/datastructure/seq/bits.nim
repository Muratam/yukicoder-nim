# Bitで管理する系の集合をまとめておく
proc `in`(inner,outer:int):bool = (inner or outer) <= inner

when isMainModule:
  import unittest
  test "Bit":
    echo 0b0011 in 0b1111
    echo(not (0b1111 in 0b0101))
    echo 0b0010 in 0b0111
    echo 0b0011 in 0b1111
