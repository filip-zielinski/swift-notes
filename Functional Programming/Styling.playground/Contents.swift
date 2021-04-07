import UIKit

enum Function {}

extension Function {

    static func compose<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
        { a in
            g(f(a))
        }
    }
    static func combine<A>(_ f: @escaping (A) -> Void, _ g: @escaping (A) -> Void) -> (A) -> Void {
        { a in
            f(a)
            g(a)
        }
    }

    static func combine<A>(_ functions: ((A) -> Void)...) -> (A) -> Void {
        { a in
            functions.forEach { $0(a) }
        }
    }

    static func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
        { a in
            { b in
                f(a, b)
            }
        }
    }

    static func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
        { b in
            { a in
                f(a)(b)
            }
        }
    }

}

extension UIView {

    static func backgroundColorStyle(color: UIColor) -> (UIView) -> Void {
        {
            $0.backgroundColor = color
        }
    }

    static func borderStyle(width: CGFloat, color: UIColor) -> (UIView) -> Void {
        {
            $0.layer.borderWidth = width
            $0.layer.borderColor = color.cgColor
        }
    }

}

extension UIButton {

    static func textFontStyle(font: UIFont, color: UIColor) -> (UIButton) -> Void {
        {
            $0.setTitleColor(color, for: .normal)
            $0.titleLabel?.font = font
        }
    }

    static func systemFont(_ color: UIColor, size: CGFloat) -> (UIButton) -> Void {
        Function.curry(textFontStyle)(.systemFont(ofSize: size))(color)
    }

    static func blueFont(_ font: UIFont) -> (UIButton) -> Void {
        Function.flip(Function.curry(textFontStyle))(.blue)(font)
    }

}

func myButtonStyle(button: UIButton) -> (UIButton) -> Void {
    Function.combine(
        UIView.backgroundColorStyle(color: .blue),
        UIView.borderStyle(width: 1.0, color: .lightGray),
        UIButton.textFontStyle(font: .systemFont(ofSize: 10), color: .white)
    )
}

let button = UIButton()

myButtonStyle(button: button)

