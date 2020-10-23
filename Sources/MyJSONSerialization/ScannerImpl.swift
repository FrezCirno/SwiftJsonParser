import Foundation

extension Data {
    init(reading input: InputStream) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                // Stream error occured
                throw input.streamError!
            } else if read == 0 {
                // EOF
                break
            }
            append(buffer, count: read)
        }
    }
}

public class ScannerImpl: Scanner {
    private let str: String
    private var pos: String.Index

    public var position: String.Index {
        return pos
    }

    init(string: String) {
        str = string
        pos = str.startIndex
    }

    convenience init(data: Data) throws {
        self.init(string: String(data: data, encoding: .utf8)!)
    }

    convenience init(stream: InputStream) throws {
        try self.init(data: try Data(reading: stream))
    }

    public func hasNext() -> Bool {
        return pos != str.endIndex
    }

    public func next() throws -> Character {
        let oldptr = pos
        pos = str.index(after: pos)
        return str[oldptr]
    }

    public func peek() throws -> Character {
        return str[pos]
    }

    public func back() throws {
        pos = str.index(before: pos)
    }
}
