import times
const f = initTimeFormat("yyyy/MM/dd")
echo (stdin.readLine().parse(f) + 2.days).format(f)