import SwiftUI

struct SafeAreaInsetsKey: EnvironmentKey {
    public static var defaultValue = EdgeInsets()
}

struct RootViewSize: EnvironmentKey {
    public static let defaultValue = CGSize.zero
}

extension EnvironmentValues {
    public var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
    
    public var rootViewSize: CGSize {
        get { self[RootViewSize.self] }
        set { self[RootViewSize.self] = newValue }
    }
}

struct WithRootGeometryReader<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { proxy in
            content
                .environment(\.safeAreaInsets, proxy.safeAreaInsets)
                .environment(
                    \.rootViewSize,
                     CGSize(
                        width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
                        height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
                     )
                )
        }
    }
}

extension View {
    func cornerRadius(
        radius: CGFloat,
        corners: UIRectCorner
    ) -> some View {
        clipShape(
            RoundedCorner(
                radius: radius,
                corners: corners
            )
        )
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

