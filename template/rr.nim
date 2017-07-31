import templates
import userimport

main:
  5.times:
    echo "aa"
  withFile(f, "members.txt","r"):
    echo f.readAll().split("\n")