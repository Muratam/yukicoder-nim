# SAIS を使って

# https://tenka1-2016-final-open.contest.atcoder.jp/tasks/tenka1_2016_final_c でverify したい
# ^hoge^fuga^piyo^ という形でjoinすることで色々嬉しい.
# prefix/suffix での検索ができる. 個数もlogNで出せる.
# SA-ISなので文字列集合の部分文字列に対しての操作もできる.
import "./sais"
import tables,algorithm,sequtils
type SAISSet = ref object
  SA: SuffixArray
  strs: seq[string]
  indexMap:Table[int,int] # ^ の位置からstrsのindex
  separator : char
proc newSAISSet(strs:seq[string],separator:char = '^'): SAISSet =
  new(result)
  result.strs = strs
  result.indexMap = initTable[int,int]()
  result.separator = separator # 含まれない文字列
  var strLenSum = 1
  for i in 0..<strs.len:
    strLenSum += strs[i].len + 1
  var S = newSeq[char](strLenSum)
  var currentPos = 0
  for i in 0..<strs.len:
    S[currentPos] = separator
    result.indexMap[currentPos] = i
    currentPos += 1
    for j in 0..<strs[i].len:
      S[currentPos] = strs[i][j]
      currentPos += 1
  S[currentPos] = separator
  result.SA = cast[string](S).newSuffixArray()
proc getString(self:SAISSet,index:int):string =
  if index in self.indexMap:
    return self.strs[self.indexMap[index]]
  # WARN: 無かった場合悲しいね
# prefixで検索できる.
iterator findIndexWithPrefix(self:SAISSet,target:string): int =
  if target.len == 0: # 空文字列は一つ増えているので
    var already = false
    for i in self.SA.findIndex(self.separator & target):
      if already:
        yield i
      already = true
  else:
    for i in self.SA.findIndex(self.separator & target): yield i
proc findAllIndexWithPrefix(self:SAISSet,target:string):seq[int] =
  toSeq(self.findIndexWithPrefix(target)).reversed()
proc findOneIndexWithPrefix(self:SAISSet,target:string): int =
  for i in self.findIndexWithPrefix(target): return i
  return -1
proc getCountWithPrefix(self:SAISSet,target:string): int =
  for _ in self.findIndexWithPrefix(target): result += 1
iterator findMatchedStringWithPrefix(self:SAISSet,target:string): string =
  for i in self.findIndexWithPrefix(target):
    yield self.getString(i)
proc findAllMatchedStringWithPrefix(self:SAISSet,target:string):seq[string] =
  toSeq(self.findMatchedStringWithPrefix(target))
proc findOneMatchedStringWithPrefix(self:SAISSet,target:string):string =
  for s in self.findMatchedStringWithPrefix(target): return s
  return ""
# suffixでも検索できる. でもstringに戻そうとすると...
iterator findIndexWithSuffix(self:SAISSet,target:string): int =
  if target.len == 0: # 空文字列は一つ増えているので
    var already = false
    for i in self.SA.findIndex(target & self.separator):
      if already:
        yield i
      already = true
  else:
    for i in self.SA.findIndex(target & self.separator): yield i
proc findAllIndexWithSuffix(self:SAISSet,target:string):seq[int] =
  toSeq(self.findIndexWithSuffix(target)).reversed()
proc findOneIndexWithSuffix(self:SAISSet,target:string): int =
  for i in self.findIndexWithSuffix(target): return i
  return -1
iterator findMatchedStringWithSuffix(self:SAISSet,target:string): string =
  for i in self.findIndexWithSuffix(target):
    yield self.getString(i)
proc findAllMatchedStringWithSuffix(self:SAISSet,target:string):seq[string] =
  toSeq(self.findMatchedStringWithSuffix(target))
proc findOneMatchedStringWithSuffix(self:SAISSet,target:string):string =
  for s in self.findMatchedStringWithSuffix(target): return s
  return ""


# 空文字の検索結果はバグりやすい
let saisset = newSAISSet(@["ab","bc","ca","abc","abbb","ab","",""])
echo saisset.findAllIndexWithPrefix("ab").mapIt(saisset.getString(it))
echo saisset.getCountWithPrefix("ab")
echo saisset.findAllMatchedStringWithPrefix("ab")
echo saisset.SA.getAllSuffixArrayString()
echo saisset.findAllMatchedStringWithPrefix("")
echo saisset.findAllIndexWithSuffix("b")
echo saisset.indexMap
echo saisset.SA.S
# echo sa4.findAll("cc").mapIt(sa4.getString(it))
