from sequtils import newSeqWith
proc calcAll() :seq[seq[string]] =
  result = newSeqWith(101,newSeq[string](101))
  for a in 0..100:
    for b in 0..100:
      if a > b: continue
      var res = 0
      for i in a..b:
        if (a+b+i) mod 3 == 0: res += 1
      result[a][b] = $res

const answers = calcAll()
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
var a:int32
var b:int32
scanf("%d %d",addr a,addr b)
printf("%s\n",answers[a][b].cstring)