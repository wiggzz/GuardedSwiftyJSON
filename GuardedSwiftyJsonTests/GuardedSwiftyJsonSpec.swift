import Quick
import Nimble
import SwiftyJSON
@testable import GuardedSwiftyJSON

struct TestStruct : JsonInitializable {
    let price : Double
    let name : String

    init(json: GuardedJSON) {
        price = json["price"].double
        name = json["name"].string
    }
}

struct DeepStruct : JsonInitializable {
    let deepItem : String

    init(json: GuardedJSON) {
        deepItem = json["level1"]["level2"].string
    }
}

struct DeferredStruct : JsonInitializable {
    let object : JSON

    init(json: GuardedJSON) {
        object = json["object"].rawJson
    }
}

struct DangerousStruct : JsonInitializable {
    let address: GuardedJSON

    init(json: GuardedJSON) {
        address = json["address"]
    }
}

struct NestedStruct : JsonInitializable {
    let items: [TestStruct]

    init(json: GuardedJSON) {
        items = json["items"].array.map {
            return TestStruct(json: $0)
        }
    }
}

struct NestedStructFlattened : JsonInitializable {
    let items : [TestStruct]

    init(json: GuardedJSON) {
        items = json["items"].array.flatMap {
            return TestStruct(json: $0.rawJson)
        }
    }
}

class FatalErrorStub : FatalErrorWrapper {
    var message : String?

    override func fail(_ message: String) {
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

            it("should be able to perform nested initialization") {
                let json = JSON([
                    "items": [
                        [
                            "name": "shovel",
                            "price": 4.5
                        ],
                        [
                            "name": "bucket",
                            "price": 2.0
                        ]
                    ]
                    ])

                let object = NestedStruct(json: json)

                expect(object).toNot(beNil())
                expect(object?.items.count).to(equal(2))
                expect(object?.items[0].name).to(equal("shovel"))
                expect(object?.items[0].price).to(equal(4.5))
                expect(object?.items[1].name).to(equal("bucket"))
                expect(object?.items[1].price).to(equal(2.0))
            }

            it("should fail the initialization when nested objects are invalid") {
                let json = JSON([
                        "items": [
                            [
                                "name": "shovel",
                                "price": 4.5
                            ],
                            [
                                "name": "bucket"
                            ]
                        ]
                    ])

                let object = NestedStruct(json: json)

                expect(object).to(beNil())
            }

            it("should not fail the initialization when nested items are flattened") {
                let json = JSON([
                    "items": [
                        [
                            "name": "shovel",
                            "price": 4.5
                        ],
                        [
                            "name": "bucket"
                        ]
                    ]
                    ])

                let object = NestedStructFlattened(json: json)

                expect(object).toNot(beNil())
                expect(object?.items.count).to(equal(1))
                expect(object?.items[0].name).to(equal("shovel"))
                expect(object?.items[0].price).to(equal(4.5))
            }

            it("should protect against dangerous usage of GuardedJSON outside initializer") {
                let fatalErrorStub = FatalErrorStub()
                FatalErrorWrapper.sharedInstance = fatalErrorStub

                let json = JSON([
                    ])

                let object = DangerousStruct(json: json)

                let _ = object!.address["streetName"].string

                expect(fatalErrorStub.message).to(equal("GuardedJSONContext being aborted after already being closed, which is unsafe: this indicates a JSON property you expected is not present. This is probably caused because you are saving a GuardedJSON object and accessing it outside an initializer. Do not store GuardedJSON as a property, use the .json property to extract the underlying JSON for storage beyond initialization."))

                FatalErrorWrapper.sharedInstance = FatalErrorWrapper()
            }
        }
    }
}
