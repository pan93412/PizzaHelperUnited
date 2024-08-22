// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ContentView

@MainActor
public struct ContentView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        TabView(selection: index) {
            ForEach(NavItems.allCases) { navCase in
                if navCase.isExposed {
                    navCase
                }
            }
        }
        .apply { theContent in
            #if compiler(>=6.0) && canImport(UIKit, _version: 18.0)
            if #unavailable(iOS 18.0), #unavailable(macCatalyst 18.0) {
                theContent
            } else {
                theContent
                    .tabViewStyle(.sidebarAdaptable)
                    .tabViewCustomization(.none)
            }
            #else
            theContent
            #endif
        }
        .tint(tintForCurrentTab)
        .onChange(of: selection) { _, _ in
            simpleTaptic(type: .selection)
        }
        // .initializeApp()
    }

    // MARK: Internal

    @preconcurrency @MainActor
    enum NavItems: Int, View, CaseIterable, Identifiable {
        case today = 1
        case showcaseDetail = 2
        case utils = 3
        case appSettings = 0

        // MARK: Public

        @ViewBuilder @MainActor public var body: some View {
            switch self {
            case .today:
                TodayTabPage()
                    .tag(rawValue) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case .showcaseDetail:
                DetailPortalTabPage()
                    .tag(rawValue) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case .utils:
                UtilsTabPage()
                    .tag(rawValue) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case .appSettings:
                AppSettingsTabPage()
                    .tag(rawValue) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            }
        }

        @ViewBuilder @MainActor public var label: some View {
            switch self {
            case .today: Label("tab.today".i18nPZHelper, systemSymbol: .windshieldFrontAndWiperAndDrop)
            case .showcaseDetail: Label("tab.details".i18nPZHelper, systemSymbol: .personTextRectangleFill)
            case .utils: Label("tab.utils".i18nPZHelper, systemSymbol: .shippingboxFill)
            case .appSettings: Label("tab.settings".i18nPZHelper, systemSymbol: .wrenchAndScrewdriverFill)
            }
        }

        // MARK: Internal

        static var exposedCaseTags: [Int] {
            #if DEBUG
            [1, 2, 3, 0]
            #else
            [2, 0]
            #endif
        }

        nonisolated var id: Int { rawValue }

        var isExposed: Bool {
            Self.exposedCaseTags.contains(rawValue)
        }
    }

    @Default(.appTabIndex) var appIndex: Int

    var index: Binding<Int> { Binding(
        get: { selection },
        set: {
            if $0 != selection {
                ViewEventBroadcaster.shared.stopRootTabTasks()
            }
            selection = $0
            appIndex = $0
            UserDefaults.baseSuite.synchronize()
        }
    ) }

    // MARK: Private

    @State private var selection: Int = {
        guard Defaults[.restoreTabOnLaunching] else { return 0 }
        guard NavItems.allCases.map(\.rawValue).contains(Defaults[.appTabIndex]) else { return 0 }
        return Defaults[.appTabIndex]
    }()

    @Environment(\.colorScheme) private var colorScheme

    private var tintForCurrentTab: Color {
        .accentColor
        // switch selection {
        // case 0, 1: return .accessibilityAccent(colorScheme)
        // default: return .accentColor
        // }
    }
}
