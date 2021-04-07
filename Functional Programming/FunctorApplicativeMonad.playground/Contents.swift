/** # Functors, Applicatives and Monads in Swift
 https://mokacoding.com/blog/functor-applicative-monads-in-pictures/
 */

import Foundation

enum Box<T> {
    case some(T)
    case empty
}



/** # FUNCTOR - apply a function to a value wrapped in a context
 - functor is a type that implements `map` function. Types implementing `map` in Swift Standard Library are: Optional, Collection, Result
 - it describes how to apply function to a wrapped value.
 */

extension Box {

    func map<U>(_ f: @escaping (T) -> U) -> Box<U> {
        switch self {
        case let .some(t):
            return .some(f(t))
        case .empty:
            return .empty
        }
    }

}

let intBox = Box.some(7)
intBox.map { $0 + 2 } // .some(9)

let emptyBox: Box<Int> = .empty
emptyBox.map { $0 + 2 } // empty



/** # APPLICATIVE - apply a wrapped function to a wrapped value
 - applicative is a type that implements `apply` function
 - Swift Standard Library does not support applicatives, however existing types can be extended to support it
 */

extension Box {

    func apply<U>(_ f: Box<(T) -> U>) -> Box<U> {
        switch f {
        case let .some(transform):
            return self.map(transform)
        case .empty:
            return .empty
        }
    }

}

/// - Optional
extension Optional {
    func apply<U>(_ f: ((Wrapped) -> U)?) -> U? {
        switch f {
        case let .some(transform):
            return self.map(transform)
        case .none:
            return .none
        }
    }
}

let someInt: Int? = 7

let someF: ((Int) -> Int)? = { $0 + 2 }
let noneF: ((Int) -> Int)? = nil

someInt.apply(someF) // 9
someInt.apply(noneF) // nil

/// - Array
extension Array {
    func apply<U>(_ fs: [(Element) -> U]) -> [U] {
        //        var result: [U] = []
        //        for f in fs {
        //            for element in self.map(f) {
        //                result.append(element)
        //            }
        //        }
        //        return result

        // or just:
        fs.flatMap { f in self.map(f) }
    }
}

[2, 4, 8, 16].apply( [{ number in number * 2 }, { number in number / 2 }] )
// [4, 8, 16, 32, 1, 2, 4, 8]



/** # MONAD - apply a function that returns a wrapped value to a wrapped value
 - basically monad is a type that implements `flatMap` function. Types implementing `flatMap` in Swift Standard Library: Optional, Collection, Result
 */

extension Box {

    func flatMap<U>(_ f: (T) -> Box<U>) -> Box<U> {
        switch self {
        case .some(let t):
            return f(t)
        case .empty:
            return .empty
        }
    }

}

let stringBox: Box<String> = .some("Swift")

stringBox.flatMap { .some("\($0) is awesome!") } // some("Swift is awesome!")
stringBox.flatMap { _ in .some(1) } // some(1)

// ----

// `Result` type is generic over two types: `Success` and `Failure`.
// It defines two variants of map function: one for success case (`map`), one for failure case (`mapError`)
// and two variants of flatMap function: for success (`flatMap`) and for failure (`flatMapError`)

let success = Result<Int, Error>.success(7)
let failure = Result<Int, Error>.failure(NSError(domain: NSCocoaErrorDomain, code: 33))

success.map { $0 + 3 } // success(10)
success.mapError { _ in NSError(domain: NSURLErrorDomain, code: 44) } // success(7)
success.flatMap { _ in Result<String, Error>.success("1") } // success("1")
success.flatMapError { _ in Result<Int, Error>.success(1) } // success(7)

failure.map { $0 + 3 } // ...NSCocoaErrorDomain
failure.mapError { _ in NSError(domain: NSURLErrorDomain, code: 44) } // ...NSURLErrorDomain
failure.flatMap { _ in Result<String, Error>.success("1") } // ...NSCocoaErrorDomain
failure.flatMapError { _ in Result<Int, Error>.success(1) } // success(1)
