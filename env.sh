[[ $1 == "" ]] && exit 1
[[ -f $1 ]] && exit 1
cp ~/codes/nim/userimport/templates.nim "./y$1.nim"
code "./y$1.nim"