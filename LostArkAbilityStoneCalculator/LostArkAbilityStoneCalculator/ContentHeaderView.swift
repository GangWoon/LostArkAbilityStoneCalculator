import SwiftUI
import ComposableArchitecture

struct ContentHeaderView: View {
    let store: Store<ContentHeaderState, ContentHeaderAction>
    private let theme: Theme = .standard
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.undoButtonTapped) }) {
                    VStack(alignment: .center, spacing: 2) {
                        theme.image.undo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        
                        Text(theme.text.undo)
                            .font(theme.font.button)
                            .foregroundColor(theme.color.button)
                            .frame(width: 40)
                    }
                }
                
                Spacer()
                
                AttributedText(
                    text: buildTitle(pos: viewStore.probabilityOfSuccess),
                    baseAttribute: Attribute(
                        range: buildTitle(pos: viewStore.probabilityOfSuccess).fullRange,
                        font: theme.font.coloredTitle,
                        color: theme.color.coloredTitle
                    ),
                    pointAttribute: Attribute(
                        range: NSRange(location: .zero, length: 5),
                        font: theme.font.title,
                        color: theme.color.title
                    ),
                    lineHeightMultple: 0.93
                )
                
                Spacer()
                
                Button(action: { viewStore.send(.resetButtonTapped) }) {
                    VStack(alignment: .center, spacing: 2) {
                        theme.image.reset
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        
                        Text(theme.text.reset)
                            .font(theme.font.button)
                            .foregroundColor(theme.color.button)
                            .frame(width: 40)
                    }
                }
            }
            .frame(height: 52)
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
    
    private func buildTitle(pos: String) -> String {
        theme.text.pos + " " + pos
    }
}

// MARK: - Theme
extension ContentHeaderView {
    struct Theme {
        struct FontCollection {
            static let standard = Self(
                coloredTitle: .custom(style: .montserrat(.semiBold), size: 20),
                title: .custom(style: .scDream(.medium), size: 18),
                button: .custom(style: .montserrat(.regular), size: 10)
            )
            let coloredTitle: UIFont
            let title: UIFont
            let button: Font
        }
        
        struct ColorCollection {
            static let standard = Self(
                button: Color(red: 1, green: 1, blue: 1, opacity: 0.55),
                title: .white,
                coloredTitle: UIColor(red: 253 / 255, green: 221 / 255, blue: 66 / 255, alpha: 1)
                
            )
            let button: Color
            let title: UIColor
            let coloredTitle: UIColor
        }
        
        struct ImageCollection {
            static let standard = Self(
                undo: Image("undoButton"),
                reset: Image("resetButton")
            )
            let undo: Image
            let reset: Image
        }
        
        struct TextCollection {
            static let standard = Self(
                undo: "Undo",
                pos: "성공 확률",
                reset: "Reset"
            )
            let undo: String
            let pos: String
            let reset: String
        }
        
        static let standard = Self(
            font: .standard,
            color: .standard,
            text: .standard,
            image: .standard
        )
        let font: FontCollection
        let color: ColorCollection
        let text: TextCollection
        let image: ImageCollection
    }
}

// MARK: - State
struct ContentHeaderState: Equatable {
    static var empty = Self(probabilityOfSuccess: "75%")
    var probabilityOfSuccess: String
}

// MARK: - Action
enum ContentHeaderAction: Equatable {
    case undoButtonTapped
    case resetButtonTapped
    case update(title: String)
}

// MARK: - Reducer
let contentHeaderReducer = Reducer<ContentHeaderState, ContentHeaderAction, Void> { state, action, _ in
    guard case let .update(title: value) = action else { return .none }
    state.probabilityOfSuccess = value
    
    return .none
}
