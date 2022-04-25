import SwiftUI
import ComposableArchitecture

struct AbilityRow: View {
    @Environment(\.rootViewSize) var rootViewSize
    let store: Store<AbilityRowState, AbilityRowAction>
    private let theme: Theme = .standard
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: .zero) {
                Text(viewStore.isRecommended ? theme.text.recommed : "")
                    .frame(height: 16)
                    .padding(.leading, 24)
                    .font(theme.font.title)
                    .foregroundColor(theme.color.recommendFont)
                
                Spacer()
                    .frame(height: 8)
                
                HStack(alignment: .center, spacing: .zero) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewStore.type.description)
                            .font(theme.font.title)
                        
                        Text(viewStore.recommendationProbability)
                            .font(theme.font.detail)
                    }
                    .foregroundColor(theme.color.titleFont)
                    
                    Spacer()
                        .frame(width: 17)
                    
                    HStack(spacing: 5) {
                        ForEach(viewStore.tryResults) { item in
                            item.image(abilityType: viewStore.type)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .background(
                    LinearGradient(
                        stops:
                            zip(theme.color.linearGradient, [0, 0.38, 1])
                            .map { Gradient.Stop(color: $0, location: $1) },
                        startPoint: UnitPoint(
                            x: -0.73,
                            y: -0.66
                        ),
                        endPoint: UnitPoint(
                            x: 1.68,
                            y: 3.94
                        )
                    )
                    .frame(width: rootViewSize.width - 32, height: 60)
                    .shadow(
                        color: theme.color.linearGradientShadow,
                        radius:60,
                        x:22,
                        y:22
                    )
                    .cornerRadius(50)
                )
                .frame(width: rootViewSize.width - 32, height: 60)
                .cornerRadius(50)
                
                Spacer()
                    .frame(height: 16)
                
                HStack(spacing: 8) {
                    Spacer()
                    
                    Button(action: { viewStore.send(.buttonTapped(.fail)) }) {
                        Text(theme.text.fail)
                            .frame(width: ((rootViewSize.width * 0.63) - 8) / 2, height: 40)
                            .background(theme.color.failButtonBackground)
                            .cornerRadius(40)
                    }
                    
                    Button(action: { viewStore.send(.buttonTapped(.success)) }) {
                        Text(theme.text.success)
                            .frame(width: ((rootViewSize.width * 0.63) - 8) / 2, height: 40)
                            .background(viewStore.type.backgroundColor)
                            .cornerRadius(40)
                            .shadow(
                                color: theme.color.buttonShadow,
                                radius:28,
                                x:6,
                                y:6
                            )
                    }
                    
                    Spacer()
                }
                .font(theme.font.button)
                .foregroundColor(theme.color.buttonFont)
                .frame(width: rootViewSize.width - 32)
            }
            .frame(width: rootViewSize.width - 32)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Theme
extension AbilityRow {
    struct Theme {
        struct FontCollection {
            static let standard = Self(
                recommend: .custom(style: .scDream(.semiBold), size: 12),
                title: .custom(style: .scDream(.semiBold), size: 14),
                detail: .custom(style: .montserrat(.medium), size: 10),
                button: .custom(style: .montserrat(.semiBold), size: 12)
            )
            let recommend: Font
            let title: Font
            let detail: Font
            let button: Font
        }
        
        struct ColorCollection {
            static let standard = Self(
                linearGradient: [
                    Color(red: 47 / 255, green: 52 / 255, blue: 57 / 255),
                    Color(red: 38 / 255, green: 41 / 255, blue: 46 / 255),
                    Color(red: 23 / 255, green: 25 / 255, blue: 28 / 255),
                ],
                linearGradientShadow: Color(.sRGB, red: .zero, green: .zero, blue: .zero, opacity: 0.5),
                recommendFont: Color(red: 221 / 255, green: 54 / 255, blue: 54 / 255),
                titleFont: .white,
                titleShadow: Color(.sRGB, red: .zero, green: .zero, blue: .zero, opacity: 0.25),
                buttonFont: .white,
                buttonShadow: Color(.sRGB, red: .zero, green: .zero, blue: .zero, opacity: 0.3),
                failButtonBackground: Color(red: 50 / 255, green: 54 / 255, blue: 59 / 255)
            )
            let linearGradient: [Color]
            let linearGradientShadow: Color
            let recommendFont: Color
            let titleFont: Color
            let titleShadow: Color
            let buttonFont: Color
            let buttonShadow: Color
            let failButtonBackground: Color
        }
        
        struct TextCollection {
            static let standard = Self(
                recommed: "추천!",
                success: "Success",
                fail: "Fail"
            )
            let recommed: String
            let success: String
            let fail: String
        }
        
        static let standard = Self(
            font: .standard,
            color: .standard,
            text: .standard
        )
        let font: FontCollection
        let color: ColorCollection
        let text: TextCollection
    }
}

// MARK: - State
struct AbilityRowState: Equatable, Identifiable {
    let id: UUID
    let type: AbilityType
    var step: Int = .zero
    var recommendationProbability: String = ""
    var isRecommended: Bool = false
    var tryResults: [TryResult] = .mock
}

// MARK: - Action
enum AbilityRowAction: Equatable {
    case buttonTapped(TryResult)
    case undoButtonTapped
    case updateItem(rp: String, isRecommended: Bool)
}

// MARK: - Reducer
let abilityRowReducer = Reducer<AbilityRowState, AbilityRowAction, Void> { state, action, _ in
    switch action {
    case let .buttonTapped(result):
        guard state.step < 10 else { return .none }
        state.tryResults[state.step] = result
        state.step += 1
        return .none
        
    case .undoButtonTapped:
        guard state.step > .zero else { return .none }
        state.step -= 1
        state.tryResults[state.step] = .none
        return .none
        
    case let .updateItem(item, isRecommended):
        state.isRecommended = isRecommended
        state.recommendationProbability = item
        return .none
    }
}

// MARK: - Type
enum TryResult: Int, Equatable, Identifiable {
    var id: String { return UUID().uuidString }
    case none = -1
    case success = 1
    case fail = 0
    
    fileprivate func image(abilityType type: AbilityType) -> Image {
        guard self != .none else { return Image("normalState") }
        switch type {
        case .positive:
            guard self != .success else { return Image("positiveSucess") }
        case .negative:
            guard self != .success else { return Image("negativeSucess") }
        }
        return Image("failed")
    }
}

enum AbilityType: Equatable, CustomStringConvertible {
    var description: String {
        switch self {
        case let .positive(value):
            return "증가 능력 \(value)"
        case .negative:
            return "감소 능력"
        }
    }
    
    fileprivate var backgroundColor: some View {
        switch self {
        case .positive:
            return Color(red: 91 / 255, green: 96 / 255, blue: 253 / 255)
        case .negative:
            return Color(red: 253 / 255, green: 90 / 255, blue: 86 / 255)
        }
    }
    case positive(Int)
    case negative
}

extension Array where Element == TryResult {
    static let mock = Self(repeating: .none, count: 10)
}
