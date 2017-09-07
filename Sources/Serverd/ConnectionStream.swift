#if os(Linux)
  import Glibc
  let stream_write = Glibc.write
  let stream_read = Glibc.read
  let stream_close = Glibc.close
#else
  import Darwin
  let stream_write = Darwin.write
  let stream_read = Darwin.read
  let stream_close = Darwin.close
#endif

/* Helper for reading to and writing from a file descriptor */
public class ConnectionStream {
  private let fd: Int32

  public init(fd: Int32) {
    self.fd = fd
  }

  public func write(string: String) {
    let _ = stream_write(self.fd, string, string.utf8.count)
  }

  public func write(bytes: [UInt8]) {
    let _ = stream_write(self.fd, bytes, bytes.count)
  }

  public func read(characters: Int) -> String {
    let bufferCapacity = characters + 1
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferCapacity)
    defer {
      buffer.deallocate(capacity: bufferCapacity)
    }

    let bytesRead = stream_read(self.fd, buffer, characters)
    buffer[bytesRead] = 0

    return String(cString: buffer)
  }

  public func read(bytes: Int) -> [UInt8] {
    var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bytes)
    defer {
      buffer.deallocate(capacity: bytes)
    }

    return [UInt8](UnsafeBufferPointer(
      start: buffer,
      count: stream_read(self.fd, buffer, bytes)
    ))
  }

  public func close() {
    guard stream_close(self.fd) > -1 else {
      return
    }
  }

  deinit {
    self.close()
  }
}
