import SwiftUI
import Combine
import ComposableArchitecture

struct AnimatedImage: View {
    let store: Store<AnimatedImageState, AnimatedImageAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Image(systemName: viewStore.imageName)
                .resizable()
                .onAppear { viewStore.send(.onAppear) }
        }
    }
}

// MARK: - State
struct AnimatedImageState: Equatable {
    static let empty = Self(
        imageNameList: [
            "sunrise.fill",
            "sun.max.fill",
            "sunset.fill",
            "moon.fill",
            "moon.stars.fill",
            "hand.wave.fill"
        ]
    )
    var imageName: String {
        guard imageNameList.count > index else { return "" }
        return imageNameList[index]
    }
    let imageNameList: [String]
    var index: Int = .zero
}

// MARK: - Action
enum AnimatedImageAction: Equatable {
    case onAppear
    case animateImage(result: Result<Int, Never>)
    case stopAnimate
}

// MARK: - Environment
struct AnimatedImageEnvironment {
    static let live: Self = {
        let imageTimer = AnimatedImageTimer()
        return Self(
            fireTimer: { imageTimer.fireTimer(limit: $0).eraseToEffect() },
            stopTimer: { .fireAndForget{ imageTimer.stopTimer() } }
        )
    }()
    let fireTimer: (Int) -> Effect<Int, Never>
    let stopTimer: () -> Effect<Never, Never>
}

// MARK: - Reducer
let animatedImageReducer = Reducer<AnimatedImageState, AnimatedImageAction, AnimatedImageEnvironment> { state, action, environment in
    switch action {
    case .onAppear:
        return environment.fireTimer(state.imageNameList.count - 1)
            .eraseToEffect()
            .catchToEffect(AnimatedImageAction.animateImage)
        
    case let .animateImage(result: .success(index)):
        state.index = index
        return .none
        
    case .animateImage:
        return .none
        
    case .stopAnimate:
        return environment.stopTimer()
            .fireAndForget()
    }
}

final class AnimatedImageTimer {
    private var timer: Timer?
    private var count: Int = .zero
    
    func fireTimer(limit: Int) -> AnyPublisher<Int, Never> {
        let subject = PassthroughSubject<Int, Never>()
        timer = .scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            self.count = limit < self.count ? .zero : self.count
            subject.send(self.count)
            self.count += 1
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
}
