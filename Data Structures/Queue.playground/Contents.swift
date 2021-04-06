/**
 #Queue
 - list where you can only insert new items at the back and remove items from the front
 - FIFO (first-in, first-out) order
 */

import Foundation

struct Queue<T> {

    var isEmpty: Bool { count == 0 }
    var count: Int { storage.count - head }

    private var storage: [T?] = []
    private var head: Int = 0 // number of empty elements in front of storage array
    private let queue: DispatchQueue = DispatchQueue(label: "Queue \(UUID())", attributes: .concurrent)

    private let smallQueueSize = 32
    private let percentageOfEmptySpotsForResize: Float = 0.6

    @discardableResult
    mutating func enqueue(_ element: T) -> T {
        queue.sync(flags: .barrier) {
            storage.append(element)
            return element
        }
    }

    /// Simple removing first element from the storage array would shift all other elements in memory which is O(n) operation.
    /// To avoid shifting elements let's mark the element as "empty" (nullify it) and keep track of number of empty elements in front of storage.
    mutating func dequeue() -> T? {
        return queue.sync(flags: .barrier) {
            guard head <= storage.count,
                  storage.indices.contains(head),
                  let element = storage[head]
            else { return nil }

            storage[head] = nil
            head += 1

            // Periodically reuse empty spots from the front of the storage.
            // Shifting elements is O(n) operation. `dequeue` will on average perform with O(1),
            // but sometimes when it is resized it would be O(n).
            resizeIfNeeded()

            return element
        }
    }

    func front() -> T? {
        return  queue.sync {
            guard isEmpty == false else { return nil }
            return storage[head]
        }
    }

    func tail() -> T? {
        return  queue.sync {
            return storage.last?.flatMap { $0 }
        }
    }

    /// To reuse empty spots, periodically shift all elements to the front of the storage. For example:
    /// `[nil, nil, nil, nil, A, B]` => `[A, B, nil, nil, nil, nil]`
    private mutating func resizeIfNeeded() {
        guard storage.count > smallQueueSize, // skip when queue is short
              case let percentageOfEmptySpots = Float(head) / Float(storage.count),
              percentageOfEmptySpots > percentageOfEmptySpotsForResize // continue when there are enough empty spots
        else { return }

        queue.sync(flags: .barrier) {
            storage.removeFirst(head)
            head = 0
        }
    }

}

extension Queue: ExpressibleByArrayLiteral {

    init(arrayLiteral elements: T...) {
        self.init()
        elements.forEach { enqueue($0) }
    }

}

extension Queue: Equatable where T: Equatable {

    static func == (lhs: Queue<T>, rhs: Queue<T>) -> Bool { lhs.storage == rhs.storage }

}

var queue = Queue<Int>()

print("enqueue \(queue.enqueue(1))")
print("enqueue \(queue.enqueue(2))")
print("enqueue \(queue.enqueue(3))")

print("dequeue: \(queue.dequeue())")

print("enqueue \(queue.enqueue(4))")

print(queue.front())
print(queue.tail())

print("dequeue: \(queue.dequeue())")
print("dequeue: \(queue.dequeue())")
print("dequeue: \(queue.dequeue())")
print("dequeue: \(queue.dequeue())")

print("enqueue \(queue.enqueue(4))")
print("enqueue \(queue.enqueue(5))")
print("dequeue: \(queue.dequeue())")
print("dequeue: \(queue.dequeue())")
print("dequeue: \(queue.dequeue())")
print("dequeue: \(queue.dequeue())")
