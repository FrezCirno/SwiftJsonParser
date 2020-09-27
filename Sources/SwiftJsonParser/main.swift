import Foundation

let manager = FileManager.default
let urlsForDocDirectory = manager.urls(for: .documentDirectory, in:.userDomainMask)
let file = urlsForDocDirectory[0].appendingPathComponent("1.txt")

let data = manager.contents(atPath: file.path)
let readString = String(data: data!, encoding: String.Encoding.utf8)
//print("文件内容: \(String(describing: readString))")

let scanner = Scanner(readString!)

let tokenList = try Tokenizer(scanner).tokenize()

let json = try Parser(tokenList).parse()

print(json.toString)
