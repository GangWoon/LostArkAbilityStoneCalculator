import SwiftUI
import ComposableArchitecture

struct PresetView: View {
    let store: Store<PresetState, PresetAction>
    private let theme: Theme = .standard
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewStore.presets, id: \.self) { preset in
                    HStack(spacing: 12) {
                        Button(action: { viewStore.send(.buttonTapped(preset)) }) {
                            AttributedText(
                                text: preset.description,
                                baseAttribute: Attribute(
                                    range: preset.description.fullRange,
                                    font: theme.font.buttonNumber,
                                    color: theme.color.foreground
                                ),
                                pointAttribute: Attribute(
                                    range: NSRange(location: .zero, length: 2),
                                    font: theme.font.buttonText,
                                    color: theme.color.foreground
                                ),
                                lineHeightMultple: 1.26
                            )
                            .padding(.vertical, 5)
                            .padding(.horizontal, 12)
                            .background(buildBackground(isSelected: viewStore.selectedPreset == preset))
                            .cornerRadius(16)
                        }
                        
                        AttributedText(
                            text: preset.detailDescription,
                            baseAttribute: Attribute(
                                range: preset.detailDescription.fullRange,
                                font: theme.font.descriptionNumber,
                                color: theme.color.foreground
                            ),
                            pointAttribute: Attribute(
                                range: preset.descriptionTextStringIndex,
                                font: theme.font.descriptionText,
                                color: theme.color.foreground
                            ),
                            lineHeightMultple: 1.26
                        )
                        
                        Spacer()
                    }
                    .frame(height: 30)
                }
            }
            .padding(.leading, 32)
        }
    }
    
    private func buildBackground(isSelected: Bool) -> some View {
        Group {
            if isSelected {
                theme.color.selectedBackground
            } else {
                theme.image.innerShadow
            }
        }
    }
}

// MARK: - Theme
extension PresetView {
    struct Theme {
        static let standard = Self(
            font: .standard,
            color: .standard,
            image: .standard
        )
        
        struct FontCollection {
            static let standard = Self(
                buttonNumber: .custom(style: .scDream(.medium), size: 12),
                buttonText: .custom(style: .montserrat(.medium), size: 13),
                descriptionNumber: .custom(style: .montserrat(.medium), size: 13),
                descriptionText: .custom(style: .scDream(.extraLight), size: 13)
            )
            let buttonNumber: UIFont
            let buttonText: UIFont
            let descriptionNumber: UIFont
            let descriptionText:UIFont
        }
        
        struct ColorCollection {
            static let standard = Self(
                foreground: .white,
                selectedBackground: Color(red: 91 / 255, green: 96 / 255, blue: 253 / 255)
            )
            let foreground: UIColor
            let selectedBackground: Color
        }
        
        struct ImageCollection {
            static let standard = Self(innerShadow: Image("presetInnerShadow"))
            let innerShadow: Image
        }
        let font: FontCollection
        let color: ColorCollection
        let image: ImageCollection
    }
}

// MARK: - State
struct PresetState: Equatable {
    static var empty = Self(
        presets: AbilityStonePreset.allCases,
        selectedPreset: .totalFourteen
    )
    let presets: [AbilityStonePreset]
    var selectedPreset: AbilityStonePreset
}

// MARK: - Action
enum PresetAction: Equatable {
    case buttonTapped(AbilityStonePreset)
}

// MARK: - Reducer
let presetReducer = Reducer<PresetState, PresetAction, Void> { state, action, _ in
    guard case let .buttonTapped(presetType) = action else { return .none }
    state.selectedPreset = presetType
    return .none
}

// MARK: - Type
extension AbilityStonePreset: CustomStringConvertible {
    var description: String {
        switch self {
        case .totalSixteen:
            return "16 돌"
        case .totalFourteen:
            return "14 돌"
        }
    }
    
    fileprivate var descriptionTextStringIndex: NSRange {
        guard let item = detailDescription.range(of: " 제외") else { return .init() }
        return NSRange(item, in: detailDescription)
    }
    
    fileprivate var detailDescription: String {
        switch self {
        case .totalSixteen:
            return "9/7, 10/6 (8/8 제외)"
        case .totalFourteen:
            return "7/7, 9/5, 10/4 (8/6 제외)"
        }
    }
}

