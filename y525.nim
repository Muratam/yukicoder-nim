import sequtils,strutils,algorithm,math,sugar,macros,strformat
import times
template get*():string = stdin.readLine().strip()

let f = initTimeFormat("HH:mm")
let s = get().parse(f) + 5.minutes
echo s.format(f)
