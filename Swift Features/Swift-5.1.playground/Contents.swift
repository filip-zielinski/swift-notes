/// # Features introduced with Swift 5.1

import UIKit

/** # SE-0255 Implicit returns from single-expression functions
 https://github.com/apple/swift-evolution/blob/master/proposals/0255-omit-return.md
 */

func makeDouble() -> Double {
    3.0 // new
//    return 3.0 // old
}
var double: Double {
    24.0
}

print(makeDouble())
print(double)



/** # SE-0068 Expanding Swift Self to class members and value types (Universal Self)
 https://github.com/apple/swift-evolution/blob/master/proposals/0068-universal-self.md
 */

struct MyStruct {
    static func staticMethod() {}

    func instanceMethod() {
        Self.staticMethod() // new
        MyStruct.staticMethod() // old
        type(of: self).staticMethod()
    }
}

// Inheritance
class UsersManager {
    class var maxUsersCount: Int { 5 }

    static func printMaxUsersCount() {
        print(Self.maxUsersCount)   // new
//        print(UsersManager.maxUsersCount) // old
    }
}

class ShopClientManager: UsersManager {
    override class var maxUsersCount: Int { 1 }
}

UsersManager.printMaxUsersCount() // 5
ShopClientManager.printMaxUsersCount() // 1



/** #SE-0254 Static and class subscripts
 https://github.com/apple/swift-evolution/blob/master/proposals/0254-static-subscripts.md
 */

enum IntToString {
    static var values: [Int: String] = [
        0: "Zero",
        1: "One",
        2: "Two"
    ]

    static subscript(_ number: Int) -> String {
        get { values[number] ?? "A lot" }
        set { values[number] = newValue }
    }
}

print(IntToString[1])

IntToString[3] = "Three"
print(IntToString[3]) // 3.0



/// # Warnings for ambiguous none cases

enum BorderStyle {
    case solid(thickness: Int)
    case dotted
    case none
}

let border: BorderStyle? = .none // warning ->



/// # Matching optional enums against non-optionals

switch border { // new
case .solid: break
case .dotted: break
case .some(.none): break
case .none: break
}

switch border { // old
case .some(.solid): break
case .some(.dotted): break
case .some(.none): break
case .none: break
}



/** # SE-0244 Opaque Result Types
 A function or method with an opaque return type hides its return value’s type information. It lets you keep your implementation details private.
 https://github.com/apple/swift-evolution/blob/master/proposals/0244-opaque-result-types.md
 https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html
 */

// Protocols with Self or associated type requirements (`some` )
func makeInt() -> some Equatable {
    Int.random(in: 1...10)
}

makeInt() == makeInt()

protocol APIRequest {
    var endpoint: String { get }
    func perform() -> String
}

extension APIRequest {
    func perform() -> String {
        "Performing request to endpoint \(endpoint)"
    }
}

protocol Initializable {
    init() // for generic examples
}

struct LoginRequest: APIRequest, Initializable {
    let endpoint: String = "/login"
}

struct UpdateUserRequest: APIRequest, Initializable {
    let endpoint: String = "/putUser"
}

func makeRequest() -> some APIRequest {
    return LoginRequest()
//     Invalid:
//    if true {
//        return LoginRequest()
//    }
//    return UpdateUserRequest()

}

let req1 = makeRequest() // function implementation decides about return type

// On the other hand - generic approach
func genericMakeRequest<T: APIRequest & Initializable>() -> T {
    return T()
}

let req2: UpdateUserRequest = genericMakeRequest() // caller decides about return type
let req3: LoginRequest = genericMakeRequest()

/// **Hide implementation details**
struct DoubleRequest<T: APIRequest, U: APIRequest>: APIRequest {
    var req1: T
    var req2: U
    let endpoint: String
    init(req1: T, req2: U) {
        endpoint = ""
        self.req1 = req1
        self.req2 = req2
    }

    func perform() -> String {
        "\(req1.perform()) \(req2.perform())"
    }
}

func makeDoubleRequest<T: APIRequest, U: APIRequest>(_ req1: T, _ req2: U) -> some APIRequest {
    let request = DoubleRequest(req1: req1, req2: req2) // Type is DoubleRequest<T, U>
    return request // This underlying concrete type is hidden
}

let doubleRequest = makeDoubleRequest(req1, req2) // req1 is `some APIRequest`, req2 is `UpdateUserRequest`. Result is `some APIRequest`
let tripleRequest = makeDoubleRequest(doubleRequest, req3) // req3 is `LoginRequest`



