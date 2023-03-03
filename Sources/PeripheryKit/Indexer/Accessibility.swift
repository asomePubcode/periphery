import Foundation

public enum Accessibility: String {
    case `public` = "public"
    case `internal` = "internal"
    case `private` = "private"
    case `fileprivate` = "fileprivate"
    case `open` = "open"

    var isObjcAccessible: Bool {
        self == .public || self == .open
    }
}
