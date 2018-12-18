import strutils,strformat
let d = stdin.readLine.parseInt()
echo fmt"{d * 108 div 100}.{d * 108 mod 100:02d}"