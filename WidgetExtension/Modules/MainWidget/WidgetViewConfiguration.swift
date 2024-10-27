// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
// @_exported import PZIntentKit
import SwiftUI
import WallpaperKit

typealias WidgetBackground = WidgetBackgroundAppEntity
typealias ExpeditionShowingMethod = ExpeditionShowingMethodAppEnum

extension WidgetBackgroundAppEntity {}

// MARK: - WidgetViewConfiguration

struct WidgetViewConfiguration {
    // MARK: Lifecycle

    init(_ intent: SelectAccountIntent, _ noticeMessage: String?) {
        self.showAccountName = true
        self.showTransformer = intent.showTransformer ?? true
        self.weeklyBossesShowingMethod = intent.weeklyBossesShowingMethod ?? .disappearAfterCompleted
        self.randomBackground = intent.randomBackground ?? false
        if let backgrounds = intent.background {
            self.selectedBackgrounds = backgrounds.isEmpty ? [.defaultBackground] : backgrounds
        } else {
            self.selectedBackgrounds = [.defaultBackground]
        }
        self.isDarkModeOn = intent.isDarkModeOn ?? true
        self.showMaterialsInLargeSizeWidget = intent.showMaterialsInLargeSizeWidget ?? true
    }

    init(noticeMessage: String? = nil) {
        self.showAccountName = true
        self.showTransformer = true
        self.weeklyBossesShowingMethod = .disappearAfterCompleted
        self.selectedBackgrounds = [.defaultBackground]
        self.randomBackground = false
        self.isDarkModeOn = true
        self.showMaterialsInLargeSizeWidget = true
        self.noticeMessage = noticeMessage
    }

    init(
        showAccountName: Bool,
        showTransformer: Bool,
        noticeExpeditionWhenAllCompleted: Bool,
        showExpeditionCompleteTime: Bool,
        showWeeklyBosses: Bool,
        noticeMessage: String?
    ) {
        self.showAccountName = showAccountName
        self.showTransformer = showTransformer
        self.weeklyBossesShowingMethod = .disappearAfterCompleted
        self.randomBackground = false
        self.selectedBackgrounds = [.defaultBackground]
        self.isDarkModeOn = true
        self.showMaterialsInLargeSizeWidget = true
    }

    // MARK: Internal

    static let defaultConfig = Self()

    let showAccountName: Bool
    let showTransformer: Bool
    let weeklyBossesShowingMethod: WeeklyBossesShowingMethodAppEnum
    var noticeMessage: String?

    let isDarkModeOn: Bool

    let showMaterialsInLargeSizeWidget: Bool

    var randomBackground: Bool
    var selectedBackgrounds: [WidgetBackground]

    var background: WidgetBackground {
        guard !randomBackground else {
            return WidgetBackground.randomElementOrNamecardBackground
        }
        if selectedBackgrounds.isEmpty {
            return .defaultBackground
        } else {
            return selectedBackgrounds.randomElement()!
        }
    }

    mutating func addMessage(_ msg: String) {
        noticeMessage = msg
    }
}

// MARK: - ExpeditionViewConfiguration

struct ExpeditionViewConfiguration {
    let noticeExpeditionWhenAllCompleted: Bool
    let expeditionShowingMethod: ExpeditionShowingMethod
}

extension WidgetBackground {
    var imageName: String? {
        if BackgroundOptions.namecards.contains(id) {
            return id
        } else { return nil }
    }

    var iconName: String? {
        switch id {
        case "game.elements.anemo":
            return "element_Anemo"
        case "game.elements.hydro":
            return "element_Hydro"
        case "game.elements.cryo":
            return "element_Cryo"
        case "game.elements.pyro":
            return "element_Pyro"
        case "game.elements.geo":
            return "element_Geo"
        case "game.elements.electro":
            return "element_Electro"
        case "game.elements.dendro":
            return "element_Dendro"
        case "game.elements.fantastico":
            return "element_Fantastico"
        case "game.elements.posesto":
            return "element_Posesto"
        case "game.elements.physico":
            return "element_Physico"
        default:
            return nil
        }
    }

    var colors: [Color] {
        switch id {
        case "app.background.purple":
            return [
                Color.purple,
                Color.purple.addBrightness(-0.15),
                Color.purple.addBrightness(-0.3),
            ]
        case "app.background.gold":
            return [
                Color.yellow,
                Color.yellow.addBrightness(-0.15),
                Color.yellow.addBrightness(-0.3),
            ]
        case "app.background.gray":
            return [
                Color.gray,
                Color.gray.addBrightness(-0.15),
                Color.gray.addBrightness(-0.3),
            ]
        case "app.background.green":
            return [
                Color.green,
                Color.green.addBrightness(-0.15),
                Color.green.addBrightness(-0.3),
            ]
        case "app.background.blue":
            return [
                Color.blue,
                Color.blue.addBrightness(-0.15),
                Color.blue.addBrightness(-0.3),
            ]
        case "app.background.red":
            return [
                Color.red,
                Color.red.addBrightness(-0.15),
                Color.red.addBrightness(-0.3),
            ]
        case "game.elements.anemo":
            return [
                Color.mint,
                Color.mint.addBrightness(-0.15),
                Color.mint.addBrightness(-0.3),
            ]
        case "game.elements.hydro":
            return [
                Color.blue,
                Color.blue.addBrightness(-0.15),
                Color.blue.addBrightness(-0.3),
            ]
        case "game.elements.cryo":
            return [
                Color.cyan,
                Color.cyan.addBrightness(-0.15),
                Color.cyan.addBrightness(-0.3),
            ]
        case "game.elements.pyro":
            return [
                Color.red,
                Color.red.addBrightness(-0.15),
                Color.red.addBrightness(-0.3),
            ]
        case "game.elements.geo":
            return [
                Color.orange,
                Color.orange.addBrightness(-0.15),
                Color.orange.addBrightness(-0.3),
            ]
        case "game.elements.electro":
            return [
                Color.purple,
                Color.purple.addBrightness(-0.15),
                Color.purple.addBrightness(-0.3),
            ]
        case "game.elements.dendro":
            return [
                Color.green,
                Color.green.addBrightness(-0.15),
                Color.green.addBrightness(-0.3),
            ]
        case "game.elements.posesto":
            return [
                Color.indigo,
                Color.indigo.addBrightness(-0.15),
                Color.indigo.addBrightness(-0.3),
            ]
        case "game.elements.fantastico":
            return [
                Color.yellow,
                Color.yellow.addBrightness(-0.15),
                Color.yellow.addBrightness(-0.3),
            ]
        case "game.elements.physico":
            return [
                Color.gray,
                Color.gray.addBrightness(-0.15),
                Color.gray.addBrightness(-0.3),
            ]
        case "app.background.intertwinedFate":
            return [
                Color("bgColor.intertwinedFate.1", bundle: .main),
                Color("bgColor.intertwinedFate.2", bundle: .main),
                Color("bgColor.intertwinedFate.3", bundle: .main),
            ]
        default:
            return []
        }
    }
}