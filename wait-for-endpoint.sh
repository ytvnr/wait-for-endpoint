#!bin/sh

TIMEOUT=30
INTERVAL=5
STATUS=200
QUIET=0


echoerr() {
  if [ "$QUIET" -ne 1 ]; then printf "\033[0;31m %s \033[0m\n" "$*" 1>&2; fi
}

echosuccess() {
  if [ "$QUIET" -ne 1 ]; then printf "\033[0;32m %s \033[0m\n" "$*" 1>&2; fi
}

usage() {
  exitcode="$1"
  cat << USAGE >&2
Usage:
  $cmdname host(:port)/path [-t timeout] [-s status] [-- command args]
  -q | --quiet                        Do not output any status messages
  -t TIMEOUT | --timeout=timeout      Timeout in seconds, zero for no timeout. Default is 30s.
  -s STATUS | --status=status         Status expected from request to be valid. Default is 200.
  -- COMMAND ARGS                     Execute command with args after the test finishes
USAGE
  exit "$exitcode"
}

wait_for_endpoint() {
  command="$*"

  for i in `seq 0 $INTERVAL $TIMEOUT` ; do
    RESULT=$(curl -s -o /dev/null -w "%{http_code}" --location $ENDPOINT );
    echo "Attempt $((i / INTERVAL)) of $((TIMEOUT / INTERVAL))"

    if [ $RESULT -eq $STATUS ] ; then
      if [ -n "$command" ] ; then
        echosuccess "Endpoint answered with status $STATUS, executing command..."
        exec $command
      fi
      exit 0
    fi
    sleep $INTERVAL
  done
  echoerr "Operation timed out" >&2
  exit 1
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
    -t)
    TIMEOUT="$2"
    if [ "$TIMEOUT" = "" ]; then break; fi
    shift 2
    ;;
    --timeout=*)
    TIMEOUT="${1#*=}"
    shift 1
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