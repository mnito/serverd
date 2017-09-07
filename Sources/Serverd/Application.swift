/* The protocol for using an application with the server */
public protocol Application {
  func accept(client: ConnectionStream)
}
