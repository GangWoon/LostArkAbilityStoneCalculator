import Foundation
import Darwin
import Combine

enum AbilityStonePreset: CaseIterable {
    case totalSixteen
    case totalFourteen
}

enum Error: Swift.Error, Equatable {
    case notReady
}

struct CalculateResult: Equatable {
    static var empty = Self(
        probabilityOfSuccess: "75%",
        recommenedProbability: 0.05919555623216688,
        firstPositiveRP: 0.05919555623216688,
        secondPositiveRP: 0.05919555623216688,
        negativeRP: 0.035396335823418536
    )
    /// RP == "RecommendationProbability"
    var valueList: [(rp: String, isRecommened: Bool)] {
        [
            (firstPositiveRP.stonePercent(type: .recommed), firstPositiveRP == recommenedProbability),
            (secondPositiveRP.stonePercent(type: .recommed), secondPositiveRP == recommenedProbability),
            (negativeRP.stonePercent(type: .recommed), negativeRP == recommenedProbability)
        ]
    }
    let probabilityOfSuccess: String
    let recommenedProbability: Double
    let firstPositiveRP: Double
    let secondPositiveRP: Double
    let negativeRP: Double
}

final class AbilityStoneCalculator {
    private let numberOfAttempts: Int
    private let firstPositiveGoal: Int
    private let secondPositiveGoal: Int
    private var positiveGoalSum: Int
    private let negativeGoal: Int
    private var pmax: Int
    private var sequence: [[Int]] = []
    private var goalCells: [[Int]]
    @Published private var dpList: [AbilityStonePreset: [Double]] = [: ]
    @Published var isValid: Bool = false
    
    init() {
        numberOfAttempts = 10
        firstPositiveGoal = .zero
        secondPositiveGoal = .zero
        positiveGoalSum = .zero
        negativeGoal = 4
        pmax = 6
        goalCells = .init(repeating: .init(repeating: .zero, count: 10), count: 10)
        build()
    }
    
    // MARK: - Open API
    func calculate(action: Action) -> CalculateResult {
        switch action {
        case let .result(type):
            let item = try? calculateResult(type: type)
            return item ?? .empty
            
        case let .undo(type):
            return undo(type: type)
            
        case let .reset(type):
            return reset(type: type)
            
        case let .preset(type):
            return preset(type: type)
            
        case let .toggle(abilityType, presetType, result):
            let item = try? toggle(type: abilityType, preset: presetType, result: result)
            return item ?? .empty
        }
    }
    
    private func undo(type: AbilityStonePreset) -> CalculateResult {
        _ = sequence.popLast()
        let calResult = try? calculateResult(type: type)
        
        return calResult ?? .empty
    }
    
    private func reset(type: AbilityStonePreset) -> CalculateResult {
        sequence = []
        let calResult = try? calculateResult(type: type)
        
        return calResult ?? .empty
    }
    
    private func preset(type: AbilityStonePreset) -> CalculateResult {
        positiveGoalSum = type.sum
        goalCells = buildGoalCellsFromGoal(
            numberOfAttempts: numberOfAttempts,
            firstPositiveGoal: firstPositiveGoal,
            secondPositiveGoal: secondPositiveGoal,
            positiveGoalSum: positiveGoalSum
        )
        switch type {
        case .totalSixteen:
            if numberOfAttempts >= 8 {
                goalCells[8][8] = .zero
            }
        case .totalFourteen:
            if numberOfAttempts >= 8 {
                goalCells[8][6] = .zero
                goalCells[6][8] = .zero
            }
        }
        let calResult = try? calculateResult(type: type)
        
        return calResult ?? .empty
    }
    
    private func toggle(
        type: AbilityType,
        preset: AbilityStonePreset,
        result: Int
    ) throws -> CalculateResult {
        let num_attempts = numberOfAttempts
        var cnt: Int = .zero
        let position = type.index
        for attempt in sequence {
            if attempt[0] == position {
                cnt += 1
            }
        }
        if cnt < num_attempts {
            sequence.append([position, result])
        }
        let calResult = try? calculateResult(type: preset)
        
        return calResult ?? .empty
    }
    
