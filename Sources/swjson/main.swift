
let scanner = Scanner("""
{"H":"W","aa":-1.23456E32}
""")

// while scanner.hasNext() {
//     print(scanner.next())
// }

let tokenList = try Tokenizer(scanner).tokenize()

// while tokenList.hasNext() {
//     let token = tokenList.next()
//     print(token)
// }

let json = try Parser(tokenList).parse()

print(json.toString)

// let tokens = try Tokenizer(scanner)
// print(tokens.token)
//
