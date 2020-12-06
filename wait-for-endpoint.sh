#!bin/sh

TIMEOUT=30
INTERVAL=5
DELAY=0
STATUS=200
QUIET=0

echoerr() {
  if [ "$QUIET" -ne 1 ]; then printf "\033[0;31m%s \033[0m\n" "$*" 1>&2; fi
}

echosuccess() {
  if [ "$QUIET" -ne 1 ]; then printf "\033[0;32m%s \033[0m\n" "$*" 1>&2; fi
}

echoinfo() {
  if [ "$QUIET" -ne 1 ]; then printf "%s\n" "$*" 1>&2; fi
}

usage() {
  exitcode="$1"
  cat << USAGE >&2
Usage:
  $cmdname host(:port)/path [-q] [-d delay] [-i interval] [-t timeout] [-s status] [-- command args]
  -q | --quiet                        Do not output any status messages.
  -d DELAY | --delay=delay            Delay before first attempt in seconds. Default is 0s.
  -i INTERVAL | --interval=interval   Interval between attemps in seconds. Default is 5s.
  -t TIMEOUT | --timeout=timeout      Timeout in seconds, zero for no timeout. Default is 30s.
  -s STATUS | --status=status         Status expected from request to be valid. Default is 200.
  -- COMMAND ARGS                     Execute command with args after the test finishes.
USAGE
  exit "$exitcode";
}

wait_for_endpoint() {
  command="$*";

  if [ $DELAY -gt 0 ] ; then
    echoinfo "Waiting $DELAY seconds before first attempt..."
    sleep $DELAY;
  fi

  for i in `seq 0 $INTERVAL $TIMEOUT` ; do
    RESULT=$(curl -s -m 2 -o /dev/null -w "%{http_code}" --location $ENDPOINT );

    if [ $TIMEOUT -gt 0 ] ; then
      echoinfo "Attempt $((i / INTERVAL)) of $((TIMEOUT / INTERVAL))."
    fi
    if [ $RESULT -eq $STATUS ] ; then
      if [ -n "$command" ] ; then
        echosuccess "Connection to $ENDPOINT succeeded with status: $STATUS. Executing command...";
        exec $command;
      fi
      exit 0;
    fi
    echoinfo "Retry in $INTERVAL seconds."
    sleep $INTERVAL;
  done
  echoerr "Operation timed out" >&2;
  exit 1;
}

while [ $# -gt 0 ]
do
  case "$1" in
    *.*)
    ENDPOINT=$(printf "%s\n" "$1")
    shift 1
    ;;
    *:*)
    ENDPOINT=$(printf "%s\n" "$1")
    shift 1
    ;;
    -q | --quiet)
    QUIET=1
    shift 1
    ;;
    -d)
    DELAY="$2"
    if [ "$DELAY" = "" ]; then break; fi
    shift 2
    ;;
    --delay=*)
    DELAY="${1#*=}"
    shift 1
    ;;
    --)
    shift
    break
    ;;
    -i)
    INTERVAL="$2"
    if [ "$INTERVAL" = "" ]; then break; fi
    shift 2
    ;;
    --interval=*)
    INTERVAL="${1#*=}"
    shift 1
    ;;
    --)
    shift
    break
    ;;
    -t)
    TIMEOUT="$2"
    if [ "$TIMEOUT" = "" ]; then break; fi
    shift 2
    ;;
    --timeout=*)
    TIMEOUT="${1#*=}"
    shift 1
    ;;
    -s)
    STATUS="$2"
    if [ "$STATUS" = "" ]; then break; fi
    shift 2
    ;;
    --status=*)
    STATUS="${1#*=}"
    shift 1
    ;;
    --)
    shift
    break
    ;;
    --)
    shift
    break
    ;;
    --help)
    usage 0
    ;;
    *)
    echoerr "Unknown argument: $1"
    usage 1
    ;;
  esac
done

if [ "$ENDPOINT" == "" ]; then
  echoerr "Error: you need to provide a endpoint to test."
  usage 2
fi

wait_for_endpoint "$@"