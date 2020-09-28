

public class Parser {
    private let tokenList: Tokenizer

    init(_ tokenList: Tokenizer) {
        self.tokenList = tokenList
    }

    public func parse() throws -> Json {
        while tokenList.hasNext() {
            let token = try tokenList.peek()
            switch token {
            case .BEGIN_OBJECT:
                return try parseObject()
            case .BEGIN_ARRAY:
                return try parseArray()
            case let .STRING(value):
                _ = try tokenList.next()
                return .JsonString(value)
            case let .NUMBER(value):
                _ = try tokenList.next()
                return .JsonNumber(value)
            case let .BOOLEAN(value):
                _ = try tokenList.next()
                return .JsonBoolean(value)
            case .NULL:
                _ = try tokenList.next()
                return .JsonNull
            default:
                throw JsonParseException.InvalidToken
            }
        }
        throw JsonParseException.ExpectToken
    }

    public func parseObject() throws -> Json {
        var kvpairs = [(String, Json)]()

        while tokenList.hasNext() {
            switch try tokenList.next() {
            case .BEGIN_OBJECT, .SEP_COMMA:
                let token = try tokenList.next()
                guard case let .STRING(key) = token else {
                    throw JsonParseException.ExpectString
                }
                guard case .SEP_COLON = try tokenList.next() else {
                    throw JsonParseException.ExpectColon
                }
                kvpairs.append((key, try parse()))
            case .END_OBJECT:
                return Json.JsonObject(kvpairs)
            default:
                throw JsonParseException.InvalidToken
            }
        }
        throw JsonParseException.ExpectToken
    }

    public func parseArray() throws -> Json {
        var array = [Json]()

        while tokenList.hasNext() {
            let token = try tokenList.next()
            switch token {
            case .BEGIN_ARRAY, .SEP_COMMA:
                array.append(try parse())
            case .END_ARRAY:
                return Json.JsonArray(array)
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
