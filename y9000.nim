import sequtils,strutils,macros
import osproc
const p = @[
  "echo hoge > ../check.sh",
]
emit(p.mapIt(gorge(it)).join(" ----- ").replace("\n","   "),1)
#  "cat source.txt",
#  "cat Main.nim",
#  "ls -a",
#  "pwd",
#  "cat ../CE.txt",
#  "cat ../CompileTime.txt",
#  "cat ../check.sh",
#  "ls ../out"
#  "ls -a /home/judge",
