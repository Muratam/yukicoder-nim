proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
var a,b:int
scanf("%d %d",addr a,addr b)
printf("%d",a-(-b))