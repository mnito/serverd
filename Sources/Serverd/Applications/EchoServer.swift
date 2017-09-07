/* A basic application example for use with the server */
public class EchoServer: Application {
  var connections: Int64 = 0

  public func accept(client: ConnectionStream) {
    // Write back first 1024 bytes
    let _ = client.write(bytes: client.read(bytes: 1024))
    // Increment connections and output connection number to the server console
    connections += 1
    print("Connection \(connections)")
  }
}
