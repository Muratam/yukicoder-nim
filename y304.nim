
import osproc,strutils,sequtils,os
for i in 577..<1000000:
  let code =  """
  #include <stdio.h>
  #include <stdlib.h>
  #include <time.h>
  char str[12];
  int used[999] = {};
  int main() {
    srand(""" & ($i) & """);
    for (int n = 0;n < 200;n++) {
      int i = 0;
      while (used[i]) i = rand() % 1000;
      used[i] = 1;
      printf("%d\n", i);
    }
  }
  """
  let f = open("hoge.c",fmWrite)
  f.write code
  f.close()
  discard execProcess("/usr/bin/gcc hoge.c")
  let p = execProcess("./a.out").strip().split("\n").map(parseInt)
  let oks = [123,999,114,514,99]
  if oks.allIt(it in p) :
     echo i,"::ok"
     quit(0)
  echo i,":",oks.filterIt(it in p).len()
