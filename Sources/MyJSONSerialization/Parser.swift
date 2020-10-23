import Foundation

public class Parser {
    private let tokenList: Tokenizer

    init(_ tokenList: Tokenizer) {
        self.tokenList = tokenList
    }

    public func parse() throws -> Any {
        while tokenList.hasNext() {
            let token = try tokenList.peek()
            switch token {
            case .BEGIN_OBJECT:
                return try parseObject()
            case .BEGIN_ARRAY:
                return try parseArray()
            case let .STRING(value):
                _ = try tokenList.next()
                return value
            case let .NUMBER(value):
                _ = try tokenList.next()
                return value
            case let .BOOLEAN(value):
                _ = try tokenList.next()
                return value
            case .NULL:
                _ = try tokenList.next()
                return NSNull()
            default:
                throw JsonParseException.InvalidToken
            }
        }
        throw JsonParseException.ExpectToken
    }

    public func parseObject() throws -> [NSString: Any] {
        var kvpairs = [NSString: Any]()

        while tokenList.hasNext() {
            switch try tokenList.next() {
            case .BEGIN_OBJECT, .SEP_COMMA:
                if try tokenList.hasNext() && tokenList.peek() != .SEP_COMMA && tokenList.peek() != .END_OBJECT {
                    let token = try tokenList.next()
                    guard case let .STRING(key) = token else {
                        throw JsonParseException.ExpectString
                    }
                    guard case .SEP_COLON = try tokenList.next() else {
                        throw JsonParseException.ExpectColon
                    }
                    kvpairs[NSString(string: key)] = try parse()
                }
            case .END_OBJECT:
                return kvpairs
            default:
                throw JsonParseException.InvalidToken
            }
        }
        throw JsonParseException.ExpectToken
    }

    public func parseArray() throws -> [Any] {
        var array = [Any]()

        while tokenList.hasNext() {
            let token = try tokenList.next()
            switch token {
            case .BEGIN_ARRAY, .SEP_COMMA:
                if try tokenList.hasNext() && tokenList.peek() != .SEP_COMMA && tokenList.peek() != .END_ARRAY {
                    array.append(try parse())
                }
            case .END_ARRAY:
                return array
            default:
                throw JsonParseException.InvalidToken
            }
        }
        throw JsonParseException.ExpectToken
    }

    enum JsonParseException: Error {
        case InvalidToken
        case ExpectString
        case ExpectColon
        case ExpectToken
    }
}
