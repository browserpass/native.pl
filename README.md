# native.pl

This script enables you to test your [Native Messaging](https://developer.chrome.com/apps/nativeMessaging) setup by allowing you to send arbitrary commands to your executable and to the response in plain old text.

## Usage
```
$ ./native.pl [EXECUTABLE] [COMMAND]...
```

Where:
* `EXECUTABLE` is a path to your host executable
* `COMMAND` is the string that will be sent to your host (**can** contain spaces)

## Example

*(Using [browserpass](https://github.com/dannyvankooten/browserpass))*

```
$ ./native.pl ~/browserpass/browserpass {\"action\": \"search\", \"domain\": \"github.com\"}
Request: |  {"action": "search", "domain": "github.com"}
Result:  |  ["github.com\\chrboe"]
Errors:  |  -
Time:    |  0.062s
```