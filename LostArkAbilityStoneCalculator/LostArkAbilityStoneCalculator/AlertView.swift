import SwiftUI
import ComposableArchitecture

struct AlertView: View {
    @Environment(\.rootViewSize) var rootViewSize
    let store: Store<ResetAlertState, ResetAlertAction>
    private let theme: Theme = .standard
    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                theme.color.dimmed
                
                ZStack {
                    Spacer()
                    
                    VStack(alignment: .center) {
                        theme.image.warnning
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 82, height: 76)
                        
                        Spacer()
                            .frame(height: 28)
                        
                        Text(theme.text.title)
                            .font(theme.font.title)
                            .foregroundColor(theme.color.titleFont)
                        
                        Spacer()
                            .frame(height: 4)
                        
                        HStack(alignment: .center) {
                            Button(action: { viewStore.send(.checkBoxTapped) }) {
                                buildCheckBox(isChecked: viewStore.isVisible)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(theme.color.yesButtonBackground)
                                
                                Text(theme.text.description)
                                    .font(.system(size: 13))
                                    .foregroundColor(theme.color.titleFont)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        HStack(spacing: 8) {
                            
                            Button(action: { viewStore.send(.buttonTapped(.no)) }) {
                                Text(theme.text.no)
                                    .frame(width: rootViewSize.width * 0.38, height: 40)
                                    .foregroundColor(theme.color.noButtonFont)
                                    .background(theme.color.noButtonBackground)
                                    .cornerRadius(24)
                            }
                            
                            Button(action: { viewStore.send(.buttonTapped(.yes)) }) {
                                Text(theme.text.yes)
                                    .frame(width: rootViewSize.width * 0.38, height: 40)
                                    .foregroundColor(theme.color.yesButtonFont)
                                    .background(theme.color.yesButtonBackground)
                                    .cornerRadius(24)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .frame(width: rootViewSize.width - 36)
                    .padding(.vertical, 24)
                    .background(theme.color.background)
                    .cornerRadius(24)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func buildCheckBox(isChecked: Bool) -> Image {
        isChecked ? theme.image.square : theme.image.checkMark
    }
}

extension AlertView {
    struct Theme {
        struct FontCollection {
            static let standard = Self(
                title: .custom(style: .scDream(.extraLight), size: 14),
                button: .custom(style: .montserrat(.semiBold), size: 12)
            )
            let title: Font
            let button: Font
        }
        
        struct ColorCollection {
            static let standard = Self(
                dimmed: Color(.sRGB, red: .zero, green: .zero, blue: .zero, opacity: 0.5),
                background: Color(red: 24 / 255, green: 27 / 255, blue: 30 / 255),
                titleFont: .white,
                yesButtonBackground: Color(red: 91 / 255, green: 96 / 255, blue: 253 / 255),
                yesButtonFont: .white,
                noButtonBackground: Color(red: 241 / 255, green: 241 / 255, blue: 241 / 255),
                noButtonFont: .black
            )
            let dimmed: Color
            let background: Color
            let titleFont: Color
            let yesButtonBackground: Color
            let yesButtonFont: Color
            let noButtonBackground: Color
            let noButtonFont: Color
        }
        
        struct ImageCollection {
            static let standard = Self(
                warnning: Image("warnning"),
                checkMark: Image(systemName: "checkmark.square"),
                square: Image(systemName: "square")
            )
            let warnning: Image
            let checkMark: Image
            let square: Image
        }
        
        struct TextCollection {
            static let standard = Self(
                title: "정말로 초기화 하시겠습니까?",
                description: "다시 보지 않기",
                yes: "Yes",
                no: "No"
            )
            let title: String
            let description: String
            let yes: String
            let no: String
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

struct ResetAlertState: Equatable {
    static var empty = Self(isVisible: true)
    var isVisible: Bool
}

enum ResetAlertAction: Equatable {
    enum ButtonType: Equatable {
        case yes
        case no
    }
    case checkBoxTapped
    case buttonTapped(ButtonType)
}

let resetAlertReducer = Reducer<ResetAlertState, ResetAlertAction, Void> { state, action, _ in
    guard case .checkBoxTapped = action else { return .none }
    state.isVisible.toggle()
    return .none
}
