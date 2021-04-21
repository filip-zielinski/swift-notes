extension Array {

    var middle: Element? {
        guard let middleIndex = middleIndex else { return nil }
        return self[middleIndex]
    }

    var middleIndex: Int? {
        if isEmpty { return nil }
        if count < 2 { return startIndex }
        return startIndex + (endIndex - 1) / 2
    }
}

let a: [Int] = []
a.middleIndex               // nil
[2].middleIndex             // 0
[2,3].middleIndex           // 0
[2,3,4].middleIndex         // 1
[1,3,4,5].middleIndex       // 1
[1,3,4,5].middle            // 3
[2,3,4,5,6].middleIndex     // 2


extension Array where Element: Comparable {

    func simpleSearch(element: Element) -> Element? {
        first { $0 == element }
    }

    /// - array: sorted array
    func bSearch(element: Element) -> Element? {
        guard isEmpty == false else { return nil }
        guard count > 1 else { return element == self[0] ? self[0] : nil }
        guard let middleIndex = middleIndex else { return nil }
        if element == self[middleIndex] { return self[middleIndex] }
        if element < self[middleIndex] { return Array(self[0..<middleIndex]).bSearch(element: element) }
        return Array(self[(middleIndex + 1)...]).bSearch(element: element)
    }

}

let testArray = [1,3,4,5,6,7,8,10,20,22,25,44]

print(
    testArray.allSatisfy { testArray.bSearch(element: $0) != nil }
) // true

print(
    testArray.bSearch(element: 9) == nil
) // true
