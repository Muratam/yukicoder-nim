# SAIS で静的な文字列集合への prefix/suffix 検索が可能.
# {S}の結合後の文字列Tとして,|T| = Σ|S| で,
# 構築 O(T) / 列挙・個数 O(PlogT)
# https://tenka1-2016-final-open.contest.atcoder.jp/tasks/tenka1_2016_final_c でverify したい

import "./sais"
import tables,algorithm,sequtils
# ^hoge^fuga^piyo^ という形でjoinして SA-IS に投げている.
type SAISSet = ref object
  SA: SuffixArray
  strs: seq[string]
  poses: seq[int] # ^ の位置
  separator : char
proc newSAISSet(strs:seq[string],separator:char = '^'): SAISSet =
  new(result)
  result.strs = strs
  result.separator = separator # 含まれない文字列
  var strLenSum = 1
  for i in 0..<strs.len:
    strLenSum += strs[i].len + 1
  var S = newSeq[char](strLenSum)
  var currentPos = 0
  result.poses = newSeq[int](strs.len)
  for i in 0..<strs.len:
    S[currentPos] = separator
    result.poses[i] = currentPos
    currentPos += 1
    for j in 0..<strs[i].len:
      S[currentPos] = strs[i][j]
      currentPos += 1
  S[currentPos] = separator
  result.SA = cast[string](S).newSuffixArray()
proc getString(self:SAISSet,index:int):string =
  var i = self.poses.lowerBound(index) - 1
  if i + 1 < self.poses.len and index >= self.poses[i+1]: i += 1
  return self.strs[i]
# prefixで検索できる. 辞書順.
iterator findIndexWithPrefix(self:SAISSet,prefix:string): int =
  if prefix.len == 0: # 空文字列は一つ増えているので
    var already = false
    for i in self.SA.findIndex(self.separator & prefix):
      if already: yield i
      already = true
  else:
    for i in self.SA.findIndex(self.separator & prefix): yield i
proc findAllIndexWithPrefix(self:SAISSet,prefix:string):seq[int] =
  toSeq(self.findIndexWithPrefix(prefix))
proc getCountWithPrefix(self:SAISSet,prefix:string): int =
  result = self.SA.getCount(self.separator & prefix)
  if prefix.len == 0 : result -= 1
iterator findStringWithPrefix(self:SAISSet,prefix:string): string =
  for i in self.findIndexWithPrefix(prefix):
    yield self.getString(i)
proc findAllStringWithPrefix(self:SAISSet,prefix:string):seq[string] =
  toSeq(self.findStringWithPrefix(prefix))
# suffixでも検索できる. 辞書順.
iterator findIndexWithSuffix(self:SAISSet,suffix:string): int =
  if suffix.len == 0: # 空文字列は一つ増えているので
    var already = false
    for i in self.SA.findIndex(suffix & self.separator):
      if already:
        yield i
      already = true
  else:
    for i in self.SA.findIndex(suffix & self.separator): yield i
proc findAllIndexWithSuffix(self:SAISSet,suffix:string):seq[int] =
  toSeq(self.findIndexWithSuffix(suffix))
iterator findStringWithSuffix(self:SAISSet,suffix:string): string =
  for i in self.findIndexWithSuffix(suffix): yield self.getString(i)
proc findAllStringWithSuffix(self:SAISSet,suffix:string):seq[string] =
  toSeq(self.findStringWithSuffix(suffix))
# 集合内の全ての部分文字列から検索もできる.
iterator find(self:SAISSet,pattern:string): tuple[index,pos:int] =
  for index in self.SA.findIndex(pattern):
    var i = self.poses.lowerBound(index) - 1
    if i + 1 < self.poses.len and index >= self.poses[i+1]: i += 1
    yield (i,index - self.poses[i] - 1)
proc getCount(self:SAISSet,pattern:string): int = self.SA.getCount(pattern)

when isMainModule:
  import unittest
  import sequtils
  test "SAIS set":
    let saisset = newSAISSet(@["ab","bc","ca","abc","abbb","ab","",""])
    check: saisset.findAllIndexWithPrefix("ab") == @[18, 0, 13, 9]
    check: saisset.getCountWithPrefix("ab") == 4
    check: saisset.findAllStringWithPrefix("ab") == @["ab", "ab", "abbb", "abc"]
    # echo saisset.SA.getAllSuffixArrayString()
    echo saisset.findAllIndexWithSuffix("b")
    check: saisset.findAllStringWithPrefix("") == @["","","ab","ab","abbb","abc", "bc", "ca"]
    check: saisset.findAllStringWithSuffix("b") == @[ "ab", "abbb", "ab"]
    check: saisset.SA.S == "^ab^bc^ca^abc^abbb^ab^^^"
    check: saisset.getCountWithPrefix("") == 8
    check: saisset.getCountWithPrefix("ab") == 4
    check: toSeq(saisset.find("c")) == @[(3,2),(1,1),(2,0)]
    check: toSeq(saisset.find("b")) == @[(5,1),(4,3),(0,1),(4,2),(4,1),(3,1),(1,0)]
    check: saisset.getCount("c") == 3
