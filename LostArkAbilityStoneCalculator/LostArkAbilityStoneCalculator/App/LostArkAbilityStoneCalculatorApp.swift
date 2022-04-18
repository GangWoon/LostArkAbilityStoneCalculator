import SwiftUI
import ComposableArchitecture

@main
struct LostArkAbilityStoneCalculatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            WithRootGeometryReader {
                AppView(
                    store: Store(
                        initialState: .empty,
                        reducer: appReducer,
                        environment: .live
                    )
                )
                .ignoresSafeArea()
                .statusBar(hidden: true)
            }
        }
    }
}
