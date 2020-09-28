/**
 * 字符流
 *
 */

public class Scanner {
    private var str: String
    private(set) var position: String.Index

    init(_ str: String) {
        self.str = str
        position = str.startIndex
    }

    public func hasNext() -> Bool {
        return position != str.endIndex
    }

    public func next() -> Character {
        let oldptr = position
        position = str.index(after: position)
        return str[oldptr]
    }

    public func peek() -> Character {
        return str[position]
    }

    public func back() {
        if position != str.startIndex {
            position = str.index(before: position)
        }
    }
}
