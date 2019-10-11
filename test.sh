#! /bin/bash
rmnimcache(){ [[ -d ./nimcache ]] && rm -rf ./nimcache; }
allresult=0

trytest(){
  rmnimcache
  dirs=`ls -l | grep drwxr | awk '{print $9}'`
  for dir in $dirs; do
    [[ $dir == "garbage" ]] && continue
    echo "test : [" $dir "]"
    cd $dir
    rmnimcache
    nims=`ls *.nim`
    for nim in $nims; do
      nim cpp -r -d:release --hints:off --verbosity:0 --nimcache:./nimcache "--warning[SmallLshouldNotBeUsed]:off" $nim
      testresult=$?
      [[ $testresult != 0 ]] && allresult=$testresult
    done
    rm `find . -maxdepth 1 -perm -111 -type f | tr "\n" " "`
    rmnimcache
    cd ..
  done
  cd ..
}

cd lib/datastructure
trytest
cd lib
trytest

exit $allresult
