// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - DetailInfo

@available(watchOS, unavailable)
struct DetailInfo: View {
    // MARK: Lifecycle

    init(
        entry: any TimelineEntry,
        dailyNote: any DailyNoteProtocol,
        viewConfig: WidgetViewConfiguration,
        spacing: CGFloat = 13
    ) {
        self.entry = entry
        self.dailyNote = dailyNote
        self.viewConfig = viewConfig
        self.spacing = spacing
    }

    // MARK: Internal

    let entry: any TimelineEntry
    let dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let spacing: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if dailyNote.hasDailyTaskIntel {
                DailyTaskInfoBar(dailyNote: dailyNote)
            }
            switch dailyNote {
            case let dailyNote as any Note4GI:
                if dailyNote.homeCoinInfo.maxHomeCoin != 0 {
                    HomeCoinInfoBar(entry: entry, homeCoinInfo: dailyNote.homeCoinInfo)
                }

                if dailyNote.hasExpeditions {
                    ExpeditionInfoBar(dailyNote: dailyNote)
                }

                if let dailyNote = dailyNote as? GeneralNote4GI {
                    if dailyNote.transformerInfo.obtained, viewConfig.showTransformer {
                        TransformerInfoBar(transformerInfo: dailyNote.transformerInfo)
                    }
                    switch viewConfig.weeklyBossesShowingMethod {
                    case .neverShow:
                        EmptyView()
                    case .disappearAfterCompleted:
                        if dailyNote.weeklyBossesInfo.remainResinDiscount != 0 {
                            WeeklyBossesInfoBar(
                                weeklyBossesInfo: dailyNote.weeklyBossesInfo
                            )
                        }
                    case .alwaysShow:
                        WeeklyBossesInfoBar(weeklyBossesInfo: dailyNote.weeklyBossesInfo)
                    }
                }
            case let dailyNote as Note4HSR:
                if dailyNote.hasExpeditions {
                    ExpeditionInfoBar(dailyNote: dailyNote)
                }
                if let dailyNote = dailyNote as? WidgetNote4HSR {
                    SimulUnivInfoBar(dailyNote: dailyNote)
                }
            case _ as Note4ZZZ:
                EmptyView() // TODO: Needs further implementation.
            default:
                EmptyView()
            }
        }
        .padding(.trailing)
    }
}
