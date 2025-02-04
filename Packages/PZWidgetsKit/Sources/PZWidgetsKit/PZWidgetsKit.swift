// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - PZWidgets

public enum PZWidgets {}

extension PZWidgets {
    static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.doesRelativeDateFormatting = true
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()

    static let intervalFormatter: DateComponentsFormatter = {
        let dateComponentFormatter = DateComponentsFormatter()
        dateComponentFormatter.allowedUnits = [.hour, .minute]
        dateComponentFormatter.maximumUnitCount = 2
        dateComponentFormatter.unitsStyle = .brief
        return dateComponentFormatter
    }()

    @MainActor
    public static func attemptToAutoInheritOldAccountsIntoProfiles() {
        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
    }
}
