public enum Json {
    case JsonNull
    case JsonBoolean(Bool)
    case JsonNumber(Double)
    case JsonString(String)
    indirect case JsonArray([Json])
    indirect case JsonObject([String: Json])

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
            return array.map { (json: Json) -> String in json.toString }.joined()
        case let .JsonObject(dict):
            return dict.map { (key, value) -> String in "\(key):\(value.toString)" }.joined()
        }
    }
}
