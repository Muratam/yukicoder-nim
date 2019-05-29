import sequtils,unicode
let S = stdin.readLine()
var ans = newSeqWith(104,newSeq[string]())
var pre = ""
var wlen = 0
var preIsW = false
for s in S.utf8:
  if s != "ｗ":
    if preIsW : pre = ""
    pre &= s
    wlen = 0
    preIsW = false
    continue
  wlen += 1
  if pre != "" : ans[wlen] &= pre
  preIsW = true
for i in (ans.len-1).countdown(0):
  if ans[i].len == 0 : continue
  for s in ans[i]: echo s
  quit(0)
echo ""