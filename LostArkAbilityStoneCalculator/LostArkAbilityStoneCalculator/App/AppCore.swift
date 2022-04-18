import Foundation
import ComposableArchitecture
import UIKit

// MARK: - State
struct AppState: Equatable {
    static var empty = Self(
        contentHeaderState: .empty,
        presetState: .empty,
        abilityList: [],
        idStack: []
    )
    var contentHeaderState: ContentHeaderState
    var presetState: PresetState
    var abilityList: IdentifiedArrayOf<AbilityRowState>
    var idStack: [UUID]
    var guideState: GuideState?
    var animatedImageState: AnimatedImageState?
    var resetAlertState: ResetAlertState?
}

// MARK: - Action
enum AppAction: Equatable {
    case onAppear
    case overwrite(list: CalculateResult)
    case update(list: Result<CalculateResult, Never>)
    case contentHeader(action: ContentHeaderAction)
    case preset(action: PresetAction)
    case abilityRow(id: AbilityRowState.ID, action: AbilityRowAction)
    case guide(action: GuideAction)
    case animatedImage(action: AnimatedImageAction)
    case resetAlert(action: ResetAlertAction)
    case readyForCalculate(action: Result<Bool, Error>)
}

// MARK: - Environment
struct AppEnvironment {
    static var live: Self {
        let calculator = AbilityStoneCalculator()
        let permanentStorage = PermanentStorage.live
        
        return Self(
            uuid: UUID.init,
            mainQueue: .main,
            calculatorIsValid: { calculator.isValid },
            readyToCalculate: calculator
                .readyToCalculate()
                .eraseToEffect(),
            calculate: calculator.calculate,
            itemFromDefaults: { permanentStorage[$0] },
            setItemToDefaults: { permanentStorage[$0] = $1 }
        )
    }
    var uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var calculatorIsValid: () -> Bool
    var readyToCalculate: Effect<Bool, Error>
    var calculate: (AbilityStoneCalculator.Action) -> CalculateResult
    var itemFromDefaults: (UserDefaults.RawType<Bool>) -> Bool
    var setItemToDefaults: (UserDefaults.RawType<Bool>, Bool) -> Void
}

// MARK: - Reducer
let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    animatedImageReducer
        .optional()
        .pullback(
            state: \.animatedImageState,
            action: /AppAction.animatedImage,
            environment: { _ in .live }
        ),
    resetAlertReducer
        .optional()
        .pullback(
            state: \.resetAlertState,
            action: /AppAction.resetAlert,
            environment: { _ in () }
        ),
    contentHeaderReducer
        .pullback(
            state: \.contentHeaderState,
            action: /AppAction.contentHeader,
            environment: { _ in () }
        ),
    presetReducer
        .pullback(
            state: \.presetState,
            action: /AppAction.preset,
            environment: { _ in () }
        ),
    abilityRowReducer
        .forEach(
            state: \.abilityList,
            action: /AppAction.abilityRow,
            environment: { _ in () }
        ),
    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            guard !environment.itemFromDefaults(.guideViewVisible) else {
                state.guideState = GuideState()
                return Effect(value: .overwrite(list: .empty))
            }
            state.animatedImageState = .empty
            return .merge(
                Effect(value: .overwrite(list: .empty)),
                environment.readyToCalculate
                    .receive(on: environment.mainQueue)
                    .catchToEffect(AppAction.readyForCalculate)
            )
            
        case let .overwrite(list: result):
            state.abilityList = []
            zip(Array<AbilityType>.empty, result.valueList)
                .forEach { type, value in
                    let rowState = AbilityRowState(
                        id: environment.uuid(),
                        type: type,
                        recommendationProbability: value.rp,
                        isRecommended: value.isRecommened
                    )
                    state.abilityList.append(rowState)
                }
            return Effect(value: .contentHeader(action: .update(title: result.probabilityOfSuccess)))
            
        case let .update(list: .success(result)):
            var effects = zip(state.abilityList.map(\.id), result.valueList)
                .map { id, item -> Effect<AppAction, Never> in
                    Effect(
                        value: .abilityRow(
                            id: id,
                            action: .updateItem(
                                rp: item.rp,
                                isRecommended: item.isRecommened
                            )
                        )
                    )
                }
            effects.append(Effect(value: .contentHeader(action: .update(title: result.probabilityOfSuccess))))
            return .merge(effects)
            
        case .contentHeader(action: .undoButtonTapped):
            guard let id = state.idStack.popLast() else { return .none }
            let result = environment.calculate(.undo(type: state.presetState.selectedPreset))
            return .merge(
                Effect(value: .update(list: .success(result))),
                Effect(value: .abilityRow(id: id, action: .undoButtonTapped))
            )
            
        case .contentHeader(action: .resetButtonTapped):
            state.idStack = []
            state.resetAlertState = environment.itemFromDefaults(.alertViewVisible) ? .empty : nil
            let result = environment.calculate(.reset(type: state.presetState.selectedPreset))
            return Effect(value: .overwrite(list: result))
            
        case let .preset(action: .buttonTapped(preset)):
            let result = environment.calculate(.preset(type: preset))
            return Effect(value: .update(list: .success(result)))
            
        case let .abilityRow(id: id, action: .buttonTapped(type)):
            guard state.abilityList.count < 10,
                  let index = state.abilityList.index(id: id) else { return .none }
            state.idStack.append(id)
            let result = environment
                .calculate(
                    .toggle(
                        abilityType: state.abilityList[index].type,
                        presetType: state.presetState.selectedPreset,
                        result: type.rawValue
                    )
                )
            return Effect(value: .update(list: .success(result)))
            
        case .guide(action: .confirmButtonTapped):
            state.guideState = nil
            environment.setItemToDefaults(.guideViewVisible, false)
            guard !environment.calculatorIsValid() else {
                let result = environment.calculate(.result(type: state.presetState.selectedPreset))
                return Effect(value: .update(list: .success(result)))
            }
            state.animatedImageState = .empty
            return environment.readyToCalculate
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.readyForCalculate)
            
        case .resetAlert(action: .buttonTapped(.no)):
            state.resetAlertState = nil
            return .none
            
        case .resetAlert(action: .buttonTapped(.yes)):
            guard let alertViewVisible = state.resetAlertState?.isVisible else { return .none }
            state.resetAlertState = nil
            environment.setItemToDefaults(.alertViewVisible, alertViewVisible)
            let result = environment.calculate(.result(type: state.presetState.selectedPreset))
            return Effect(value: .overwrite(list: result))
            
        case .readyForCalculate(action: .success):
            let item = environment.calculate(.result(type: state.presetState.selectedPreset))
            return .merge(
                Effect(value: .update(list: .success(item))),
                Effect(value: .animatedImage(action: .stopAnimate))
            )
            
        case .readyForCalculate(action: .failure):
            return environment.readyToCalculate
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.readyForCalculate)
            
        case .animatedImage(action: .stopAnimate):
            state.animatedImageState = nil
            return .none
            
        case .contentHeader,
                .abilityRow,
                .resetAlert,
                .animatedImage:
            return .none
        }
    }
)

fileprivate extension Array where Element == AbilityType {
    static var empty: Self = [
        .positive(1),
        .positive(2),
        .negative
    ]
}
