import Foundation

extension String {
    var fullRange: NSRange {
        NSRange(location: .zero, length: self.count)
    }
}
