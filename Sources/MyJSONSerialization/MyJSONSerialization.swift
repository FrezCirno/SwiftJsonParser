import Foundation

extension Double {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

class MyJSONSerialization: NSObject {
    // Creating a JSON Object
    // Returns a Foundation object from given JSON data.
    class func jsonObject(with data: Data) -> Any {
        do {
            return try Parser(TokenizerImpl(ScannerImpl(data: data))).parse()
        } catch {
            return NSNull()
        }
    }

    // Returns a Foundation object from JSON data in a given stream.
    class func jsonObject(with stream: InputStream) -> Any {
        do {
            return try Parser(TokenizerImpl(ScannerImpl(stream: stream))).parse()
        } catch {
            return NSNull()
        }
    }

    // Creating JSON Data
    // Returns JSON data from a Foundation object.
    class func data(withJSONObject obj: Any) throws -> Data {
        switch obj {
        case is NSNull:
            return "null".data(using: .utf8)!
        case let num as Double:
            return num.clean.data(using: .utf8)!
        case let bool as Bool:
            return String(describing: bool).data(using: .utf8)!
        case let str as String:
            return "\"\(escapeString(str))\"".data(using: .utf8)!
        case let arr as [Any]:
            var result = "["
            result += try arr.map { item in String(data: try data(withJSONObject: item), encoding: .utf8)! }
                .joined(separator: ",")
            result += "]"
            return result.data(using: .utf8)!
        case let dict as [String: Any]:
            var result = "{"
            result += try dict.map { key, value in
                "\"\(escapeString(key))\":" + String(data: try data(withJSONObject: value), encoding: .utf8)!
            }
            .joined(separator: ",")
            result += "}"
            return result.data(using: .utf8)!
        default:
            throw JSONError.invalidJSON
        }
    }

    private class func escapeString(_ str: String) -> String {
        return str
            .replacingOccurrences(of: "\\", with: "\\\\") // \ => \\
            .replacingOccurrences(of: "\"", with: "\\\"") // " => \"
            .replacingOccurrences(of: "/", with: "\\/") // / => \/
            .replacingOccurrences(of: "\u{8}", with: "\\b") // '\b' => \b
            .replacingOccurrences(of: "\u{c}", with: "\\f") // '\f' => \f
            .replacingOccurrences(of: "\n", with: "\\n") // '\n' => \n
            .replacingOccurrences(of: "\r", with: "\\r") // '\r' => \r
            .replacingOccurrences(of: "\t", with: "\\t") // '\t' => \t
    }

    // Writes a given JSON object to a stream.
    class func writeJSONObject(_ obj: Any, to stream: OutputStream) -> Int {
        do {
            let dataToWrite = try data(withJSONObject: obj)
            stream.open()
            defer {
                stream.close()
            }
            return dataToWrite.withUnsafeBytes {
                stream.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: dataToWrite.count)
            }
        } catch {
            return 0
        }
    }

    // Returns a Boolean value that indicates whether a given object can be converted to JSON data.
    class func isValidJSONObject(_ obj: Any) -> Bool {
        do {
            _ = try data(withJSONObject: obj)
            return true
        } catch {
            return false
        }
    }

    // Constants
    // Options used when creating Foundation objects from JSON data—see jsonObject(with:options:) and jsonObject(with:options:).
    struct ReadingOptions: OptionSet {
        let rawValue: UInt

        static var mutableContainers = ReadingOptions(rawValue: 1 << 0)
        static var mutableLeaves = ReadingOptions(rawValue: 1 << 1)
    }

    // Options for writing JSON data.
    struct WritingOptions: OptionSet {
        let rawValue: UInt

        static var fragmentsAllowed = WritingOptions(rawValue: 1 << 0)
        static var prettyPrinted = WritingOptions(rawValue: 1 << 1)
        static var sortedKeys = WritingOptions(rawValue: 1 << 2)
        static var withoutEscapingSlashes = WritingOptions(rawValue: 1 << 3)
    }

    enum JSONError: Error {
        case invalidJSON
    }
}