    private func calculateResult(type: AbilityStonePreset) throws -> CalculateResult {
        guard let dp = dpList[type] else { throw Error.notReady }
        let firstPostive = calculateIndexFromSequence(
            goal: firstPositiveGoal,
            index: 1,
            numberOfAttempts: numberOfAttempts,
            sequence: sequence
        )
        let secondPostive = calculateIndexFromSequence(
            goal: secondPositiveGoal,
            index: 2,
            numberOfAttempts: numberOfAttempts,
            sequence: sequence
        )
        let nagative = calculateIndexFromSequence(
            goal: negativeGoal,
            index: 3,
            numberOfAttempts: numberOfAttempts,
            sequence: sequence
        )
        let params = Params(
            a: Int(firstPostive[0]),
            b: Int(secondPostive[0]),
            c: Int(nagative[0]),
            p: Int(calculatePmaxFromSequence(pmax: pmax, sequence: sequence)),
            d: Int(firstPostive[2]),
            e: Int(secondPostive[2]),
            f: Int(nagative[1])
        )
        let probabilityOfSuccess = calculatePmaxFromSequence(pmax: pmax, sequence: sequence).decodedPercent.stonePercent(type: .pos)
        let firstPositiveProbability = calculateFirstPositiveProbability(params: params, dp: dp)
        let secondPositiveProbability = calculateSecondPositiveProbability(params: params, dp: dp)
        let negativeProbability = calculateNegativeProbability(params: params, dp: dp)
        let recommenedProbability = max(firstPositiveProbability, secondPositiveProbability, negativeProbability)
        
        return CalculateResult(
            probabilityOfSuccess: probabilityOfSuccess,
            recommenedProbability: recommenedProbability,
            firstPositiveRP: firstPositiveProbability,
            secondPositiveRP: secondPositiveProbability,
            negativeRP: negativeProbability
        )
    }
    
    private func build() {
        Task {
            dpList[.totalSixteen] = await buildDPList(presetType: .totalSixteen)
            dpList[.totalFourteen] = await buildDPList(presetType: .totalFourteen)
            isValid.toggle()
        }
    }
    
    private func buildDPList(presetType type: AbilityStonePreset) async -> [Double] {
        return await withCheckedContinuation { continuation in
            positiveGoalSum = type.sum
            goalCells = buildGoalCellsFromGoal(
                numberOfAttempts: numberOfAttempts,
                firstPositiveGoal: firstPositiveGoal,
                secondPositiveGoal: secondPositiveGoal,
                positiveGoalSum: type.sum
            )
            switch type {
            case .totalSixteen:
                goalCells[8][8] = .zero
            case .totalFourteen:
                goalCells[8][6] = .zero
                goalCells[6][8] = .zero
            }
            let dp = buildDp(
                numberOfAttempts: numberOfAttempts,
                pmax: pmax,
                goalCells: goalCells
            )
            continuation.resume(returning: dp)
        }
    }
    
    private func buildGoalCellsFromGoal(
        numberOfAttempts count: Int,
        firstPositiveGoal: Int,
        secondPositiveGoal: Int,
        positiveGoalSum: Int
    ) -> [[Int]] {
        let closedRange = (0...count)
        let getItem: (Int) -> [Int] = { i in
            return closedRange
                .map { j in
                    let sum = i + j
                    let item = i >= firstPositiveGoal
                    && j >= secondPositiveGoal
                    && sum >= positiveGoalSum
                    ? 1 : 0
                    return item
                }
        }
        
        return closedRange
            .map(getItem)
    }
    
    private func calculatePmaxFromSequence(pmax: Int, sequence: [[Int]]) -> Int {
        var item = pmax - 1
        for attempt in sequence {
            if attempt[1] == .zero {
                item = min(item + 1, pmax - 1)
            } else {
                item = max(item - 1, .zero)
            }
        }
        
        return item
    }
    
    private func calculateIndexFromSequence(
        goal: Int,
        index: Int,
        numberOfAttempts: Int,
        sequence: [[Int]]
    ) -> [Int] {
        var na = numberOfAttempts
        var goal = goal
        var success = 0
        for attempt in sequence {
            if attempt[0] == index {
                na -= 1
                if attempt[1] == 1 {
                    goal -= 1
                    success += 1
                }
            }
        }
        
        return [na, goal, success]
    }
    
