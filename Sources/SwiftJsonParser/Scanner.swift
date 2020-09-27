/**
 * 字符流
 *
 *
 *
 */

public class Scanner {
    private var str: String
    private var ptr: String.Index

    init(_ str: String) {
        self.str = str
        ptr = str.startIndex
    }

    public func hasNext() -> Bool {
        return ptr != str.endIndex
    }

    public func next() -> Character {
        let oldptr = ptr
        ptr = str.index(after: ptr)
        return str[oldptr]
    }

    public func peek() -> Character {
        return str[ptr]
    }

    public func back() {
        if ptr != str.startIndex {
            ptr = str.index(before: ptr)
        }
    }
}
