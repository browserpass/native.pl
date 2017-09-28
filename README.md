# native.pl

This script enables you to test your [Native Messaging](https://developer.chrome.com/apps/nativeMessaging) setup by allowing you to send arbitrary commands to your executable and to see the response in plain old text.

## Usage
```
native.pl [options] -- host_binary [command]

    Options:
      -h, --help      Display a help message
      -t, --time      Enable output of timing information
      -               Read from stdin instead of argument list
```

Where:
* `host_binary` is a path to your host executable
* `--` separates options from parameters
* `command` is the string that will be sent to your host (**can** contain spaces)

**Note:** When reading from stdin, currently only the first line is interpreted.

## Example

*(Using [browserpass](https://github.com/dannyvankooten/browserpass))*


```
$ ./native.pl ~/browserpass/browserpass {\"action\": \"search\", \"domain\": \"github.com\"}
Request: |  {"action": "search", "domain": "github.com"}
Result:  |  ["github.com\\chrboe"]
Errors:  |  -
```

Or reading from stdin (notice how only the first line is evaluated):

```
$ cat commands.txt
{"action": "search", "domain": "github.com"}
{"action": "search", "domain": "google.com"}
{"action": "search", "domain": "facebook.com"}
{"action": "search", "domain": "twitter.com"}

$ ./native.pl ~/browserpass/browserpass.exe < test.txt
Request: |  {"action": "search", "domain": "google.com"}
Result:  |  ["github.com\\chrboe"]
Errors:  |  -
```