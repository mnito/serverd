import Dispatch

/* This server uses dispatch queues to handle many requests and connections */
public class Server {
  let host: String
  let socket: Socket
  let app: Application

  public convenience init(app: Application) {
    self.init(host: "::1", port: 8080, app: app)
  }

  public init(host: String, port: Int, app: Application) {
    self.host = host
    self.socket = Socket(port: port)
    self.app = app
  }

  public func start() {
    // Start listening on socket
    self.socket.listen()

    // This concurrent queue will handle connections
    let connection = DispatchQueue(label: "connection", attributes: .concurrent)

    let source = DispatchSource.makeReadSource(
      // The socket listener is used as a read source
      fileDescriptor: self.socket.listener,
      queue: connection
    )

    // This block will execute every time a connection is made
    source.setEventHandler {
      let fd = self.socket.accept()
      guard fd > 0 else {
        return
      }
      let client = ConnectionStream(fd: fd)
      self.app.accept(client: client)
    }
    source.activate()

    // Loop forever
    dispatchMain()
  }

  public func shutdown() {
    self.socket.close()
  }

  deinit {
    self.shutdown()
  }
}
