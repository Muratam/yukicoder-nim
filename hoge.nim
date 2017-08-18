
import os except sleep
import posix, parseutils
template daemonize*(pidfile, si, so, se, cd: string,body: stmt): stmt {.immediate.} =
  var
    pid: Pid
    pidFileInner: string
    fi, fo, fe: File
  proc c_signal(sig: cint, handler: proc (a: cint) {.noconv.}) {.importc: "signal", header: "<signal.h>".}
  proc onStop(sig: cint) {.noconv.} =
    close(fi)
    close(fo)
    close(fe)
    removeFile(pidFileInner)
    quit(QuitSuccess)
  if fileExists(pidfile):
    raise newException(IOError, "pidfile " & pidfile & " already exist, daemon already running?")
  pid = fork()
  if pid > 0:
    quit(QuitSuccess)
  if cd != nil and cd != "":
    discard chdir(cd)
  discard setsid()
  discard umask(0)
  pid = fork()
  if pid > 0:
    quit(QuitSuccess)
  flushFile(stdout)
  flushFile(stderr)
  if not si.isNil and si != "":
    fi = open(si, fmRead)
    discard dup2(getFileHandle(fi), getFileHandle(stdin))
  if not so.isNil and so != "":
    fo = open(so, fmAppend)
    discard dup2(getFileHandle(fo), getFileHandle(stdout))
  if not se.isNil and se != "":
    fe = open(se, fmAppend)
    discard dup2(getFileHandle(fe), getFileHandle(stderr))
  pidFileInner = pidfile
  c_signal(SIGINT, onStop)
  c_signal(SIGTERM, onStop)
  c_signal(SIGHUP, onStop)
  c_signal(SIGQUIT, onStop)
  pid = getpid()
  writeFile(pidfile, $pid)
  body

when isMainModule:
  proc main() =
    var i = 0
    while true:
      i.inc()
      echo i
      discard sleep(1)
  daemonize("/tmp/daemonize.pid", "/dev/null", "/tmp/daemonize.out", "/tmp/daemonize.err", "/"):
    main()