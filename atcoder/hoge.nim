import future,times,sequtils
echo cpuTime()
echo lc[3 * i | (i <- 0..1_0000000, i!=49), int][1]
echo cpuTime()
echo toSeq(0..1_0000000).filterIt(it != 49).mapIt(it * 3)[1]
echo cpuTime()
