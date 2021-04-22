/** # Selection sort
 Simple but slow sorting algorithm.
 -  complexity O(n2)
 */

extension Array {

    /**
     For every element in array:
     1. Find smallest element in array
     2. Swap it with current iteration element
     3. return sorted array
    */
    func selectionSortedWithSwap(areInIncreasingOrder order: (Element, Element) -> Bool) -> Self {
        var copy = self

        for index in copy.indices {
            guard let smallestElementOffset = copy[index..<copy.endIndex]
                    .enumerated()
                    .min(by: { a, b in order(a.element, b.element) })?
                    .offset
            else { break }

            copy.swapAt(index, index + smallestElementOffset)
        }

        return copy
    }

    /**
     Create empty `result` array
     For every element in array:
     1. Find smallest element in array
     2. Move it to `result` array
     3. return `result` array
     */
    func selectionSortedWithoutSwap(areInIncreasingOrder order: (Element, Element) -> Bool) -> Self {
        var result: [Element] = []
        var copy = self

        while let smallest = copy.enumerated().min(by: { a, b in order(a.element, b.element) }) {
            result.append(smallest.element)
            copy.remove(at: smallest.offset)
        }

        return result
    }

}

[1, 1, 3, 2, 1, 7, 4, 5].selectionSortedWithoutSwap(areInIncreasingOrder: <)
// [1, 1, 1, 2, 3, 4, 5, 7]

[1, 1, 3, 2, 1, 7, 4, 5].selectionSortedWithSwap(areInIncreasingOrder: <)
// [1, 1, 1, 2, 3, 4, 5, 7]
