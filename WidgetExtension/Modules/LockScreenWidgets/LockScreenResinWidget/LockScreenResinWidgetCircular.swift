// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
struct LockScreenResinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var staminaMonochromeIconAssetName: String {
        switch result {
        case let .success(data):
            return switch data.game {
            case .genshinImpact: "icon.resin"
            case .starRail: "icon.trailblazePower"
            case .zenlessZone: "icon.zzzBattery"
            }
        case .failure: return "icon.resin"
        }
    }

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                let staminaIntel = data.staminaIntel
                Gauge(value: Double(staminaIntel.finished) / Double(staminaIntel.all)) {
                    LinearGradient(
                        colors: [
                            .init("iconColor.resin.dark"),
                            .init("iconColor.resin.middle"),
                            .init("iconColor.resin.light"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .mask(
                        Image(staminaMonochromeIconAssetName, bundle: .main)
                            .resizable()
                            .scaledToFit()
                    )
                } currentValueLabel: {
                    let value = "\(staminaIntel.finished)"
                    Text(verbatim: value)
                        .font(.title3)
                        .fontWidth(value.count > 3 ? .condensed : .standard)
                        .minimumScaleFactor(0.1)
                }
                .gaugeStyle(
                    ProgressGaugeStyle(
                        circleColor: Color("iconColor.resin.middle", bundle: .main)
                    )
                )
            case .failure:
                Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                    LinearGradient(
                        colors: [
                            .init("iconColor.resin.dark"),
                            .init("iconColor.resin.middle"),
                            .init("iconColor.resin.light"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .mask(
                        Image(staminaMonochromeIconAssetName, bundle: .main)
                            .resizable()
                            .scaledToFit()
                    )
                } currentValueLabel: {
                    Image(systemSymbol: .ellipsis)
                }
                .gaugeStyle(
                    ProgressGaugeStyle(
                        circleColor: Color("iconColor.resin.middle", bundle: .main)
                    )
                )
            }
        default: // This includes the `.accented` case.
            switch result {
            case let .success(data):
                let staminaIntel = data.staminaIntel
                Gauge(value: Double(staminaIntel.finished) / Double(staminaIntel.all)) {
                    Image(staminaMonochromeIconAssetName, bundle: .main)
                        .resizable()
                        .scaledToFit()
                } currentValueLabel: {
                    let value = "\(staminaIntel.finished)"
                    Text(verbatim: value)
                        .font(.title3)
                        .fontWidth(value.count > 3 ? .condensed : .standard)
                        .minimumScaleFactor(0.1)
                }
                .gaugeStyle(ProgressGaugeStyle())
            case .failure:
                Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                    Image(staminaMonochromeIconAssetName, bundle: .main)
                        .resizable()
                        .scaledToFit()
                } currentValueLabel: {
                    Image(systemSymbol: .ellipsis)
                }
                .gaugeStyle(ProgressGaugeStyle())
            }
        }
    }
}
