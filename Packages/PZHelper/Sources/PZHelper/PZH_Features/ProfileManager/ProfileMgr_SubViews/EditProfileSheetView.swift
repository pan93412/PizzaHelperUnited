// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

struct EditProfileSheetView: View {
    // MARK: Lifecycle

    init(profile: PZProfileMO, isShown: Binding<Bool>) {
        self._isShown = isShown
        self.profile = profile
    }

    // MARK: Internal

    var body: some View {
        NavigationView {
            List {
                Text(verbatim: "# Under Construction")
            }
            .navigationTitle("profileMgr.edit.title".i18nPZHelper)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Private

    @Binding private var isShown: Bool
    @State private var profile: PZProfileMO
}