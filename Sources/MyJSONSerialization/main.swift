
while let line = readLine() {
    let obj = MyJSONSerialization.jsonObject(with: line.data(using: .utf8)!)
    print("Swift:")
    print(obj)

    let data = try MyJSONSerialization.data(withJSONObject: obj)
    print("JSON:")
    print(String(data: data, encoding: .utf8)!)
}
