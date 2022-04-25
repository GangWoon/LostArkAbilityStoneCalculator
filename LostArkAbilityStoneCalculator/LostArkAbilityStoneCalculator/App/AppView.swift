import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Environment(\.rootViewSize) var rootViewSize
    @Environment(\.safeAreaInsets) var safeAreaInsets
    let store: Store<AppState, AppAction>
    private let theme: Theme = .standard
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                backgroundView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: .zero) {
                        logoView
                        contentView
                    }
                }
                
                IfLetStore(
                    store.scope(
                        state: \.guideState,
                        action: AppAction.guide
                    ),
                    then: {
                        GuideView(store: $0)
                            .transition(.opacity)
                    }
                )
                .animation(.easeInOut, value:viewStore.guideState)
                
                IfLetStore(
                    store.scope(
                        state: \.animatedImageState,
                        action: AppAction.animatedImage
                    ),
                    then: { store in
                        VStack(spacing: .zero) {
                            Spacer()
                            
                            AnimatedImage(store: store)
                            .frame(width: 300, height: 300)
                            
                            Spacer()
                                .frame(height: 12)
                            
                            Text("확률을 계산 중입니다\n조금만 기다려 주세요")
                                .multilineTextAlignment(.center)
                                .font(.custom(style: .scDream(.semiBold), size: 14))
                            
                            Spacer()
                        }
                        .frame(width: rootViewSize.width)
                        .background(
                            Color.black
                                .opacity(0.85)
                        )
                        
                    }
                )
                
                IfLetStore(
                    store.scope(
                        state: \.resetAlertState,
                        action: AppAction.resetAlert
                    ),
                    then: {
                        AlertView(store: $0)
                            .transition(.opacity.animation(.easeInOut))
                    }
                )
            }
            .onAppear {
                viewStore.send(.onAppear)
                UIScrollView.appearance().isScrollEnabled = safeAreaInsets.top == .zero
                UIScrollView.appearance().bounces = false
            }
        }
    }
    
    private var backgroundView: some View {
        Color.black
    }
    
    private var logoView: some View {
        VStack(alignment: .center, spacing: .zero) {
            theme.image.logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: rootViewSize.height * 0.1)
                .padding(.horizontal, rootViewSize.width * 0.2)
                .padding(.top, rootViewSize.height * 0.05)
        }
    }
    
    private var contentView: some View {
        ZStack {
            LinearGradient(
                colors: theme.color.gradation,
                startPoint: .init(x: 0.2, y: 0.2),
                endPoint: .init(x: 0.8, y: 0.8)
            )
            .frame(height: rootViewSize.height.contentViewHeight)
            .cornerRadius(radius: 14, corners: [.topLeft, .topRight])
            
            VStack(spacing: .zero) {
                ContentHeaderView(
                    store: store.scope(
                        state: \.contentHeaderState,
                        action: AppAction.contentHeader
                    )
                )
                
                Spacer()
                    .frame(height: 24)
                
                PresetView(
                    store: store.scope(
                        state: \.presetState,
                        action: AppAction.preset
                    )
                )
                
                Spacer()
                    .frame(height: 24)
                
                VStack(spacing: 16) {
                    ForEachStore(
                        store.scope(
                            state: \.abilityList,
                            action: AppAction.abilityRow
                        ),
                        content: { AbilityRow(store:$0) }
                    )
                }
                
                Spacer()
            }
            .frame(width: rootViewSize.width)
        }
    }
}

// MARK: - Theme
extension AppView {
    struct Theme {
        struct ColorCollection {
            static let standard = Self(
                gradation:  [
                    Color(.sRGB, red: 21 / 255, green: 23 / 255, blue: 25 / 255, opacity: 1.0),
                    Color(.sRGB, red: 7 / 255, green: 8 / 255, blue: 9 / 255, opacity: 1.0)
                ]
            )
            let gradation: [Color]
        }
        
        struct ImageCollection {
            static let standard = Self(
                logo: Image("logo"),
                animation: [
                    .init(named: "cuteMokoko")!,
                    .init(named: "angryMokoko")!,
                    .init(named: "smellMokoko")!,
                ]
            )
            let logo: Image
            let animation: [UIImage]
        }
        
        static let standard = Self(
            color: .standard,
            image: .standard
        )
        let color: ColorCollection
        let image: ImageCollection
    }
}

fileprivate extension CGFloat {
    var contentViewHeight: CGFloat {
        return self < 700 ? 662 : self * 0.85
    }
}
