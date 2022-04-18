import SwiftUI

enum CustomFontStyle {
    fileprivate var fontName: String {
        switch self {
        case let .scDream(sCDream):
            return sCDream.fontName
        case let .montserrat(montserrat):
            return montserrat.fontName
        }
    }
    case scDream(SCDream)
    case montserrat(Montserrat)
}

enum SCDream {
    fileprivate var fontName: String {
        var fontName = "S-CoreDream-"
        switch self {
        case .extraLight:
            fontName.append(contentsOf: "2ExtraLight")
        case .medium:
            fontName.append(contentsOf: "5Medium")
        case .semiBold:
            fontName.append(contentsOf: "6Bold")
        }
        
        return fontName
    }
    case extraLight
    case medium
    case semiBold
}

enum Montserrat {
    fileprivate var fontName: String {
        var fontName = "Montserrat-"
        switch self {
        case .regular:
            fontName.append("Regular")
        case .medium:
            fontName.append("Medium")
        case .semiBold:
            fontName.append("SemiBold")
        }
        
        return fontName
    }
    case regular
    case medium
    case semiBold
}

extension UIFont {
    static func custom(style: CustomFontStyle, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.fontName, size: size) else { return .systemFont(ofSize: size) }
        return font
    }
}

extension Font {
    static func custom(style: CustomFontStyle, size: CGFloat) -> Font {
        return .custom(style.fontName, size: size)
    }
}
