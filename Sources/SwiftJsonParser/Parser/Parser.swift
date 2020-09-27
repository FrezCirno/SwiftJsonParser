

public class Parser {
    private let tokenList: TokenList

    init(_ tokenList: TokenList) {
        self.tokenList = tokenList
    }

    public func parse() throws -> Json {
        while tokenList.hasNext() {
            let token = tokenList.next()
            switch token {
            case .BEGIN_OBJECT:
                return try parseObject()
            case .BEGIN_ARRAY:
                return try parseArray()
            case let .STRING(value):
                return .JsonString(value)
            case let .NUMBER(value):
                return .JsonNumber(value)
            case let .BOOLEAN(value):
                return .JsonBoolean(value)
            case .NULL:
                return .JsonNull
            default:
                throw JsonParseException.InvalidToken
            }
        }
        throw JsonParseException.ExpectToken
    }

    public func parseObject() throws -> Json {
        var dict = [String: Json]()
        while tokenList.hasNext() {
            let token = tokenList.peek()
            switch token {
            case .SEP_COMMA:
                _ = tokenList.next()
                fallthrough
            case .STRING:
                let (key, value) = try parseEntry()
                dict[key] = value
            case .END_OBJECT:
                _ = tokenList.next()
                return Json.JsonObject(dict)
            default:
                throw JsonParseException.InvalidToken
            }
        }
        throw JsonParseException.ExpectToken
    }

    public func parseArray() throws -> Json {
        var array = [Json]()
        while tokenList.hasNext() {
            let token = tokenList.next()
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

    private func parseEntry() throws -> (String, Json) {
        var token: Token

        token = tokenList.next()
        guard case let .STRING(key) = token else {
            throw JsonParseException.ExpectString
        }

        token = tokenList.next()
        guard case .SEP_COLON = token else {
            throw JsonParseException.ExpectColon
        }

        return (key, try parse())
    }

    enum JsonParseException: Error {
        case InvalidToken
        case ExpectString
        case ExpectColon
        case ExpectToken
    }
}
