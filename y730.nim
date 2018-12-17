import sequtils,tables
echo if toSeq(stdin.readLine.toCountTable.values).max() == 1: "YES" else: "NO"