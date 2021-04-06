/**
 #Strategy
 - behavioral design pattern
 - allows to select one of a family of algorithms at runtime
 - isolates the implementation details of an algorithm from the code that uses it
 - helps to replace inheritance with composition
 - Open/Closed Principle. New strategies can be introduced without having to change the context
 */

class Duck {

    var flyingStrategy: FlyingStrategy
    var quackStrategy: QuackStrategy

    init(flyingStrategy: FlyingStrategy, quackStrategy: QuackStrategy) {
        self.flyingStrategy = flyingStrategy
        self.quackStrategy = quackStrategy
    }

    /// for subclass to implement
    func render() {
        fatalError()
    }

    func doFly() {
        flyingStrategy.fly()
    }

    func doQuack() {
        quackStrategy.quack()
    }

}

/// defines "flying" family of algorithms
protocol FlyingStrategy { ///  or`FlyingBehavior`
    func fly()
}

/// defines "quacking" family of algorithms
protocol QuackStrategy { /// or `QuackBehavior`
    func quack()
}

struct DoesFly: FlyingStrategy {
    func fly() {
        print("Watch me flying!")
    }
}

struct DoesNotFly: FlyingStrategy {
    func fly() {
        print("<<<Nothing>>>")
    }
}

struct SqueaksStrategy: QuackStrategy {
    func quack() {
        print("<squeak>")
    }
}

struct SilentStrategy: QuackStrategy {
    func quack() {
        print("...")
    }
}

struct QuacksStrategy: QuackStrategy {
    func quack() {
        print("Qua Qack!")
    }
}

final class WildDuck: Duck {

    init() {
        super.init(flyingStrategy: DoesFly(), quackStrategy: QuacksStrategy())
    }

    override func render() {
        print("🦆")
    }

}

final class PlasticDuck: Duck {
    init() {
        super.init(flyingStrategy: DoesNotFly(), quackStrategy: SilentStrategy())
    }

    override func render() {
        print("🐥")
    }
}

func exampleOfSwapingAlgorithm() {
    let dummyDuck = PlasticDuck()
    dummyDuck.render()
    dummyDuck.doFly()
    dummyDuck.doQuack()

    print("\nCome to life:\n")

    // Swap algorithm in run-time
    dummyDuck.flyingStrategy = DoesFly()
    dummyDuck.quackStrategy = QuacksStrategy()
    dummyDuck.render()
    dummyDuck.doFly()
    dummyDuck.doQuack()
}

exampleOfSwapingAlgorithm()
