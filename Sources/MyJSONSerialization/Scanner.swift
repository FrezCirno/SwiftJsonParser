
public protocol Scanner {
    // 当前扫描位置
    var position: String.Index { get }

    // hasNext
    func hasNext() -> Bool

    // next
    func next() throws -> Character

    // peek
    func peek() throws -> Character

    // back
    func back() throws
}
