/** # Function Composition
 Collection of functions that allows composing functions together.
 Custom operators are optional, however they simplify the usage greatly.
 References:
 - https://www.pointfree.co  - great series on functional programming in Swift
 - https://fsharpforfunandprofit.com/series/thinking-functionally/ - series of articles on functional programming concepts
 - https://github.com/pointfreeco/
 - https://github.com/pointfreeco/swift-overture - a library for function composition. It covers all the concepts tackled in this document and more
 - https://github.com/pointfreeco/swift-prelude - adds custom operators to Overture and more
 */

/// # Precedence groups

precedencegroup ForwardApplication {
    associativity: left
}

precedencegroup EffectfulComposition {
    associativity: left
    higherThan: ForwardApplication
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication, EffectfulComposition
}

precedencegroup SingleTypeComposition {
    associativity: right
    higherThan: ForwardApplication
}

/// # Common code for examples

func incr(a: Int) -> Int { a + 1 }
func square(a: Int) -> Int { a * a }




/** # Compute - function application
 - Pass parameters to a function while eliminating intermediate values
 https://www.pointfree.co/episodes/ep1-functions
*/

func with<A, B>(_ a: A, _ f: (A) -> B) -> B {
    f(a)
}

func with<A>(_ a: inout A, _ f: (inout A) -> Void) -> A {
    f(&a)
    return a
}

func with<A: AnyObject>(_ a: A, _ f: (A) -> Void) -> A {
    f(a)
    return a
}

/// Pipe forward operator
infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
    with(a, f)
}

func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
  with(&a, f)
}

func |> <A: AnyObject>(_ a: A, _ f: (A) -> Void) -> A {
    f(a)
    return a
}

with(2, incr) // 3
2 |> incr |> square // 9




/** # Forward composition of functions (semigroupoid)
 https://www.pointfree.co/episodes/ep1-functions
*/
func compose<A, B, C>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C
) -> (A) -> C {
    { a in g(f(a)) }
}

/// Forward compose operator
infix operator >>>: ForwardComposition

func >>><A, B, C>(
    f: @escaping (A) -> B,
    g: @escaping (B) -> C
) -> (A) -> C {
    compose(f, g)
}

let incrAndStringify = incr >>> String.init // Int -> String

2 |> incrAndStringify // "3"
2 |> incr >>> square >>> String.init // "9"

// Example: optimize multiple `map` transformations
// [2, 4, 8].map(square).map(incrAndStringify)
[2, 4, 8].map(square >>> incrAndStringify) // ["5", "7", "65"]




/** # Single type function composition (semigroup)
 - Forward composition of functions constrained to a single type
 */

infix operator <>: SingleTypeComposition

func <> <A>(
    _ f: @escaping (A) -> A,
    _ g: @escaping (A) -> A
) -> (A) -> A {
    compose(f, g)
}

func <> <A: AnyObject>(
    _ f: @escaping (A) -> Void,
    _ g: @escaping (A) -> Void
) -> (A) -> Void {
    { a in
        f(a)
        g(a)
    }
}

func <> <A>(
    _ f: @escaping (inout A) -> Void,
    _ g: @escaping (inout A) -> Void
) -> (inout A) -> Void {
    { a in
        f(&a)
        g(&a)
    }
}

/// # Example: composable configuration of object using forward composition

    import UIKit

    func decimalStyle(formatter: NumberFormatter) -> Void {
        formatter.numberStyle = .decimal
    }

    func currencyStyle(formatter: NumberFormatter) -> Void {
        formatter.numberStyle = .currency
        formatter.roundingMode = .down
    }

    func noDecimalPointStyle(formatter: NumberFormatter) -> Void {
        formatter.maximumFractionDigits = 0
    }

    let currencyFormatter = NumberFormatter() |> currencyStyle <> noDecimalPointStyle

    currencyFormatter.string(from: 2.1) // "$2"




/** # Compose functions with side effects
 https://www.pointfree.co/episodes/ep2-side-effects
*/

func composeWithEffects<A, B, C, E>(
    _ f: @escaping (A) -> (B, E),
    _ g: @escaping (B) -> (C, E),
    _ h: @escaping (E, E) -> E // Effects accumulator function
) -> (A) -> (C, E) {
    { a in
        let (b, effects) = f(a)
        let (c, moreEffects) = g(b)
        return (c, h(effects, moreEffects))
    }
}

/// "fish" operator
infix operator >=>: EffectfulComposition

func >=> <A, B, C, E>(
    f: @escaping (A) -> (B, [E]),
    g: @escaping (B) -> (C, [E])
) -> (A) -> (C, [E]) {
    composeWithEffects(f, g, +)
}

let incrWithLogs: (Int) -> (Int, [String]) = incr >>> { ($0, ["Computed: \($0)"]) }

2 |> incrWithLogs >=> incrWithLogs // (4, ["Computed: 3", "Computed: 4"])

