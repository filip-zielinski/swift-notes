/**
 #Stack
 You can only:
 - push to add a new element to the top of the stack
 - pop to remove the element from the top
 - peek at the top element without popping it off

 LIFO (last-in, first-out) order
 */

import Foundation

struct Stack<T> {

    var isEmpty: Bool { storage.isEmpty }
    var count: Int { storage.count }

    private var storage: [T] = []

    mutating func push(_ element: T) {
        storage.append(element)
    }

    mutating func pop() -> T? {
        storage.popLast()
    }

    func peek() -> T? {
        return storage.last
    }

}

/// #Example

var stack = Stack<Int>()

print("peek: \(stack.peek())")

print("push 1")
stack.push(1)

print("peek: \(stack.peek())")

print("push 2")
stack.push(2)
print("peek: \(stack.peek())")

print("pop: \(stack.pop())")
print("pop: \(stack.pop())")
print("pop: \(stack.pop())")

print("count: \(stack.count)")

print("push 3")
stack.push(3)

print("push 4")
stack.push(4)
print("count: \(stack.count)")
