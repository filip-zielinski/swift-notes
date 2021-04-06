/**
 #Decorator
 - dynamically adds new behavior to object
 - decorators are of the same type as decorated object
 - object can be wrapped in more than one decorator
 - decorator adds his behaviour before or/and after delegating action to decorated object
 - There are: base object of type A, base decorator type inheriting/conforming to A and concrete decorator implementations
 */

/// Base object definition
protocol Beverage {
    var name: String { get }
    var cost: Double { get }
    func description() -> String
}

/// Base object implementation
struct Espresso: Beverage {
    let name: String = "Espresso coffee"
    let cost: Double = 0.50
    func description() -> String {
        "Excellent \(name) beverage"
    }
}

/// Decorator definition
protocol BeverageDecorator: Beverage {
    var beverage: Beverage { get }
}

/// Decorators implementations
struct ChocolateDecorator: BeverageDecorator {

    let beverage: Beverage // Base object

    var name: String { beverage.name + "with chocolate" } // new behavior
    var cost: Double { beverage.cost + 0.20 }

    func description() -> String {
        "\(beverage.description()) with chocolate"
    }

}

struct SoyMilkDecorator: BeverageDecorator {

    let beverage: Beverage

    var name: String { beverage.name + "with soy milk" }
    var cost: Double { beverage.cost + 0.30 }

    func description() -> String {
        "\(beverage.description()) with soy milk"
    }

}

struct WheapCreamDecorator: BeverageDecorator {

    let beverage: Beverage

    var name: String { beverage.name + "with wheap cream" }
    var cost: Double { beverage.cost + 0.30 }

    func description() -> String {
        "\(beverage.description()) with wheap cream"
    }

}

// Example

func describe(_ drink: Beverage) {
    print("\(drink.description()) : $\(drink.cost)")
}

var drink: Beverage = Espresso()
describe(drink)

drink = SoyMilkDecorator(beverage: drink)
drink = WheapCreamDecorator(beverage: drink)
drink = ChocolateDecorator(beverage: drink)
drink = ChocolateDecorator(beverage: drink)
describe(drink)
