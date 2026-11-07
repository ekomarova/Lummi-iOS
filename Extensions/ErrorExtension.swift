//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Domain and codes that mean the device ran out of space: Cocoa file write, SQLite "database or disk is full", POSIX ENOSPC.
private let deviceStorageFullCodes: [String: Set<Int>] = [
    NSCocoaErrorDomain: [NSFileWriteOutOfSpaceError],
    "NSSQLiteErrorDomain": [13],
    NSPOSIXErrorDomain: [Int(ENOSPC)]
]

// Errors wrap each other, so every walk down the underlying chain is cut off defensively after this many errors.
let maxUnderlyingErrorDepth = 5

extension Error {
    // This error followed by the errors it wraps through `NSUnderlyingErrorKey`, outermost first, cut off after
    // `maxDepth` errors in total. Empty when `maxDepth` is 0.
    func underlyingErrors(maxDepth: Int = maxUnderlyingErrorDepth) -> [Error] {
        var chain: [Error] = []
        var current: Error? = self
        while let error = current, chain.count < maxDepth {
            chain.append(error)
            current = (error as NSError).userInfo[NSUnderlyingErrorKey] as? Error
        }
        return chain
    }

    // A short, language-independent identifier such as "NSCocoaErrorDomain 134110". Unlike `localizedDescription`,
    // which is system text that may be technical or in the wrong language, it is safe to show as a reference for support.
    var technicalCode: String {
        let nsError = self as NSError
        return "\(nsError.domain) \(nsError.code)"
    }

    // Whether the error, or one it wraps, says the device is out of storage. Unlike most store errors, the user can fix it.
    var isDeviceStorageFull: Bool {
        underlyingErrors().contains { error in
            let nsError = error as NSError
            return deviceStorageFullCodes[nsError.domain]?.contains(nsError.code) == true
        }
    }
}
