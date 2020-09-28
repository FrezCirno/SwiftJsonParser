import Foundation

if let str = readLine() {
    print("解析结果: \n\(try JSON(data: str).prettify())")
}
