//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// The user-facing explanation for a failure to open a store. Only a full device storage is told apart, because it is
// the one cause the user can fix; every other error gets a general text, with the error code shown elsewhere.
enum ErrorMessages {
    // The message of the "iCloud Sync Error" alert.
    static func syncAlert(for error: (any Error)?) -> LocalizedStringResource {
        if error?.isDeviceStorageFull == true {
            return "Your device is out of storage, so Lummi couldn't use iCloud sync. Free up some space and try again."
        }
        return "Lummi couldn't use iCloud sync. Your joys are safe on this device. Check your iCloud settings and try again later."
    }

    // The explanation on the full-screen storage error.
    static func storageExplanation(for error: any Error) -> LocalizedStringResource {
        if error.isDeviceStorageFull {
            return """
                Your device is out of storage, so Lummi couldn't open its storage. \
                Your joys haven't been deleted. Free up some space and try again.
                """
        }
        return "Lummi couldn't open its storage. Your joys haven't been deleted. Try again, or restart the app."
    }
}
