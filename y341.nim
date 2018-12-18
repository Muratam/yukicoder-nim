import sequtils,strutils,unicode
echo stdin.readline().toRunes.mapIt(it == "…".toRunes[0])
  .foldl((if b:(a.res.max(a.pre+1),a.pre+1) else:(a.res,0)),(res:0,pre:0)).res