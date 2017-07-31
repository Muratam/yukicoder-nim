[[ $1 == "" ]] && exit 1
[[ -d $1 ]] && exit 1
mkdir $1
cd $1
cp ~/codes/nim/userimport/templates.nim ./code.nim
code ./code.nim