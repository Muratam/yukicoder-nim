import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

echo get().replace("-","").replace("min","A").count('A')