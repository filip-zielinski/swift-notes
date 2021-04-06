/**
 # KeyPath
 - A key path from a specific root type to a specific resulting value type
 */

// setup
import UIKit

@objcMembers class Kid : NSObject {
    dynamic var name: String
    dynamic var age: Double
    dynamic var bestFriend: Kid? = nil
    dynamic var friends: [Kid] = []

    init(name: String, age: Double) {
        self.name = name
        self.age = age
    }
}

let ben = Kid(name: "Benjamin", age: 5.5)
let mia = Kid(name: "Mia", age: 5.0)

/// # Swift 3 KeyPaths
let kidsNameKeyPath = #keyPath(Kid.name) // String

// evaluate property
let name = ben.value(forKeyPath: kidsNameKeyPath) // value(forKeyPath: String) -> Any?

// mutate property
ben.setValue("Ben", forKeyPath: kidsNameKeyPath) // setValue(_, forKeyPath: String) -> Any

/// # Swift 4 KeyPaths
let bestFriendKeyPath = \Kid.bestFriend

// evaluate property
let age = mia[keyPath: \Kid.age]

mia[keyPath: \Kid.bestFriend] = ben
mia[keyPath: \Kid.friends].append(ben)
let friendsName = mia.friends[keyPath: \[Kid].[0].name]

// mutate property
ben[keyPath: \Kid.age] = 6.0

/// # Appending KeyPaths
func friendAge(_ kid: Kid, _ friendKeyPath: KeyPath<Kid, Kid>) -> Double {
    let kidsAgeKeyPath = friendKeyPath.appending(path: \.age)
    return kid[keyPath: kidsAgeKeyPath]
}

let firstFriendAge = friendAge(mia, \.friends[0])

/// # Type system
let kidKeyPaths = [\Kid.name, \Kid.age, \Kid.friends] // PartialKeyPath<Kid>

struct BirthdayParty {
    let celebrant: Kid
    var theme: String
    var attending: [Kid]
}

let keyPaths = [\Kid.name, \BirthdayParty.celebrant] //AnyKeyPath


/// # Mutating KeyPaths
/// ## Value types
var bensParty = BirthdayParty(celebrant: ben, theme: "Space", attending: [ben])
let themeKeyPath = \BirthdayParty.theme // WritableKeyPath<BirthdayParty, String>

bensParty[keyPath: themeKeyPath] = "ninja"

/// ## Reference types
let ageKeyPath = \Kid.age // ReferenceWritableKeyPath<Kid, Double>

ben[keyPath: ageKeyPath] = 7.0

var party = BirthdayParty(celebrant: mia, theme: "Space", attending: [ben, mia])

/// # KeyPaths are captured by Value
print("KeyPaths are captured by Value:")
let chris = Kid(name: "Chris", age: 2.0)
ben[keyPath: \Kid.friends].append(mia)
ben[keyPath: \Kid.friends].append(chris)

var index = 0
let partyAttendeeAgeKeyPath: KeyPath<Kid, Kid> = \Kid.friends[index]
print(friendAge(ben, partyAttendeeAgeKeyPath)) // 5.0

index = 1
print(friendAge(ben, partyAttendeeAgeKeyPath)) // 5.0 (not 2.0)

/// # Key-Value Observing
print("\nKey-Value Observing:")
let observation = ben.observe(\.age) { observed, change in
    print("Observed: \(observed)") // Kid
    print("Change: \(change)") // NSKeyValueObservedChange<Double>
}

ben.age = 9.0

/// # Usage
/// ## "Adapter" pattern
print("\nAdapter pattern:")
protocol Identifiable {
    associatedtype ID
    static var idKey: WritableKeyPath<Self, ID> { get }
}
struct Person: Identifiable {
    static let idKey = \Person.socialSecurityNumber
    var socialSecurityNumber: String
}
struct Book: Identifiable {
    static let idKey = \Book.isbn
    var isbn: String
}

func printID<T: Identifiable>(thing: T) {
    print(thing[keyPath: T.idKey])
}

let postmanByBukowski = Book(isbn: "555-55-5555")
printID(thing: postmanByBukowski)

/// ## In tandem with generics: Constraints
extension UIView {
    func anchor<Anchor, AnchorType>(_ anchorPath: KeyPath<UIView, Anchor>,
                                    to view: UIView,
                                    constant: CGFloat = 0) where Anchor: NSLayoutAnchor<AnchorType> {

        translatesAutoresizingMaskIntoConstraints = false
        self[keyPath: anchorPath].constraint(equalTo: view[keyPath: anchorPath], constant: constant).isActive = true
    }
}

let parentView = UIView()
let subView = UIView()

//subView.anchor(\UIView.topAnchor, to: parentView)

/// ## In tandem with generics: API for View <-> Model communication
class SettingsSwitch<T>: UISwitch {

    private var viewModel: T
    private let keyPath: WritableKeyPath<T, Bool> // KeyPath to update the model

    init(viewModel: T, keyPath: WritableKeyPath<T, Bool>) {
        self.viewModel = viewModel
        self.keyPath = keyPath
        super.init(frame: .zero)

        let initialValue = viewModel[keyPath: keyPath]
        setOn(initialValue, animated: false)
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func valueChanged() {
        viewModel[keyPath: keyPath] = isOn // Update model
    }
}

/// ## Other usage
print("\nOther usage:\n")
let titles = ["Theme", "Attending", "Birthday Kid"]
let partyPaths = [\BirthdayParty.theme, \BirthdayParty.attending, \BirthdayParty.celebrant.name]

for (title, partyPath) in zip(titles, partyPaths) {
    let partyValue = party[keyPath: partyPath]
    print("\(title)\n\(partyValue)\n")
}
