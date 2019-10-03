#! /bin/bash
rmnimcache(){ [[ -d ./nimcache ]] && rm -rf ./nimcache; }
allresult=0

cd lib
rmnimcache
dirs=`ls -l | grep d | awk '{print $9}'`
for dir in $dirs; do
  [[ $dir == "garbage" ]] && continue
  echo "test : [" $dir "]"
  cd $dir
  rmnimcache
  nims=`ls *.nim`
  for nim in $nims; do
    nim cpp -r --hints:off --verbosity:0 --nimcache:./nimcache "--warning[SmallLshouldNotBeUsed]:off" $nim
    testresult=$?
    [[ $testresult != 0 ]] && allresult=$testresult
  done
  rm `find . -maxdepth 1 -perm -111 -type f | tr "\n" " "`
  rmnimcache
  cd ..
done

exit $allresult
