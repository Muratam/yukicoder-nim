import sequtils,algorithm
echo if stdin.readLine().sorted(cmp) == stdin.readLine().sorted(cmp): "YES" else: "NO"