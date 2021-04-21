protocol Fibonacci {
    static func fibonacci(n: Int) -> Int
}

struct Recursive: Fibonacci {

    // Easy to understand, but sub-optimal: some elements are calculated more than once
    static func fibonacci(n: Int) -> Int {
        if n < 2 { return n }
        return fibonacci(n: n - 1) + fibonacci(n: n - 2)
    }

}

struct Dynamic: Fibonacci {

    static func fibonacci(n: Int) -> Int {
        var partial: [Int] = Array.init(repeating: 0, count: max(2, n + 1))

        partial[0] = 0
        partial[1] = 1

        guard n > 1 else { return partial[n] }

        for i in 2...n {
            partial[i] = partial[i - 1] + partial[i - 2]
        }

        return partial[n]
    }

}

// ----

func assertEqual(value: Int, _ input1: (Int) -> Int, _ input2: (Int) -> Int) -> Bool {
    input1(value) == input2(value)
}

print(
    (0...10).allSatisfy { assertEqual(value: $0, Recursive.fibonacci, Dynamic.fibonacci) }
) // true
