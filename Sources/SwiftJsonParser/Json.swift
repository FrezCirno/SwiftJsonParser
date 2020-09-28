public enum JSON {
    case JsonNull
    case JsonBoolean(Bool)
    case JsonNumber(Double)
    case JsonString(String)
    indirect case JsonArray([JSON])
    indirect case JsonObject([(String, JSON)])

    init(data: String) throws {
        self = try Parser(Tokenizer(Scanner(data))).parse()
    }

    var toString: String {
        switch self {
        case .JsonNull:
            return "null"
        case let .JsonBoolean(bool):
            return String(bool)
        case let .JsonNumber(num):
            return String(num)
        case let .JsonString(str):
            return "\"\(str)\""
        case let .JsonArray(array):
            return "[\(array.map { (json: JSON) -> String in json.toString }.joined(separator: ","))]"
        case let .JsonObject(kvpairs):
            return "{\(kvpairs.map { (key, value) -> String in "\"\(key)\":\(value.toString)" }.joined(separator: ","))}"
        }
    }

    func prettify(_ depth: Int = 0, indent: Int = 2) -> String {
        switch self {
        case .JsonNull:
            return "null"
        case let .JsonBoolean(bool):
            return String(bool)
        case let .JsonNumber(num):
            return String(num)
        case let .JsonString(str):
            return "\"\(str)\""
        case let .JsonArray(array):
            return "[\n"
                + array.map { json in
                    String(repeating: " ", count: indent * (depth + 1)) + json.prettify(depth + 1)
                }.joined(separator: ",\n") + "\n"
                + String(repeating: " ", count: indent * depth) + "]"
        case let .JsonObject(kvpairs):
            return "{\n"
                + kvpairs.map { key, value in
                    String(repeating: " ", count: indent * (depth + 1)) + "\"" + key + "\": " + value.prettify(depth + 1)
                }.joined(separator: ",\n") + "\n"
                + String(repeating: " ", count: indent * depth) + "}"
        }
    }
}