    private func buildDp(numberOfAttempts: Int, pmax: Int, goalCells: [[Int]]) -> [Double] {
        var itemList = Array<Double>(repeating: .zero, count: (Int(pow(Double(numberOfAttempts + 1), 6))) * pmax)
        let reverseClosedRange = (0...numberOfAttempts).reversed()
        let closedRange = (0...numberOfAttempts)
        
        for d in reverseClosedRange {
            for a in 0...(numberOfAttempts - d) {
                for e in reverseClosedRange {
                    for b in (0...numberOfAttempts - e) {
                        for c in closedRange {
                            for f in closedRange {
                                for p in 0..<pmax {
                                    var item: Double = .zero
                                    let params = Params(a: a, b: b, c: c, p: p, d: d, e: e, f: f)
                                    if goalCells[d][e] == 1
                                        && a == .zero
                                        && b == .zero
                                        && c <= f {
                                        item = 1
                                    } else if c < f {
                                        let newParams = Params(a: a, b: b, c: c, p: p, d: d, e: e, f: c)
                                        let index = newParams.index(numberOfAttempts: numberOfAttempts,pmax: pmax)
                                        item = itemList[index]
                                    } else {
                                        item = max(
                                            item,
                                            calculateFirstPositiveProbability(params: params, dp: itemList),
                                            calculateSecondPositiveProbability(params: params, dp: itemList),
                                            calculateNegativeProbability(params: params, dp: itemList)
                                        )
                                    }
                                    let index = params.index(numberOfAttempts: numberOfAttempts, pmax: pmax)
                                    itemList[index] = item
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return itemList
    }
    
    private func calculateFirstPositiveProbability(params: Params, dp: [Double]) -> Double {
        guard params.a != .zero && params.f >= .zero else { return .zero }
        let newParams = Params(
            a: params.a - 1,
            b: params.b,
            c: params.c,
            p: max(params.p - 1, .zero),
            d: params.d + 1,
            e: params.e,
            f: params.f
        )
        let newParams2 = Params(
            a: params.a - 1,
            b: params.b,
            c: params.c,
            p: min(params.p + 1, pmax - 1),
            d: params.d,
            e: params.e,
            f: params.f
        )
        let succ = params.d < numberOfAttempts ? params.p.decodedPercent * dp[newParams.index(numberOfAttempts: numberOfAttempts, pmax: pmax)] : .zero
        let fail = (1 - params.p.decodedPercent) * dp[newParams2.index(numberOfAttempts: numberOfAttempts, pmax: pmax)]
        
        return succ + fail
    }
    
    private func calculateSecondPositiveProbability(params: Params, dp: [Double]) -> Double {
        guard params.b != .zero && params.f >= .zero else { return .zero }
        let newParams1 = Params(
            a: params.a,
            b: params.b - 1,
            c: params.c,
            p: max(params.p - 1, .zero),
            d: params.d,
            e: params.e + 1,
            f: params.f
        )
        let newParams2 = Params(
            a: params.a,
            b: params.b - 1,
            c: params.c,
            p: min(params.p + 1, pmax - 1),
            d: params.d,
            e: params.e,
            f: params.f
        )
        let succ = params.e < numberOfAttempts ? params.p.decodedPercent * dp[newParams1.index(numberOfAttempts: numberOfAttempts, pmax: pmax)] : .zero
        let fail = (1 - params.p.decodedPercent) * dp[newParams2.index(numberOfAttempts: numberOfAttempts, pmax: pmax)]
        
        return succ + fail
    }
    
    private func calculateNegativeProbability(params: Params, dp: [Double]) -> Double {
        guard params.f >= .zero else { return .zero }
        let newParams = Params(
            a: params.a,
            b: params.b,
            c: params.c - 1,
            p: max(params.p - 1, .zero),
            d: params.d,
            e: params.e,
            f: params.f - 1
        )
        let newParams2 = Params(
            a: params.a,
            b: params.b,
            c: params.c - 1,
            p: min(params.p + 1, pmax - 1),
            d: params.d,
            e: params.e,
            f: params.f
        )
        
        return params.c > .zero ? (params.f == .zero ? 0 : params.p.decodedPercent * dp[newParams.index(numberOfAttempts: numberOfAttempts, pmax: pmax)]) + (1 - params.p.decodedPercent) * dp[newParams2.index(numberOfAttempts: numberOfAttempts, pmax: pmax)] : 0
    }
}

// MARK: - AbilityStoneCalculator.Action Extension ++
extension AbilityStoneCalculator {
    enum Action {
        case result(type: AbilityStonePreset)
        case undo(type: AbilityStonePreset)
        case reset(type: AbilityStonePreset)
        case preset(type:AbilityStonePreset)
        case toggle(abilityType: AbilityType, presetType: AbilityStonePreset, result: Int)
    }
}

// MARK: - FilePrivate Extension ++
extension AbilityType {
    fileprivate var index: Int {
        switch self {
        case let .positive(value):
            return value
        case .negative:
            return 3
        }
    }
}

extension Int {
    fileprivate var decodedPercent: Double {
        return 0.25 + Double(self) * 0.1
    }
}

extension Double {
    fileprivate enum `Type` {
        /// pos == ProbabilityOfSuccess
        case pos
        case recommed
    }
    
    fileprivate func stonePercent(type: `Type`) -> String {
        guard self != .zero else { return "0%" }
        var item: String = ""
        switch type {
        case .pos:
            item = String(format: "%0.f", self * 100)
        case .recommed:
            item = String(format: "%0.2f", self * 100)
        }
        return item + "%"
    }
}

private struct Params {
    let a, b, c, p, d, e, f: Int
    
    func index(numberOfAttempts: Int, pmax: Int) -> Int {
        let item = numberOfAttempts + 1
        return (((((a * item + b) * item + c) * pmax + p) * item + d) * item + e) * item + f
    }
}

extension AbilityStonePreset {
    fileprivate var sum: Int {
        switch self {
        case .totalSixteen:
            return 16
        case .totalFourteen:
            return 14
        }
    }
}
