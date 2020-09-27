import Foundation

public class Tokenizer {
    private var scanner: Scanner

    init(_ scanner: Scanner) throws {
        self.scanner = scanner
    }

    public func tokenize() throws -> TokenList {
        let tokenList = TokenList()
        var token: Token

        while true {
            token = try next()
            tokenList.add(token)
            if case .END_DOCUMENT = token { break }
        }

        return tokenList
    }

    public func next() throws -> Token {
        while scanner.hasNext() {
            let ch = scanner.next()

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
                scanner.back()
                return try readNumber()
            default:
                throw JsonTokenizeException.IllegalCharacter
            }
        }
        return .END_DOCUMENT
    }

    private func readNull() throws -> Token {
        guard scanner.next() == "u", scanner.next() == "l", scanner.next() == "l" else {
            throw JsonTokenizeException.InvalidJsonString
        }
        return .NULL
    }

    private func readTrue() throws -> Token {
        guard scanner.next() == "r", scanner.next() == "u", scanner.next() == "e" else {
            throw JsonTokenizeException.InvalidJsonString
        }
        return .BOOLEAN(true)
    }

    private func readFalse() throws -> Token {
        guard scanner.next() == "a", scanner.next() == "l", scanner.next() == "s", scanner.next() == "e" else {
            throw JsonTokenizeException.InvalidJsonString
        }
        return .BOOLEAN(false)
    }

    private func readString() throws -> Token {
        var str = ""
        while scanner.hasNext() {
            let ch = scanner.next()
            switch ch {
            case "\\":
                let cch = scanner.next()
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
                    for _ in 1 ... 4 {
                        let ucode = scanner.next()
                        var ucodeStr = ""
                        guard ucode.isHexDigit else {
                            throw JsonTokenizeException.InvalidJsonString
                        }
                        ucodeStr.append(ucode)
                        str.append(Character(ucodeStr))
                    }
                default:
                    throw JsonTokenizeException.InvalidJsonString
                }
            case "\"":
                return .STRING(str)
            case "\r", "\n":
                throw JsonTokenizeException.InvalidJsonString
            default:
                str.append(ch)
            }
        }
        throw JsonTokenizeException.InvalidJsonString
    }

    private func readNumber() throws -> Token {
        var base = "", expon = "", ch: Character?

        /* 负号 */
        ch = scanner.peek()
        if ch == "-" {
            base.append(scanner.next())
        }

        /* 底数整数部分 */
        guard scanner.peek().isNumber else {
            throw JsonTokenizeException.ExpectedNumber
        }
        base.append(scanner.next())
        
        if ch != "0" {
            while scanner.peek().isNumber {
                base.append(scanner.next())
            }
        }

        /* 底数小数部分 */
        if scanner.peek() == "." {
            base.append(scanner.next())
            guard scanner.peek().isNumber else {
                throw JsonTokenizeException.ExpectedNumber
            }
            repeat {
                base.append(scanner.next())
            } while scanner.peek().isNumber
        }

        /* 指数 */
        ch = scanner.peek()
        if ch == "e" || ch == "E" {
            _ = scanner.next()

            ch = scanner.peek()
            if ch == "-" || ch == "+" {
                expon.append(scanner.next())
            }

            guard scanner.peek().isNumber else {
                throw JsonTokenizeException.ExpectedNumber
            }
            repeat {
                expon.append(scanner.next())
            } while scanner.peek().isNumber
        } else {
            expon.append("0")
        }

        let value = Double(base)! * pow(10, Double(expon)!)
        return .NUMBER(value)
    }

    enum JsonTokenizeException: Error {
        case InvalidJsonString
        case IllegalCharacter
        case ExpectedNumber
    }
}
