import Quick
import Nimble
import SwiftyJSON
@testable import GuardedSwiftyJSON

struct TestStruct : JsonInitializable {
    let price : Double
    let name : String

    init(json: JsonProxy) {
        price = json["price"].double
        name = json["name"].string
    }
}

struct DeepStruct : JsonInitializable {
    let deepItem : String

    init(json: JsonProxy) {
        deepItem = json["level1"]["level2"].string
    }
}

struct DeferredStruct : JsonInitializable {
    let object : JSON

    init(json: JsonProxy) {
        object = json["object"].json
    }
}

struct DangerousStruct : JsonInitializable {
    let address: JsonProxy

    init(json: JsonProxy) {
        address = json["address"]
    }
}

class FatalErrorStub : FatalErrorWrapper {
    var message : String?

    override func fail(message: String) {
        self.message = message
    }
}

class GuardedSwiftyJsonSpec : QuickSpec {
    override func spec() {
        describe("JsonInitialiable") {
            it("should initialize the object") {
                let json = JSON([
                    "name": "test name",
                    "price": 14.5
                    ])

                let object = TestStruct(json: json)

                expect(object?.price).to(equal(14.5))
                expect(object?.name).to(equal("test name"))
            }

            it("should fail to initialize when a required item is not present") {
                let json = JSON([
                    "name": "test name"
                    ])

                let object = TestStruct(json: json)

                expect(object).to(beNil())
            }

            it("should be able to save the json for later use") {
                let json = JSON([
                    "object": [
                        "key": "value"
                    ]
                    ])

                let object = DeferredStruct(json: json)

                expect(object?.object["key"].string).to(equal("value"))
            }

            it("should be capable of deep extraction of objects") {
                let json = JSON([
                        "level1": [
                            "level2": "test string"
                        ]
                    ])

                let object = DeepStruct(json: json)

                expect(object?.deepItem).to(equal("test string"))
            }

            it("should protect against dangerous usage of JsonProxy outside initializer") {
                let fatalErrorStub = FatalErrorStub()
                FatalErrorWrapper.sharedInstance = fatalErrorStub

                let json = JSON([
                    ])

                let object = DangerousStruct(json: json)

                let _ = object!.address["streetName"].string

                expect(fatalErrorStub.message).to(equal("ProxyContext being aborted after already being closed. This is probably caused because you are saving a JsonProxy object and accessing it outside an initializer. Do not store JsonProxy as a property, use the .json property to extract the underlying JSON for storage beyond initialization."))

                FatalErrorWrapper.sharedInstance = FatalErrorWrapper()
            }
        }
    }
}
