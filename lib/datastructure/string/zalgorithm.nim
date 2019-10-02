# 最長共通接頭辞 : Z-Algorithm
# O(S)で, S と S[i:] の最長共通接頭辞の長さを作成
proc getLCPByZAlgorithm(S:string): seq[int] =
  result = newSeq[int](S.len)
  var j = 0
  for i in 1..<S.len:
    if i + result[i-j] < j + result[j]:
      result[i] = result[i-j]
    else:
      var k = 0.max(j + result[j] - i)
      while i + k < S.len() and S[k] == S[i + k]: k += 1
      result[i] = k
      j = i
  result[0] = S.len

# 検索パターンPに対して P$S を作って検索
proc zFindIndex(target:string,pattern:string,last:char = '$'): int =
  let found = getLCPByZAlgorithm(pattern & last & target)
  for i in pattern.len+1..<pattern.len+target.len+1:
    if found[i] == pattern.len: return i - pattern.len - 1
  return -1

when isMainModule:
  import unittest
  test "Z Algorithm":
    check: "aaabaaaab".getLCPByZAlgorithm() == @[9,2,1,0,3,4,2,1,0]
    check: "aaaaiuaa".zFindIndex("aiu") == 3
