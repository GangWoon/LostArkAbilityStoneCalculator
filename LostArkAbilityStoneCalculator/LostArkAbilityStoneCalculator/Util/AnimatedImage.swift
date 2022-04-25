import SwiftUI
import Combine
import ComposableArchitecture

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
        return imageNameList[index]
    }
    var index: Int = .zero
    var imageNameList: [String]
    var isAnimated: Bool = true
}

enum AnimatedImageAction: Equatable {
    case onAppear
    case animateImage(result: Result<Int, Never>)
    case stopAnimate
}

struct AnimatedImageEnvironment {
    static let live: Self = {
        let imageTimer = AnimatedImageTimer()
        
        return Self(
            fireTimer: imageTimer.fireTimer,
            stopTimer: imageTimer.stopTimer
        )
    }()
    let fireTimer: (Int) -> AnyPublisher<Int, Never>
    let stopTimer: () -> Void
}

final class AnimatedImageTimer {
    private var timer: Timer?
    var count: Int = .zero
    
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
        environment.stopTimer()
        return .none
    }
}

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
