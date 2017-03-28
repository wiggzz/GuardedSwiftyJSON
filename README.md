[![Build Status](https://travis-ci.org/wiggzz/GuardedSwiftyJSON.svg?branch=master)](https://travis-ci.org/wiggzz/GuardedSwiftyJSON)

# GuardedSwiftyJSON

## Why should I use this?

This library makes initializing models with JSON data with SwiftyJSON a lot easier.

Often with SwiftyJSON I end up doing something like this:

```swift
import SwiftyJSON

struct Model {
  let name : String
  let height : Double

  init?(json: JSON) {
    guard let name = json["name"].string, let height = json["height"].double else {
      return nil
    }

    self.name = name
    self.height = height
  }
}
```

which gets annoying when you have more than two or three properties you want to guard your model on.

## Example

GuardedSwiftyJSON solves this by providing an initializer which will fail the initialization if properties that you request are not present.

```swift
import GuardedSwiftyJSON

struct Model : JsonInitializable {
  let name : String
  let height : Double

  init(json: GuardedJSON) {
    name = json["name"].string
    height = json["height"].double
  }
}
```

And then your object will get an initializer that allows it to be created from a Swifty JSON object:

```swift
let data : JSON = ["name": "Arthur Swiftington", "height": 182.8]

let model : Model? = Model(json: data)
```

If either one of name or height are not present, the initialization will fail.

You can specify optional properties by using the optional prefix:
```swift
import GuardedSwiftyJSON

struct Model : JsonInitializable {
  let name : String
  let height : Double?

  init(json: GuardedJSON) {
    name = json["name"].string
    height = json["height"].optionalDouble
  }
}
```
Then, if those optional properties do not exist, they will not cause initialization to abort.

GuardedSwiftyJSON provides the following protocol
```swift
protocol JsonInitializable {
  init?(json: JSON)
  init(json: GuardedJSON)
}
```
and a default implementation of `init?(json: JSON)` which automatically calls the proxying initializer and then fails the initialization if any of the required JSON properties are not present.

## Nested objects

Often you will have nested JSON objects that you will want to represent as a separate model. The default behavior is for the outer initializer to fail if a nested object is not valid. For example:
```swift
struct Outer : JsonInitializable {
  let inner : Inner

  init(json: GuardedJSON) {
    // since the inner json is still a GuardedJSON object in the same context,
    // if any of the properties trying to be extracted are invalid, the outer
    // initialization process will fail.
    inner = Inner(json: json["inner"])
  }
}
```
If we want an inner object to be optional, we should use the failable initializer of the Inner object:
```swift
struct Outer : JsonInitializable {
  let inner : Inner?

  init(json: GuardedJSON) {
    // here we extract the raw json object and call the failable initializer
    inner = Inner(json: json["inner"].rawJson)
  }
}
```

The same approach can be used to flatten a nested array of objects, where we only want to drop the ones that cannot be deserialized:
```swift
struct Outer : JsonInitializable {
  let items: [Inner]

  init(json: GuardedJSON) {
    inner = json["inner"].array.flatMap {
      return Inner(json: $0.rawJson)
    }
  }
}
```
To be specific, the `Outer` initializer will fail if the `inner` key is not present or is not an array. Otherwise the `Outer` initializer will succeed, and the array will be filled with any valid elements from the JSON.

In this way you can control where you want initialization to fail.

## Installation

### Carthage

    github "wiggzz/GuardedSwiftyJSON"

### Cocoapods

    pod 'GuardedSwiftyJSON'

## Contributing

Pull requests and issues are welcomed.

To run the tests, you first need to install the dependencies using `Carthage`.

    carthage update
