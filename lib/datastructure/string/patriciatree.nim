
import critbits

# 標準ライブラリにパトリシア木がある. Nim0.13でも使える.
# HashSet[string] の数倍以内のコストで使えるのでお得.
# 文字列sの集合Sにクエリqを投げる.
# 全要素数 O(1)
# 追加・削除 O(slogS)
# prefix検索 O(qlogS) :: iterator でマッチするもの全てをiterator
# prefixに一致する個数は検索できない.
# nearest は取得できない.
# prefix に一致する要素に対する reduce ができると良いですね...
# セグツリって 区間に対する reduce 木なのでは?
# reduce[T,V](i:V,x,y:T):V を受け付ける木
# 0..nの密な区間 [l,r] に対する reduce ができるのがセグツリ
#　　　　　　　　　　　　　　　　  updateができるのが遅延セグツリ
# [-∞..∞)の密でない区間[l,r] に対する reduce ができる構造もあるはず(使わないセグツリ？)
#                             update ができる構造もあるはず
# 区間 "prefix.*" に対する reduce ができるのが パトリシア木


when isMainModule:
  import unittest
  import strutils
  import times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  var xorShiftVar* = 88172645463325252.uint64
  xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
  proc xorShift() : uint64 =
    xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
    xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
    xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
    return xorShiftVar
  proc randomBit*(maxBit:int):int = # mod が遅い場合
    cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))
  proc randomStringFast*(maxBit:int,kindBit:int=4):string =
    let size = 1 + randomBit(maxBit) # 長いのを大量に
    const A = 'A'.ord
    if kindBit > 4:
      var S = newSeq[char](size)
      for i in 0..<size: S[i] = cast[char](randomBit(kindBit) + A)
      return cast[string](S)
    else:
      result = ""
      for i in 0..<size: result.add cast[char](randomBit(kindBit) + A)
  # bench
  import sets
  stopwatch:
    block:
      echo "Raw"
      var S = 0
      for i in 0..<6e5.int:
        S += randomStringFast(3).len
      echo S
  # stopwatch:
  #   block:
  #     echo "HashSet"
  #     var S = initSet[string]()
  #     for i in 0..<1e6.int:
  #       S.incl randomStringFast(3,1)
  #     echo S.len
  # stopwatch:
  #   block:
  #     echo "Patricia Tree"
  #     var S : CritBitTree[void]
  #     for i in 0..<1e6.int:
  #       S.incl randomStringFast(3,1)
  #     echo S.len

  # test "Patricia Tree":
  #   block: # キーの重複を許さないver
  #     var T : CritBitTree[int]
  #     echo T.len
  #     T.inc "aiueo"
  #     T.inc "aiueoeo"
  #     T.inc "aiueo"
  #     echo T.len
  #     echo "aiueo" in T
  #     echo "aiueoa" in T
  #     echo T
  #   block: # これはなんですか
  #     var T : CritBitTree[void]
  #     echo T.len
  #     T.incl "aiueo"
  #     T.incl "aiueoeo"
  #     T.incl "aiueo"
  #     echo T.len
  #   block: # これはTableですね
  #     var T : CritBitTree[char]
  #     echo T.len
  #     T["aiueo"] = 'x'
  #     T["aiueoeo"] = 'o'
  #     T["aiueo"] = 'c'
  #     echo T["aiueo"]
  #     T.excl "aiueo"
  #     echo "aiueo" in T
