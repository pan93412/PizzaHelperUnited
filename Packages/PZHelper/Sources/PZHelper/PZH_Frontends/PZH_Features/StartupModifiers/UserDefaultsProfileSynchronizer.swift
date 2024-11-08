// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import UserNotifications

// MARK: - UserDefaultsProfileSynchronizer

private struct UserDefaultsProfileSynchronizer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                Task { @MainActor in
                    await PZProfileActor.shared.syncAllDataToUserDefaults()
                }
            }
    }
}

extension View {
    func syncProfilesToUserDefaults() -> some View {
        modifier(UserDefaultsProfileSynchronizer())
    }
}