/** # SE-0240 Ordered Collection Diffing
 https://github.com/apple/swift-evolution/blob/master/proposals/0240-ordered-collection-diffing.md
 Calculates the differences between two ordered collections – what items to remove and what items to insert. Used with any ordered collection that contains Equatable elements
 */

let scores1 = [100, 101, 102]
let scores2 = [100, 101, 202, 203]

let diff = scores2.difference(from: scores1)
print(diff)
dump(diff)

print(scores1.applying(diff)! == scores2) // true

var scores3 = scores1

// apply diff manually
for change in diff {
    switch change {
    case .remove(let offset, _, _):
        scores3.remove(at: offset)
    case .insert(let offset, let element, _):
        scores3.insert(element, at: offset)
    }
}
print(scores3)



/** # SE-0245 Add an Array Initializer with Access to Uninitialized Storage
 https://github.com/apple/swift-evolution/blob/master/proposals/0245-array-uninitialized-initializer.md
 */

let randomNumbers = Array<Int>(unsafeUninitializedCapacity: 10) { buffer, initializedCount in
    for x in 0..<10 {
        buffer[x] = Int.random(in: 0...10)
    }

    initializedCount = 10
}

let randomNumbers2 = (0...9).map { _ in Int.random(in: 0...10) }
    //easier to read, but less efficient



/** # SE-0258 Property Wrappers
 https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md
 automatically wrap property values using specific types
 */

@propertyWrapper
class Capitalized {
    private(set) var value: String
    var wrappedValue: String {
        get { return value.capitalized }
        set { value = newValue }
    }
    init(wrappedValue: String) {
        self.value = wrappedValue
    }
}



/** # SE-0242 Synthesize default values for the memberwise initializer
 https://github.com/apple/swift-evolution/blob/master/proposals/0242-default-values-memberwise.md
 */

struct User {
    @Capitalized var name: String
    var postsCount: Int = 0 // must be `var`
}

let noob = User(name: "newbie")
let bodhisattva = User(name: "1337-man", postsCount: 9999)
print(noob.name) // "Newbie"

/// Example `UserDefault` property wrapper
@propertyWrapper
struct UserDefault<T> {
  let key: String
  let defaultValue: T

  var wrappedValue: T {
    get {
      return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
    }
    set {
      UserDefaults.standard.set(newValue, forKey: key)
    }
  }
}

let a = UserDefault(key: "FOO_FEATURE_ENABLED", defaultValue: false)

enum GlobalSettings {
  @UserDefault(key: "FOO_FEATURE_ENABLED", defaultValue: false)
  static var isFooFeatureEnabled: Bool

  @UserDefault(key: "BAR_FEATURE_ENABLED", defaultValue: false)
  static var isBarFeatureEnabled: Bool
}




/** # SE-0261 Identifiable Protocol
 https://github.com/apple/swift-evolution/blob/master/proposals/0261-identifiable.md

 public protocol Identifiable {

     /// A type representing the stable identity of the entity associated with `self`.
     associatedtype ID : Hashable

     /// The stable identity of the entity associated with `self`.
     var id: Self.ID { get }
 }

 extension Identifiable where Self: AnyObject {
     var id: ObjectIdentifier {
         return ObjectIdentifier(self)
     }
 }
 */

class ClassWithID: Identifiable {}

let classWithID = ClassWithID()
print(classWithID.id)



/** # SE-XXXX Function builders (draft proposal)
 * https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md

 * https://blog.vihan.org/swift-function-builders/
 * Function builers sound like they create functions but they can create any value.
   A function builders is something you can attach to a class which makes it easier to produce an object that is composed of more objects
 */

@_functionBuilder
class UIViewFunctionBuilder {
    static func buildBlock(_ children: UIView...) -> UIView {
        let newView = UIView()

        for view in children {
            newView.addSubview(view)
        }

        return newView
    }
}

func MakeLabel(with text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    return label
}

@UIViewFunctionBuilder
func buildView() -> UIView {
    MakeLabel(with: "Hello, World!")
    MakeLabel(with: "My name is John Doe!")
}

let view: UIView = buildView()



/** # Swift 5.1 features behind SwiftUI
 */

import SwiftUI

struct ContentView: View {
    var body: some View { // Opaque Result Type
//        print("aaa")
        /*return*/ Text("Hello World") // Implicit returns from single-expression functions, Function builder
    }
}



/**
 Sources:
 * https://swift.org/blog/swift-5-1-released/
 * https://www.hackingwithswift.com/articles/182/whats-new-in-swift-5-1
 * https://www.swiftbysundell.com/articles/the-swift-51-features-that-power-swiftuis-api/
 */
