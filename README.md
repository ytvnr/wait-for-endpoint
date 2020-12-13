# wait-for-endpoint

![example workflow file path](https://github.com/ytvnr/wait-for-endpoint/workflows/Sh%20analysis/badge.svg)

`wait-for-endpoint` is a sh script that you can use to wait for an **HTTP** endpoint to be available.
It can be useful in order to synchronize the spin-up of interdependent services.

This script is inspired by [wait-for-it](https://github.com/vishnubob/wait-for-it) and [wait-for](https://github.com/eficode/wait-for) that both wait for a _TCP_ port to be open on a host.

`wait-for-endpoint` deals with **HTTP** endpoints and checks the `http` status of the response returned by the enpoint.

`wait-for-endpoint.sh` is useful when you want to test an endpoint to check the functional availability of a service.
You can use it in the context of linked docker containers, CI workflows, etc.

⚠️ You will need to have [cURL](https://github.com/curl/curl) available.

## Usage

```text
sh ./wait-for-endpoint.sh host(:port)/path [-q] [-d delay] [-i interval] [-t timeout] [-s status] [-- command args]
  -q | --quiet                                  Do not output any status messages.
  -d DELAY | --delay=delay                      Delay before first attempt in seconds. Default is 0s.
  -i INTERVAL | --interval=interval             Interval between attemps in seconds. Default is 5s.
  -t TIMEOUT | --timeout=timeout                Timeout in seconds, zero for no timeout. Default is 30s.
  -s STATUS | --status=status                   Status expected from request to be valid. Default is 200.
  -m MAX_TIME | --max-time=max-time             Maximum time in seconds that you allow curl operation to take. Default is 2s.
  -h HTTP_METHOD | --http-method=http-method    HTTP method to use for the request. Default is GET.
  -- COMMAND ARGS                               Execute command with args after the test finishes.
```

## Options

| Short 	| Long       	        | Description   	                                            | Default value 	|
|-------	|------------	        |---------------	                                            |---------------	|
| -q    	| --quiet    	        | Do not output any status messages 	                        | 0             	|
| -d    	| --delay    	        | Delay before first attempt in seconds                         | 0s               	|
| -i      	| --interval            | Interval between attemps in seconds                           | 5s              	|
| -t      	| --timeout             | Timeout in seconds, zero for no timeout                       | 30s              	|
| -s      	| --status              | Status expected from request to be valid                      | 200              	|
| -m      	| --max-time            | Maximum time in seconds that you allow curl operation to take | 2s              	|
| -h      	| --http-status         | HTTP method to use for the request                            | GET              	|
|       	| -- COMMAND ARGS       | Execute command with args after the test finishes             |               	|

## Examples

For example, let's test if we can access port 80 on `www.google.com`,
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

In combination to timeout, you can configure the interval (with the `-i` or `--interval=`) between request attempts. The default value is 5s.
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

## Testing

Testing is done using [bats](https://github.com/sstephenson/bats).

### Run tests locally

Run `npm i` to install dependency

Then, run `npm run test` to run test suite contained in `wait-for-endpoint.bats`

⚠️ Tests suite asserting on output message are run with `--quiet` option. This allows to not log execution information and just have the real output.