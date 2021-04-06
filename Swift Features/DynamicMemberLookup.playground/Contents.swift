/**
 # Dynamic Member Lookup
 - provide "dot" syntax for arbitrary names which are resolved at runtime - in a completely type safe way
 https://github.com/apple/swift-evolution/blob/master/proposals/0195-dynamic-member-lookup.md
 */

import Foundation

@dynamicMemberLookup
class Number {

    let name = "Number Object"
    subscript(dynamicMember prop: String) -> String {
        return "\(name): \(prop)"
    }

    subscript(dynamicMember prop: String) -> Int? {
        return Int(prop)
    }

    subscript<T>(dynamicMember prop: String) -> (T...) -> Void {
        return { (values: T...) in
            values.forEach { value in
                print("\(prop): \(value)")
            }
        }
    }
}

let two: Int? = Number().2 // 2
let three: Int? = Number().three // nil (`Int("three") == nil`)
let four: String = Number().four // "four"

let f: (String...) -> Void = Number().x
f("thing", "another thing")

// ----

@dynamicMemberLookup
struct List<T> {
    private var list: [String: T] = [:]
    subscript(dynamicMember prop: String) -> T? {
        get {
            return list[prop]
        }
        set {
            list[prop] = newValue
        }
    }
}

var myList = List<String>()

myList.element = "some element"
let someElement = myList.element // "some element"

// ----

/**
 Use dynamicMember subscript to get access to JSON object properties using "dot" syntax.
 DynamicJSON project takes this idea further: https://github.com/saoudrizwan/DynamicJSON
 */
@dynamicMemberLookup
enum JSON: Equatable {

    case dictionary([String: JSON])
    case array([JSON])
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    subscript(dynamicMember key: String) -> JSON? {
        guard case .dictionary(let dictionary) = self else { return nil }
        return dictionary[key]
    }

    subscript(index: Int) -> JSON? {
        guard case .array(let array) = self,
              array.indices.contains(index)
        else { return nil }

        return array[index]
    }

    subscript(key: String) -> JSON? {
        guard case .dictionary(let dictionary) = self else { return nil }
        return dictionary[key]
    }

    var dictionary: [String: JSON]? {
        guard case .dictionary(let dictionary) = self else { return nil }
        return dictionary
    }

    var array: [JSON]? {
        guard case .array(let array) = self else { return nil }
        return array
    }

    var string: String? {
        guard case .string(let string) = self else { return nil }
        return string
    }

    var int: Int? {
        guard case .int(let number) = self else { return nil }
        return number
    }

    var double: Double? {
        guard case .double(let number) = self else { return nil }
        return number
    }

    var bool: Bool? {
        guard case .bool(let bool) = self else { return nil }
        return bool
    }

    // `.allowFragments` option allows top-level objects that are not an NSArray or NSDictionary
    init?(data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: options),
              let json = JSON(object)
        else { return nil }

        self = json
    }

    init?(_ object: Any) {
        if let data = object as? Data,
           let json = JSON(data: data) {
            self = json
        } else if let dictionary = object as? [String: Any] {
            self = .dictionary(dictionary.compactMapValues(JSON.init))
        } else if let array = object as? Array<Any> {
            self = .array(array.compactMap(JSON.init))
        } else if let string = object as? String {
            self = .string(string)
        } else if let number = object as? Int {
            self = .int(number)
        } else if let number = object as? Double {
            self = .double(number)
        } else if let bool = object as? Bool {
            self = .bool(bool)
        } else if let json = object as? JSON {
            self = json
        } else {
            return nil
        }
    }
}

let myJson = JSON(
    [
        "address": [
            "city": "Oslo",
            "zone": 4
        ],
        "name": "Johan",
        "favoriteItems": [100, 120, 250]
    ]
)

print(myJson?.name) // "Johan"
print(myJson?.address?.city) // "Oslo"
print(myJson?.address?.zone) // 4
print(myJson?.favoriteItems) // [100, 120, 250]
