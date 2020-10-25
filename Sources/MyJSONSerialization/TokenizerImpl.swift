import Foundation

public class TokenizerImpl: Tokenizer {
    private var scanner: Scanner
    private var _next: Token?

    init(_ scanner: Scanner) throws {
        self.scanner = scanner
    }

    public func hasNext() -> Bool {
        return _next != nil || scanner.hasNext()
    }

    public func peek() throws -> Token {
        if _next == nil {
            _next = try nextToken()
        }
        return _next!
    }

    public func next() throws -> Token {
        if _next != nil {
            let tmp = _next!
            _next = nil
            return tmp
        } else {
            return try nextToken()
        }
    }

    private func nextToken() throws -> Token {
        while scanner.hasNext() {
            let ch = try scanner.next()
            switch ch {
            case "{":
                return .BEGIN_OBJECT
            case "}":
                return .END_OBJECT
            case "[":
                return .BEGIN_ARRAY
            case "]":
                return .END_ARRAY
            case ":":
                return .SEP_COLON
            case ",":
                return .SEP_COMMA
            case "n":
                return try readNull()
            case "t":
                return try readTrue()
            case "f":
                return try readFalse()
            case "\"":
                return try readString()
            case "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                try scanner.back()
                return try readNumber()
            default:
                throw JsonTokenizeException.IllegalCharacter(position: scanner.position)
            }
        }
        throw JsonTokenizeException.ExpectedCharacter
    }

    private func readNull() throws -> Token {
        guard try scanner.next() == "u", try scanner.next() == "l", try scanner.next() == "l" else {
            throw JsonTokenizeException.ExpectedNull(position: scanner.position)
        }
        return .NULL
    }

    private func readTrue() throws -> Token {
        guard try scanner.next() == "r", try scanner.next() == "u", try scanner.next() == "e" else {
            throw JsonTokenizeException.ExpectedTrue(position: scanner.position)
        }
        return .BOOLEAN(true)
    }

    private func readFalse() throws -> Token {
        guard try scanner.next() == "a", try scanner.next() == "l", try scanner.next() == "s", try scanner.next() == "e" else {
            throw JsonTokenizeException.ExpectedFalse(position: scanner.position)
        }
        return .BOOLEAN(false)
    }

    private func readString() throws -> Token {
        var str = ""
        while scanner.hasNext() {
            let ch = try scanner.next()
            switch ch {
            case "\\":
                let cch = try scanner.next()
                switch cch {
                case "\"":
                    str.append("\"")
                case "\\":
                    str.append("\\")
                case "/":
                    str.append("/")
                case "b":
                    str.append("\u{8}")
                case "f":
                    str.append("\u{c}")
                case "n":
                    str.append("\n")
                case "r":
                    str.append("\r")
                case "t":
                    str.append("\t")
                case "u":
                    var ucodeStr = ""
                    for _ in 1 ... 4 {
                        let uchar = try scanner.next()
                        guard uchar.isHexDigit else {
                            throw JsonTokenizeException.IllegalCharacter(position: scanner.position)
                        }
                        ucodeStr.append(uchar)
                    }
                    guard let ucode = Int(ucodeStr), let uscalar = Unicode.Scalar(ucode) else {
                        throw JsonTokenizeException.IllegalCharacter(position: scanner.position)
                    }
                    let char = Character(uscalar)
                    str.append(char)
                case " ":
                    str.append(" ")
                default:
                    throw JsonTokenizeException.IllegalCharacter(position: scanner.position)
                }
            case "\"":
                return .STRING(str)
            case "\r", "\n":
                throw JsonTokenizeException.IllegalCharacter(position: scanner.position)
            default:
                str.append(ch)
            }
        }
        throw JsonTokenizeException.IllegalCharacter(position: scanner.position)
    }

    private func readNumber() throws -> Token {
        var base = "", expon = "", ch: Character?

        /* 负号 */
        if try scanner.peek() == "-" {
            base.append(try scanner.next())
        }

        /* 底数整数部分 */
        guard try scanner.peek().isNumber else {
            throw JsonTokenizeException.ExpectedNumber(position: scanner.position)
        }
        base.append(try scanner.next())

        while try scanner.hasNext() && scanner.peek().isNumber {
            base.append(try scanner.next())
        }

        /* 底数小数部分 */
        if try scanner.hasNext() && scanner.peek() == "." {
            base.append(try scanner.next())
            guard try scanner.hasNext() && scanner.peek().isNumber else {
                throw JsonTokenizeException.ExpectedNumber(position: scanner.position)
            }
            repeat {
                base.append(try scanner.next())
            } while try scanner.hasNext() && scanner.peek().isNumber
        }

        /* 指数 */
        if try scanner.hasNext() && (scanner.peek() == "e" || scanner.peek() == "E") {
            _ = try scanner.next()

            ch = try scanner.peek()
            if ch == "-" || ch == "+" {
                expon.append(try scanner.next())
            }

            guard try scanner.hasNext() && scanner.peek().isNumber else {
                throw JsonTokenizeException.ExpectedNumber(position: scanner.position)
            }
            repeat {
                expon.append(try scanner.next())
            } while try scanner.hasNext() && scanner.peek().isNumber
        } else {
            expon.append("0")
        }

        guard let nbase = Double(base), let nexpon = Double(expon) else {
            throw JsonTokenizeException.ExpectedNumber(position: scanner.position)
        }
        return .NUMBER(nbase * pow(10, nexpon))
    }

    enum JsonTokenizeException: Error {
        case IllegalCharacter(position: String.Index)
        case ExpectedNumber(position: String.Index)
        case ExpectedNull(position: String.Index)
        case ExpectedTrue(position: String.Index)
        case ExpectedFalse(position: String.Index)
        case ExpectedCharacter
    }
}
