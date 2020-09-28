
var readString = """
{"status":200,"data":["123",null,1.2345E45,true,false,{"id":2,"name":"b"},{"id":3,"name":"c"},{"id":4,"name":"d"},{"id":5,"name":"e"}],"msg":"aaaaa"}
"""

print("文件内容: \(readString)")

let scanner = Scanner(readString)

let tokenizer = try Tokenizer(scanner)

// while tokenizer.hasNext() {
//     print(try tokenizer.next())
// }

let json = try Parser(tokenizer).parse()

print(json.toString)
