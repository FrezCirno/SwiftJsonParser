public class TokenList {
    private var tokens = [Token]()
    private var index = 0

    public func add(_ token: Token) {
        tokens.append(token)
    }

    public func hasNext() -> Bool {
        return index < tokens.count
    }

    public func peek() -> Token {
        return tokens[index]
    }

    public func peekPrevious() -> Token {
        return tokens[index]
    }

    public func next() -> Token {
        let oldindex = index
        index += 1
        return tokens[oldindex]
    }
}
