# wait-for-endpoint

https://github.com/ytvnr/wait-for-endpoint/workflows/Sh%20analysis/badge.svg

./wait-for-endpoint is a sh script to wait for an HTTP endpoint to be available.
It is useful for synchronizing the spin-up of interdependant services.

This script is inspired by [wait-for-it](https://github.com/vishnubob/wait-for-it) and [wait-for](https://github.com/eficode/wait-for).
They wait for a service to be up by testing a host and TCP port.

`wait-for-endpoint.sh` is useful when you want to test a endpoint to check the functional availability of a service.
You can use for linked docker containers, CI workflows, etc.

⚠️ You will need to install `cURL`.

## Usage

```text
sh ./wait-for-endpoint.sh host(:port)/path [-q] [-d delay] [-i interval] [-t timeout] [-s status] [-- command args]
  -q | --quiet                        Do not output any status messages.
  -d DELAY | --delay=delay            Delay before first attempt in seconds. Default is 0s.
  -i INTERVAL | --interval=interval   Interval between attemps in seconds. Default is 5s.
  -t TIMEOUT | --timeout=timeout      Timeout in seconds, zero for no timeout. Default is 30s.
  -s STATUS | --status=status         Status expected from request to be valid. Default is 200.
  -- COMMAND ARGS                     Execute command with args after the test finishes.
```

## Options

| Short 	| Long       	    | Description   	                                | Default value 	|
|-------	|------------	    |---------------	                                |---------------	|
| -q    	| --quiet    	    | Do not output any status messages 	            | 0             	|
| -d    	| --delay    	    | Delay before first attempt in seconds             | 0s               	|
| -i      	| --interval        | Interval between attemps in seconds               | 5s              	|
| -t      	| --timeout         | Timeout in seconds, zero for no timeout           | 30s              	|
| -s      	| --status          | Status expected from request to be valid          | 200              	|
|       	| -- COMMAND ARGS   | Execute command with args after the test finishes |               	|

## Examples

For example, let's test to see if we can access port 80 on `www.google.com`,
and if it is available, echo the message `google is up`.

```text
$ sh ./wait-for-endpoint.sh www.google.com:80 -- echo "google is up"
Attempt 0 of 6.
Connection to google.fr succeeded with status: 200. Executing command... 
google is up
```

You can set your own timeout with the `-t` or `--timeout=` option.  Setting
the timeout value to 0 will disable the timeout:

```text
$ sh ./wait-for-endpoint.sh -t 0 www.google.com:80 -- echo "google is up"
Connection to google.fr succeeded with status: 200. Executing command... 
google is up
```

In combination to timeout, you can set your interval (with the `-i` or `--interval=`) between request attempts. Default is 5s.
In the following example, we will choose an interval of 3 seconds, and a timeout of 15 seconds, which means 5 attempts.

Let's try with an unavailable endpoint.

```text
$ sh ./wait-for-endpoint.sh google.fr/api -t 15 -i 3 -- echo "google is up"
Attempt 0 of 5.
Retry in 3 seconds.
Attempt 1 of 5.
Retry in 3 seconds.
Attempt 2 of 5.
Retry in 3 seconds.
Attempt 3 of 5.
Retry in 3 seconds.
Attempt 4 of 5.
Retry in 3 seconds.
Attempt 5 of 5.
Retry in 3 seconds.
Operation timed out 
```

The subcommand will be executed if the service responds with the desired status. You can choose another status with the `-s` or `--status=`

If you don't want to execute a subcommand, leave off the `--` argument.  This
way, you can test the exit condition of `wait-for-endpoint.sh` in your own scripts,
and determine how to proceed:

```text
$ sh ./wait-for-endpoint.sh www.google.com
Attempt 0 of 6.
$ echo $?
0
$ sh ./wait-for-endpoint.sh www.google.com:81
Retry in 5 seconds.
Operation timed out 
$ echo $?
1
```