import Foundation

final class PermanentStorage {
    static let live = PermanentStorage(.live)
    static let debug = PermanentStorage(.debug)
    private let userDefaults: UserDefaults = .standard
    
    fileprivate init(_ state: State) {
        guard case .debug = state else { return }
        self[.alertViewVisible] = true
        self[.guideViewVisible] = true
    }
    
    subscript<T>(raw: UserDefaults.RawType<T>) -> T {
        get {
            guard let value = userDefaults.value(forKey: raw.key) as? T else { return raw.default }
            return value
        }
        set {
            userDefaults.setValue(newValue, forKey: raw.key)
        }
    }
}

extension PermanentStorage {
    enum State {
        case live
        case debug
    }
}

extension UserDefaults {
    struct RawType<Value> {
        static var alertViewVisible: UserDefaults.RawType<Bool> {
            UserDefaults.RawType(key: "alertViewVisible", default: true)
        }
        static var guideViewVisible: UserDefaults.RawType<Bool> {
            UserDefaults.RawType(key: "guideViewVisible", default: true)
        }
        let key: String
        let `default`: Value
        private init(key: String, `default`: Value) {
            self.key = key
            self.default = `default`
        }
    }
}
