import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
echo get().reversed().join("").replace(">","A").replace("<",">").replace("A","<")