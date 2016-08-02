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

GuardedSwiftyJSON provies the following protocol
```swift
protocol JsonInitializable {
  init?(json: JSON)
  init(json: GuardedJSON)
}
```
and a default implementation of `init?(json: JSON)` which automatically calls the proxying initializer and then fails the initialization if any of the required JSON properties are not present.

## Installation

### Carthage

    github "wiggzz/GuardedSwiftyJSON"

### Cocoapods

    pod 'GuardedSwiftyJSON'

## Contributing

Pull requests and issues are welcomed.
