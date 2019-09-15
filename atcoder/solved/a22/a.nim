import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues

let S = stdin.readLine()
if S == "Sunny" :
  echo "Cloudy"
elif S == "Cloudy":
  echo "Rainy"
else:
  echo "Sunny"
