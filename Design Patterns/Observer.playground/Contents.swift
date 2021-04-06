/**
 #Observer
 - behavioral design pattern
 - allows an `Subject` object to notify multiple `Observer` objects about its state changes after they register for updates
 - one to many relation
 */

protocol Subject {

    associatedtype ObserverType: Observer

    var observers: [ObserverType] { get set }

    mutating func register(_ observer: ObserverType)
    mutating func unregister(_ observer: ObserverType)
    func notify()

}

protocol Observer {

    associatedtype Value
    func onUpdate(_: Value)

}

extension Subject where ObserverType: Equatable {

    mutating func register(_ observer: ObserverType) {
        guard observers.contains(observer) == false else { return }
        observers.append(observer)
    }

    mutating func unregister(_ observer: ObserverType) {
        observers.removeAll { $0 == observer }
    }

}

extension Subject where ObserverType: AnyObject {

    mutating func register(_ observer: ObserverType) {
        guard observers.contains(where: { observer === $0 }) == false else { return }
        observers.append(observer)
    }

    mutating func unregister(_ observer: ObserverType) {
        observers.removeAll { $0 === observer }
    }

}

/**
 Although following implementation of `WeatherObserver` protocol constrains the associatedtype `Value` to concrete type,
 it is currently not possible to use it as existential type (eg. as `ObserverType` in `WeatherProvider`).
 https://forums.swift.org/t/lifting-the-self-or-associated-type-constraint-on-existentials/18025

     protocol WeatherObserver: Observer where Value == WeatherParams {
         func update(_: WeatherParams)
     }

 Instead let's use associatedtype-erased `AnyObserver`.
 */

final class AnyObserver<Value>: Observer {

    private let _onUpdate:  (Value) -> Void

    init<O: Observer>(_ observer: O) where Value == O.Value {
        self._onUpdate = observer.onUpdate
    }

    func onUpdate(_ value: Value) {
        _onUpdate(value)
    }

}

extension Observer {

    func eraseToAnyObserver() -> AnyObserver<Value> {
        AnyObserver(self)
    }

}

// Implementation example

final class WeatherProvider: Subject {

    struct WeatherParams {
        let temperature: Float
        let humidity: Float
        let pressure: Float
    }

    private var temperature: Float = 0
    private var humidity: Float = 0
    private var pressure: Float = 0

    var observers: [AnyObserver<WeatherParams>] = []

    func notify() {
        observers.forEach {
            $0.onUpdate(
                .init(temperature: temperature, humidity: humidity, pressure: pressure)
            )
        }
    }

    func setReadings(temperature: Float, humidity: Float, pressure: Float) {
        self.temperature = temperature
        self.humidity = humidity
        self.pressure = pressure

        receivedNewReadings()
    }

    private func receivedNewReadings() {
        notify()
    }

}

extension WeatherProvider.WeatherParams: CustomStringConvertible {

    var description: String {
        "temperature: \(temperature), humidity: \(humidity), pressure: \(pressure)"
    }

}

struct CurrentWeather: Observer {

    func onUpdate(_ params: WeatherProvider.WeatherParams) {
        print("\(self) received params: \(params)")
    }

}

final class WeatherHistory: Observer {

    private var history: [WeatherProvider.WeatherParams] = []

    func onUpdate(_ params: WeatherProvider.WeatherParams) {
        history.append(params)
        print(
            """
            \(self)
            average temperature: \(average(\.temperature)),
            average humidity: \(average(\.humidity)),
            average pressure: \(average(\.pressure)).

            """
        )
    }

    private func average(_ keyPath: KeyPath<WeatherProvider.WeatherParams, Float>) -> Float {
        history.map { $0[keyPath: keyPath] }.reduce(0, +) / Float(history.count)
    }

}


var weatherProvider = WeatherProvider()
let currentWeather = CurrentWeather().eraseToAnyObserver()
let weatherHistory = WeatherHistory().eraseToAnyObserver()

weatherProvider.register(currentWeather)
weatherProvider.register(currentWeather) // Already registered
weatherProvider.register(weatherHistory)
weatherProvider.register(weatherHistory) // Already registered

weatherProvider.setReadings(temperature: 10, humidity: 90, pressure: 1000)
weatherProvider.setReadings(temperature: 11, humidity: 82, pressure: 1050)
weatherProvider.setReadings(temperature: 12, humidity: 88, pressure: 1020)

weatherProvider.unregister(weatherHistory)

weatherProvider.setReadings(temperature: 20, humidity: 100, pressure: 990)