2
    |> incrWithLogs
    >=> incr
    >>> incrWithLogs
// (5, ["Computed: 3", "Computed: 5"])




/** # `inout` function transformation
 - Functions of type `(A) -> A` and `(inout A) -> Void` are interchangeable
 - Functions `(A) -> A` compose well with other functions, so transforming inout functions may come in handy
 */

func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    { a in a = f(a) }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    { a in
        var copy = a
        f(&copy)
        return copy
    }
}




/** # Curry
 - Named after Haskell Curry.
 - Break multi arguments function into smaller one-argument functions: transform `(A, B) -> C` to `(A) -> (B) -> C`.
 - Allows to compose functions, eg. for partial application technique
 https://www.pointfree.co/episodes/ep5-higher-order-functions
 https://fsharpforfunandprofit.com/posts/currying/
 https://fsharpforfunandprofit.com/posts/partial-application/
 */

func curry<A, B, C>(
    _ f: @escaping (A, B) -> C
) -> (A) -> (B) -> C {
    { a in { b in f(a, b) } }
}

/// `curry` that takes 3 arguments
func curry<A, B, C, D>(
    _ f: @escaping (A, B, C) -> D
) -> (A) -> (B) -> (C) -> D {
    { a in { b in { c in f(a, b, c) } } }
}

func uncurry<A, B, C>(
    _ f: @escaping (A) -> (B) -> C
) -> (A, B) -> C {
    { a, b in f(a)(b) }
}

String.init(data:encoding:) // (Data, Encoding) -> String?
curry(String.init(data:encoding:)) // (Data) -> (Encoding) -> String?




/** # Flip
 - Change order of functions arguments: transform `(A) -> (B) -> C` to `(B) -> (A) -> C`
 https://www.pointfree.co/episodes/ep5-higher-order-functions
 */

func flip<A, B, C>(
    _ f: @escaping (A) -> (B) -> C
) -> (B) -> (A) -> C {
    { b in { a in f(a)(b) } }
}

func flip<A, C>(
    _ f: @escaping (A) -> () -> C
) -> () -> (A) -> C {
    { { a in f(a)() } }
}

// Example: partial function application - fix some parameters of the function
String.init(data:encoding:) // (Data, Encoding) -> String?
curry(String.init(data:encoding:)) // (Data) -> (Encoding) -> String?
flip(curry(String.init(data:encoding:))) // (Encoding) -> (Data) -> String?

let utf8String = flip(curry(String.init(data:encoding:)))(.utf8) // (Data) -> String?
let emptyString = utf8String(Data()) // ""

// Example: Compose a static method of a type
String.uppercased(with:) // (String) -> (Locale?) -> String
flip(String.uppercased(with:)) // (Locale?) -> (String) -> String
let uppercasedForEnglishLocale = flip(String.uppercased(with:))(.init(identifier: "en")) // partial function application

uppercasedForEnglishLocale("Hello") // "HELLO"

// Example: Method without arguments
String.uppercased // (String) -> () -> String
flip(String.uppercased) // () -> (String) -> String

flip(String.uppercased)()("Hello") // "HELLO"

/** # Zurry
 Curry for zero argument function. Just for nicer looking composition.
 */

func zurry<A>(_ f: () -> A) -> A {
    f()
}

flip(String.uppercased) // () -> (String) -> String
let uppercase = zurry(flip(String.uppercased)) // (String) -> String

uppercase("Hello") // "HELLO"




/** # Free versions of Swift's built-in higher order functions
 - `Array.map` does not compose well using `curry` or `flip`
 - On the other hand a free version of `map` does
 https://www.pointfree.co/episodes/ep5-higher-order-functions
 */

func map<A, B>(
    _ f: @escaping (A) -> B
) -> ([A]) -> [B] {
    { $0.map(f) }
}

map(incr) // [Int] -> [Int]

map(incr) >>> map(square) >>> map(String.init) // [Int] -> [String]
// or
map(incr >>> square >>> String.init) // [Int] -> [String]

func flatMap<A, B>(
    _ f: @escaping (A) -> [B]
) -> ([A]) -> [B] {
    { $0.flatMap(f) }
}

func filter<A>(
    _ f: @escaping (A) -> Bool
) -> ([A]) -> [A] {
    { $0.filter(f) }
}

func reduce<A, R>(
    _ nextPartialResult: @escaping (R, A) -> R
) -> (R) -> ([A]) -> R {
    { initialResult in
        { collection in
            collection.reduce(initialResult, nextPartialResult)
        }
    }
}

// Example: composable and reusable transformations
let greaterThanTen = filter { $0 > 10 } // ([Int]) -> [Int]

let composableTransformation: ([Int]) -> [Int] =
    filter { $0.isMultiple(of: 2) }
    >>> map(incr >>> square)
    >>> greaterThanTen

[2, 4, 8] |> composableTransformation // [25, 81]
