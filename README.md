# RadoSmallServer

Very tiny and minimalistic HTTP server based on [SwiftNIO](https://github.com/apple/swift-nio).

Use it as follows: 
```
    try RadoSmallServer(path: "/ping", method: .GET, type: .text, host: "127.0.0.1", port: 8080) {
        return "OK".data(using: .utf8)!
    }.start()
``` 

