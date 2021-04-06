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

func quickSortWithPivotAtFront<T: Comparable>(_ array: [T]) -> [T] {
    if array.count < 2 {
        return array
    }
    let pivot = array[0]
    let less = array.filter { $0 < pivot }
    let more = array.filter { $0 > pivot }

    return quickSortWithPivotAtFront(less) + [pivot] + quickSortWithPivotAtFront(more)
}

func quickSortRandomPivot<T: Comparable>(_ array: [T]) -> [T] {
    guard array.count > 1,
          let pivot = array.randomElement()
    else { return array }
    let less = array.filter { $0 < pivot }
    let more = array.filter { $0 > pivot }

    return quickSortRandomPivot(less) + [pivot] + quickSortRandomPivot(more)
}

func quickSortMiddlePivot<T: Comparable>(_ array: [T]) -> [T] {
    guard array.count > 1,
          let pivot = array.middle
    else { return array }
    let less = array.filter { $0 < pivot }
    let more = array.filter { $0 > pivot }

    return quickSortMiddlePivot(less) + [pivot] + quickSortMiddlePivot(more)
}

// ----

import UIKit

let measureSerialQueue = DispatchQueue(label: "measureQueue")

func measure<A>(_ name: String = "", on queue: DispatchQueue = measureSerialQueue, _ block: () -> A) {
    queue.sync {
        let startTime = CACurrentMediaTime()
        block()
        let timeElapsed = CACurrentMediaTime() - startTime
        print("\(name) - \(timeElapsed)")
    }
}

func testArray(size: Int) -> [Int] {
    (0...size).map {_ in Int.random(in: 0...999999) }
}

let array = testArray(size: 10000)

measure("PivotAtFront") { quickSortWithPivotAtFront(array) }
measure("RandomPivot") { quickSortRandomPivot(array) }
measure("PivotInTheMiddle") { quickSortMiddlePivot(array) }
measure("Swift sorted") { array.sorted() }
