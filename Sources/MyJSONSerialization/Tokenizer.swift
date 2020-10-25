
public protocol Tokenizer {
    // 是否有下一个token
    func hasNext() -> Bool

    // 提前检查下一个token， 没有了就会抛出异常
    func peek() throws -> Token

    // 返回下一个token， 没有了就会抛出异常
    func next() throws -> Token
}
