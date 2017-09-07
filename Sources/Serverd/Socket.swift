#if os(Linux)
  import Glibc
  let socket_listen = Glibc.listen
  let socket_accept = Glibc.accept
  let SIN6_FAMILY = UInt16(Glibc.AF_INET6)
#else
  import Darwin
  let socket_listen = Darwin.listen
  let socket_accept = Darwin.accept
  let SIN6_FAMILY = UInt8(Darwin.AF_INET6)
#endif

#if swift(>=3.1.1)
  let SOCKET_SOCK_STREAM = Int32(SOCK_STREAM.rawValue)
#else
  let SOCKET_SOCK_STREAM = Int32(SOCK_STREAM)
#endif

internal struct Address {
  var addr: sockaddr_in6 = sockaddr_in6()
  var ptr: UnsafeMutablePointer<sockaddr>? = nil
  var length: UInt32 = 32
}

/* Server socket wrapper class */
public class Socket {
  public let port: Int
  public var ipv6Only = false {
    willSet(newValue) {
      var on = newValue ? 1 : 0
      setsockopt(self.listener, Int32(IPPROTO_IPV6), IPV6_V6ONLY, &on, UInt32(MemoryLayout<UnsafeRawPointer>.stride))
    }
  }

  public let listener: Int32 = socket(AF_INET6, SOCKET_SOCK_STREAM, 0)
  private var address: Address = Address()
  public let connectionLimit: Int32 = SOMAXCONN

  public init(port: Int) {
    self.port = port
    self.address.addr.sin6_family = SIN6_FAMILY
    self.address.addr.sin6_addr = in6addr_any
    self.address.addr.sin6_port = UInt16(self.port).bigEndian
  }

  public func listen() {
    var addr = self.address.addr
    let _ = withUnsafeMutablePointer(to: &addr) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        bind(self.listener, UnsafeMutablePointer<sockaddr>($0), socklen_t(MemoryLayout<sockaddr_in6>.stride))
        let _ = socket_listen(self.listener, self.connectionLimit)
        self.address.ptr = UnsafeMutablePointer<sockaddr>($0)
        self.address.length = socklen_t(MemoryLayout<sockaddr_in6>.stride)
      }
    }
  }

  public func accept() -> Int32 {
    return socket_accept(self.listener, self.address.ptr!, &self.address.length)
  }

  public func close() {
    let _ = shutdown(self.listener, 2)
  }

  deinit {
    self.close()
  }
}
