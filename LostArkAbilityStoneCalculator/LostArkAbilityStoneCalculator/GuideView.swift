import SwiftUI
import ComposableArchitecture

struct GuideView: View {
    @Environment(\.rootViewSize) var rootViewSize
    let store: Store<GuideState, GuideAction>
    private let theme: Theme = .standard
    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                VStack(spacing: .zero) {
                    theme.color.dimmed
                        .frame(height: rootViewSize.height.topPadding)
                    
                    ZStack {
                        Rectangle()
                            .fill(theme.color.dimmed)
                        
                        Rectangle()
                            .cornerRadius(14)
                            .frame(width: rootViewSize.width - 32)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                    .frame(height: 84)
                    
                    ZStack {
                        theme.color.dimmed
                        
                        VStack(alignment: .center, spacing: .zero) {
                            theme.image.upArrow
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                                .padding(.top, 16)
                            
                            Spacer()
                                .frame(height: 32)
                            
                            Text(theme.text.description)
                                .foregroundColor(theme.color.description)
                                .font(theme.font.description)
                                .frame(width: 250)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    
                    Button(action: { viewStore.send(.confirmButtonTapped) }) {
                        Text(theme.text.button)
                            .frame(width: rootViewSize.width - 36, height: 46)
                            .foregroundColor(theme.color.buttonFont)
                            .background(theme.color.buttonBackground)
                            .cornerRadius(24)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

// MARK: - Theme
extension GuideView {
    struct Theme {
        struct FontCollection {
            static let standard = Self(
                description: .system(size: 14),
                button: .system(size: 20)
            )
            let description: Font
            let button: Font
        }
        
        struct ColorCollection {
            static let standard = Self(
                dimmed: Color.black.opacity(0.85),
                description: .white,
                buttonFont: .black,
                buttonBackground: .white
            )
            let dimmed: Color
            let description: Color
            let buttonFont: Color
            let buttonBackground: Color
        }
        
        struct ImageCollection {
            static let standard = Self(upArrow: Image("upArrow"))
            let upArrow: Image
        }
        
        struct TextCollection {
            static let standard = Self(
                description: "안녕하세요.✋ 모코코 여러분\n\n처음 프리셋은 14돌에 맞춰져 있어요.\n16돌에 맞추고 싶으시면 버튼을 클릭해\n확률을 변경해 주세요 :)",
                button: "start"
            )
            let description: String
            let button: String
        }
        
        static let standard = Self(
            font: .standard,
            color: .standard,
            image: .standard,
            text: .standard
        )
        let font: FontCollection
        let color: ColorCollection
        let image: ImageCollection
        let text: TextCollection
    }
}

// MARK: - State
struct GuideState: Equatable { }

// MARK: - Action
enum GuideAction: Equatable {
    case confirmButtonTapped
}

extension CGFloat {
    fileprivate var topPadding: CGFloat {
        (self * 0.15) + 70 + 16
    }
}
