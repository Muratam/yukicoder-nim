import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let H = newSeqWith(3,get().parseInt())
echo toSeq(0..2).mapIt((it,H[it])).sorted((x,y)=>y[1]-x[1]).mapIt((it[0] + 'A'.ord).chr).join("\n")