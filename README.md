# Swift语言练习 1 —— JSON解析器

> 谭梓煊 (1853434)

> [Mail](2277861660@qq.com)

> [Github地址](https://github.com/FrezCirno/SwiftJsonParser.git)

## 1 项目背景

JSON(JavaScript Object Notation, JS 对象表示法) 是一种轻量级的数据交换格式。它基于 ECMAScript (欧洲计算机协会制定的js规范)的一个子集，采用完全独立于编程语言的文本格式来存储和表示数据。简洁和清晰的层次结构使得 JSON 成为理想的数据交换语言。 易于人阅读和编写，同时也易于机器解析和生成，并有效地提升网络传输效率。

本次项目目的是使用Swift语言实现一个`Text-in, Text-out`的JSON解析器。其中解析器API设计参考Swift语言中的[NSJSONSerialization](https://developer.apple.com/documentation/foundation/nsjsonserialization?language=occ)类。支持JSON到Swift原生数据结构的双向转换。

## 2 项目实现

### 2.1 API设计
```swift
class MyJSONSerialization: NSObject {

    // 🚚 JSON解析: JSON -> Swift
    // 将纯数据(Data)类型的JSON转化为Swift数据结构
    class func jsonObject(with data: Data) -> Any

    // 从输入流中获取JSON, 转化为Swift数据结构
    class func jsonObject(with stream: InputStream) -> Any
    
    // 🚛 JSON序列化: Swift -> JSON
    // 将Swift数据结构转化为JSON
    class func data(withJSONObject obj: Any) throws -> Data
    
    // 将Swift数据结构转化为JSON, 并写入输出流, 返回写入字节数
    class func writeJSONObject(_ obj: Any, to stream: OutputStream) -> Int

    // 测试给定Swift数据结构能否转化为JSON
    class func isValidJSONObject(_ obj: Any) -> Bool
}
```
### 2.2 数据流

- 🚚 JSON解析: JSON -> Swift

> **`JSON(Data)` --(Scanner)--> `字符流` -(Tokenizer)-> `TokenList` --(Parser)--> `Swift(Any)`**

- 🚛 JSON序列化: Swift -> JSON

> **递归遍历 + String(describing:_)**

### 2.3 Scanner实现

- 设计上大体参考了Java的Scanner
- 返回扫描位置， 发生错误时方便debug

```swift
public protocol Scanner {
    // 返回当前扫描位置
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
```

### 2.4 Tokenizer实现

- 采用惰性解析Token的方法, 按需解析

```swift
public protocol Tokenizer {
    // 是否有下一个token
    func hasNext() -> Bool

    // 提前检查下一个token， 没有了就会抛出异常
    func peek() throws -> Token

    // 返回下一个token， 没有了就会抛出异常
    func next() throws -> Token
}
```

- Token定义

    - 使用`enum`表示Token

    - 遵从`Equatable`协议, 从而方便地判断两个(基本)Token是否相等

```swift
public enum Token: Equatable {
    case BEGIN_OBJECT
    case END_OBJECT
    case BEGIN_ARRAY
    case END_ARRAY
    case NULL
    case NUMBER(Double)
    case STRING(String)
    case BOOLEAN(Bool)
    case SEP_COLON
    case SEP_COMMA
}
```

### 2.5 Parser实现

- 递归解析
    - `parse`内部调用`parseObject`和`parseArray`
    - `parseObject`和`parseArray`内部调用`parse`

```swift
public class Parser {
    private let tokenList: Tokenizer

    init(_ tokenList: Tokenizer) {
        self.tokenList = tokenList
    }

    // 解析任意类型
    public func parse() throws -> Any 

    // 解析一个Object
    private func parseObject() throws -> [String: Any] 

    // 解析一个Array
    private func parseArray() throws -> [Any]
}
```

### 2.6 错误处理

- Tokenizer错误定义
```swift
enum TokenizerImpl.JsonTokenizeException: Error {
    case IllegalCharacter(position: String.Index)
    case ExpectedNumber(position: String.Index)
    case ExpectedNull(position: String.Index)
    case ExpectedTrue(position: String.Index)
    case ExpectedFalse(position: String.Index)
    case ExpectedCharacter
}
```

- Parser错误定义
```swift
enum Parser.JsonParseException: Error {
    case InvalidToken
    case ExpectString
    case ExpectColon
    case ExpectToken
}
```

- JSON序列化错误定义
```swift
enum MyJSONSerialization.JSONError: Error {
    case invalidJSON
}
```

## 3 项目演示

- main代码

    - Text-in, Text-out!

```swift
while let line = readLine() {
    // JSON -> Swift
    let obj = MyJSONSerialization.jsonObject(with: line.data(using: .utf8)!)
    print("Swift:")
    print(obj)

    // Swift -> JSON
    let data = try MyJSONSerialization.data(withJSONObject: obj)
    print("JSON:")
    print(String(data: data, encoding: .utf8)!)
}
```

- 测试方法

```shell
# For short JSON
$ echo '{"Hello":"World!"}' | swift run

# For long JSON
$ cat longlong.json | swift run
```

### 3.1 一般JSON

```shell
$ echo '{"key":[0,1,true,false,null,2.5e3]}' | swift run
Swift:
["key": [0.0, 1.0, true, false, <null>, 2500.0]]
JSON:
{"key":[0,1,true,false,null,2500]}
```

### 3.2 边界情况: 空对象, 空数组

```shell
$ echo '[]' | swift run           
Swift:
[]
JSON:
[]
```

```shell
$ echo '[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]' | swift run
Swift:
[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]
JSON:
[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]
```

```shell
$ echo '[[],[[,[[]],[[[[]],[[]]]]]],[]]]' | swift run
Swift:
[[], [[[[]], [[[[]], [[]]]]]], []]
JSON:
[[],[[[[]],[[[[]],[[]]]]]],[]]
```

```shell
$ echo '{"a":{"b":{}},"c":{}}' | swift run
Swift:
["a": ["b": [:]], "c": [:]]
JSON:
{"a":{"b":{}},"c":{}}
```

```shell
$ echo '[{},[{},{},[]]]' | swift run       
Swift:
[[:], [[:], [:], []]]
JSON:
[{},[{},{},[]]]
```

### 3.3 长JSON

```shell
$ wc -m longtest.json
11342 longtest.json
$ cat longtest.json | swift run
Swift:
["sections": [], "documentVersion": 0.0, "identifier ...
JSON:
{"sections":[],"documentVersion":0,"identifier":{"url":"doc ... 
```

### 3.4 字符串

- 中文字符, Emoji (Literal)

```shell
$ echo '"我爱中国，我爱🌍"' | swift run
Swift:
我爱中国，我爱🌍
JSON:
"我爱中国，我爱🌍"
```

- 转义字符

```shell
$ cat escape.json
"转义字符【\"】【\\】【\/】【\b】【\f】【\n】【\r】【\t】【\u1234】"
$ cat escape.json | swift run 
Swift:
转义字符【"】【\】【/】 】【
                            】【
】【    】【Ӓ】
JSON:
"转义字符【\"】【\\】【\/】【\b】【\f】【\n】【\r】【\t】【Ӓ】"
```

### 3.5 鲁棒性

- 尾缀逗号

```shell
$ echo '[1,2,3,]' | swift run
Swift:
[1.0, 2.0, 3.0]
JSON:
[1,2,3]
```
