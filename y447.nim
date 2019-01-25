import sequtils,algorithm,math,tables,sugar
import sets,intsets,queues,heapqueue,bitops,strutils
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a:int32) =
  template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
  template put(n:int32) = putchar_unlocked("0123456789"[n])
  if a < 10:
    put(a)
    return
  if a < 100:
    let a1 = a.div10
    (put(a1);put(a-a1*10))
    return
  if a < 1000:
    let a1 = a.div10
    let a2 = a1.div10
    put(a2)
    put(a1-a2*10)
    put(a-a1*10)
    return
  if a < 10000:
    let a1 = a.div10
    let a2 = a1.div10
    let a3 = a2.div10
    put(a3)
    put(a2-a3*10)
    put(a1-a2*10)
    put(a-a1*10)
    return
  if a < 100000:
    let a1 = a.div10
    let a2 = a1.div10
    let a3 = a2.div10
    let a4 = a3.div10
    put(a4)
    put(a3-a2*10)
    put(a2-a3*10)
    put(a1-a2*10)
    put(a-a1*10)
    return

proc printInt(a:int) = printInt(a.int32)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
proc scanName(): string =
  result = ""
  while true:
    let k = getchar_unlocked()
    if k == ' ': return
    result &= k


proc calcScore(star:int,ac:int):int = 50 * star + (50 * star) * 5 div (4 + ac)

let n = scan()
let L = newSeqWith(n,scan())
var AC = newSeqWith(n,1)
type User = ref object
  name: string
  scores : seq[int]
  lastSubmit: int
  sum:int
proc newUser(name:string): User =
  new(result)
  result.name = name
  result.scores = newSeq[int](n)
proc update(self:var User,pID:int,score:int,lastSumbit:int) =
  self.sum += score
  self.lastSubmit = lastSumbit
  self.scores[pID] = score
var maxID = 0
var userIDs = newTable[string,int]()
var users = newSeq[User]()
for i in 0..<scan():
  let name = scanName()
  let pID = getchar_unlocked().ord - 'A'.ord
  discard getchar_unlocked()
  let score = calcScore(L[pID],AC[pID])
  AC[pID] += 1
  if name notin userIDs:
    let id = maxID
    userIDs[name] = id
    maxID += 1
    users &= newUser(name)
  users[userIDs[name]].update(pID,score,i)
users.sort(proc(x,y:User):int =
  if x.sum != y.sum : y.sum - x.sum
  else: x.lastSubmit - y.lastSubmit
)
for i,u in users:
  printInt(i+1)
  putchar_unlocked(' ')
  printf(u.name.cstring)
  putchar_unlocked(' ')
  for score in u.scores:
    printInt(score)
    putchar_unlocked(' ')
  printInt(u.sum)
  putchar_unlocked('\n')
