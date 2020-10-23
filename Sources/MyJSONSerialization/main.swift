
print("input json data: ")
while let line = readLine() {
    let obj = MyJSONSerialization.jsonObject(with: line.data(using: .utf8)!)
    print("JSONObject: \(obj)")

    let data = try MyJSONSerialization.data(withJSONObject: obj)
    print("Data: \(String(data: data, encoding: .utf8)!)")
}
