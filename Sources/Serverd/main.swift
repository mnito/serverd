print("Starting server")

let port = 8080

print("Listening on port " + String(describing: port))

let app = EchoServer()
let s = Server(host: "::1", port: port, app: app)
s.start()
