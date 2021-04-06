/// Indirect storage with copy on write

protocol Drawable {
    func draw()
}

/**
 Existential that does not fit in existential container's inline buffer.

 When `LineWithHeapAlloacation` is stored as protocol ("existential") type `Drawable`, its properties are allocated on heap.
 Protocol ("existential") type values are stored in existential containers. Existential containers have inline buffer which size is 3 words.
 `LineWithHeapAlloacation` has 4 properties, each of 1 word size, so it wouldn't fit in inline buffer (on 64 bits architecture 1 word = 64 bits and `Double` = 64 bits).
 Therefore it is allocated on heap and reference to it is stored in inline buffer.
 */
struct LineWithHeapAlloacation: Drawable {

    var x1, y1, x2, y2: Double

    func draw() {
        print(x1, y1, x2, y2)
    }

}

/**
 Every `LineWithHeapAlloacation` value use separate heap allocation for storage
 */
let zero = LineWithHeapAlloacation(x1: 0.0, y1: 0.0, x2: 0.0, y2: 0.0)
let linesOnHeap: [Drawable] = [zero, zero, zero]

/**
 Limit the heap allocation by using "copy on write" technique.

 Let's store large struct properties indirectly, using a reference type.
 A reference size is 1 word, so it fits in existential container's inline buffer.
 Every value copy would share storage as long as it is not mutated.
*/

struct Line: Drawable {

    private class LineStorage {

        var x1, y1, x2, y2: Double

        init(x1: Double, y1: Double, x2: Double, y2: Double) {
            self.x1 = x1
            self.y1 = y1
            self.x2 = x2
            self.y2 = y2
        }

        convenience init(_ storage: LineStorage) {
            self.init(x1: storage.x1, y1: storage.y1, x2: storage.x2, y2: storage.y2)
        }

    }

    private var storage: LineStorage

    init(x1: Double, y1: Double, x2: Double, y2: Double) {
        storage = LineStorage(x1: x1, y1: y1, x2: x2, y2: y2)
    }

    func draw() {
        print(storage.x1, storage.y1, storage.x2, storage.y2)
    }

    mutating func move() {
        // check the `storage` reference count. If it is greater than 1 then create a copy.
        if isKnownUniquelyReferenced(&storage) == false {
            storage = LineStorage(storage)
        }
        // some mutation
        storage.x1 = 0.0
        storage.y1 = 0.0
    }

}

let one = Line(x1: 0.0, y1: 0.0, x2: 1.0, y2: 0.0)
let lines = [one, one, one]
