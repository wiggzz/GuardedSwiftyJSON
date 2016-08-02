import Foundation
import SwiftyJSON

public protocol JsonInitializable {
    init?(json: JSON)
    init(json: GuardedJSON)
}

public protocol GuardedJSON {
    var json : JSON { get }

    var array : [GuardedJSON] { get }
    var optionalArray : [GuardedJSON]? { get }

    var dictionary : [String:GuardedJSON] { get }
    var optionalDictionary : [String:GuardedJSON]? { get }

    var string : String { get }
    var optionalString : String? { get }

    var double : Double { get }
    var optionalDouble : Double? { get }

    var bool : Bool { get }
    var optionalBool : Bool? { get }

    var number : NSNumber { get }
    var optionalNumber : NSNumber? { get }

    var float: Float { get }
    var optionalFloat : Float? { get }

    var int: Int { get }
    var optionalInt: Int? { get }

    var uInt: UInt { get }
    var optionalUInt: UInt? { get }

    var int8: Int8 { get }
    var optionalInt8: Int8? { get }

    var uInt8: UInt8 { get }
    var optionalUInt8: UInt8? { get }

    var int16: Int16 { get }
    var optionalInt16: Int16? { get }

    var uInt16: UInt16 { get }
    var optionalUInt16: UInt16? { get }

    var int32: Int32 { get }
    var optionalInt32: Int32? { get }

    var uInt32: UInt32 { get }
    var optionalUInt32: UInt32? { get }

    var int64: Int64 { get }
    var optionalInt64: Int64? { get }

    var uInt64: UInt64 { get }
    var optionalUInt64: UInt64? { get }

    subscript (path: [JSONSubscriptType]) -> GuardedJSON { get }
    subscript (path: JSONSubscriptType...) -> GuardedJSON { get }
}

extension JsonInitializable {
    public init?(json: JSON) {
        let context = GuardedJSONContext()
        self.init(json: context.proxy(json))
        context.close()
        if context.aborted {
            return nil
        }
    }
}

private class GuardedJSONContext {
    var closed : Bool = false
    var aborted : Bool = false

    func abort() {
        if (closed) {
            FatalErrorWrapper.sharedInstance.fail("GuardedJSONContext being aborted after already being closed, which is unsafe: this indicates a JSON property you expected is not present. This is probably caused because you are saving a GuardedJSON object and accessing it outside an initializer. Do not store GuardedJSON as a property, use the .json property to extract the underlying JSON for storage beyond initialization.")
        }
        aborted = true
    }

    func close() {
        closed = true
    }

    func proxy(json: JSON) -> GuardedJSON {
        return _GuardedJSON(json: json, context: self)
    }
}

class FatalErrorWrapper {
    static var sharedInstance = FatalErrorWrapper()

    func fail(message: String) {
        fatalError(message)
    }
}

private class _GuardedJSON : GuardedJSON {
    let json: JSON
    let context : GuardedJSONContext

    init(json: JSON, context : GuardedJSONContext) {
        self.json = json
        self.context = context
    }

    var array : [GuardedJSON] {
        return extractOrAbort(json.array?.map(context.proxy))
    }

    var optionalArray: [GuardedJSON]? {
        return json.array?.map(context.proxy)
    }

    var dictionary : [String:GuardedJSON] {
        return Dictionary(extractOrAbort(json.dictionary).map { ($0, context.proxy($1)) })
    }

    var optionalDictionary : [String:GuardedJSON]? {
        return (json.dictionary?.map { ($0, context.proxy($1)) }).map { Dictionary($0) }
    }

    var string : String {
        return extractOrAbort(json.string)
    }

    var optionalString : String? {
        return json.string
    }

    var double : Double {
        return extractOrAbort(json.double)
    }

    var optionalDouble : Double? {
        return json.double
    }

    var bool : Bool {
        return extractOrAbort(json.bool)
    }

    var optionalBool : Bool? {
        return json.bool
    }

    var number : NSNumber {
        return extractOrAbort(json.number)
    }

    var optionalNumber: NSNumber? {
        return json.number
    }

    var float: Float {
        return extractOrAbort(json.float)
    }
    var optionalFloat : Float? {
        return json.float
    }

    var int: Int {
        return extractOrAbort(json.int)
    }
    var optionalInt: Int? {
        return json.int
    }

    var uInt: UInt {
        return extractOrAbort(json.uInt)
    }
    var optionalUInt: UInt? {
        return json.uInt
    }

    var int8: Int8 {
        return extractOrAbort(json.int8)
    }
    var optionalInt8: Int8? {
        return json.int8
    }

    var uInt8: UInt8 {
        return extractOrAbort(json.uInt8)
    }
    var optionalUInt8: UInt8? {
        return json.uInt8
    }

    var int16: Int16 {
        return extractOrAbort(json.int16)
    }
    var optionalInt16: Int16? {
        return json.int16
    }

    var uInt16: UInt16 {
        return extractOrAbort(json.uInt16)
    }
    var optionalUInt16: UInt16? {
        return json.uInt16
    }

    var int32: Int32 {
        return extractOrAbort(json.int32)
    }
    var optionalInt32: Int32? {
        return json.int32
    }

    var uInt32: UInt32 {
        return extractOrAbort(json.uInt32)
    }
    var optionalUInt32: UInt32? {
        return json.uInt32
    }

    var int64: Int64 {
        return extractOrAbort(json.int64)
    }
    var optionalInt64: Int64? {
        return json.int64
    }

    var uInt64: UInt64 {
        return extractOrAbort(json.uInt64)
    }
    var optionalUInt64: UInt64? {
        return json.uInt64
    }

    subscript (path: [JSONSubscriptType]) -> GuardedJSON {
        return context.proxy(json[path])
    }

    subscript (path: JSONSubscriptType...) -> GuardedJSON {
        return context.proxy(json[path])
    }

    private func extractOrAbort<T : DefaultInitializable>(value: T?) -> T {
        if let value = value {
            return value
        } else {
            context.abort()
            return T()
        }
    }
}

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

protocol DefaultInitializable {
    init()
}

extension Bool : DefaultInitializable {}
extension Double : DefaultInitializable {}
extension NSNumber : DefaultInitializable {}
extension String : DefaultInitializable {}
extension Dictionary : DefaultInitializable {}
extension Array : DefaultInitializable {}
extension Float : DefaultInitializable {}
extension Int : DefaultInitializable {}
extension UInt : DefaultInitializable {}
extension Int8 : DefaultInitializable {}
extension UInt8 : DefaultInitializable {}
extension Int16 : DefaultInitializable {}
extension UInt16 : DefaultInitializable {}
extension Int32 : DefaultInitializable {}
extension UInt32 : DefaultInitializable {}
extension Int64 : DefaultInitializable {}
extension UInt64 : DefaultInitializable {}

