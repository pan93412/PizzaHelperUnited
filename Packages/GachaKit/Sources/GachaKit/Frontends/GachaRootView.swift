// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - GachaRootView

public struct GachaRootView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = "gachaKit.GachaRootView.navTitle".i18nGachaKit

    public static var navIcon: Image { Image("GachaRecordMgr_NavIcon", bundle: .module) }

    @MainActor public var body: some View {
        coreBody
            .navigationTitle(theVM.currentGPIDTitle ?? Self.navTitle)
            .navBarTitleDisplayMode(.large)
        // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
        #if os(iOS) || targetEnvironment(macCatalyst)
            .toolbar(.hidden, for: .tabBar)
        #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    GachaProfileSwitcherView()
                }
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .confirmationAction) {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Menu {
                        NavigationLink("gachaKit.menu.getGachaRecords") {
                            EmptyView() // GetGachaRecordView()
                        }.disabled(true)
                        NavigationLink("gachaKit.menu.manageGachaRecords") {
                            EmptyView() // ManageGachaRecordView()
                        }.disabled(true)
                        NavigationLink("gachaKit.menu.exchangeGachaRecords") {
                            EmptyView() // ExchangeGachaView()
                        }.disabled(true)
                        Divider()
                        NavigationLink("gachaKit.menu.listCloudDataFromPreviousVersions".i18nGachaKit) {
                            CDGachaMODebugView()
                        }
                        if theVM.hasInheritableGachaEntries {
                            Button("gachaKit.menu.inheritCloudDataFromPreviousVersions".i18nGachaKit) {
                                theVM.migrateOldGachasIntoProfiles()
                            }
                        }
                        Divider()
                        Button("gachaKit.menu.rebuildGachaUIDList".i18nGachaKit) {
                            theVM.rebuildGachaUIDList()
                        }
                    } label: {
                        Image(systemSymbol: .goforwardPlus)
                    }
                    .disabled(theVM.taskState == .busy)
                }
            }
            .task {
                if let task = theVM.task { await task.value }
                if !theVM.hasInheritableGachaEntries {
                    theVM.checkWhetherInheritableDataExists()
                }
            }
            .environment(theVM)
    }

    // MARK: Fileprivate

    @Environment(\.modelContext) fileprivate var modelContext
    @Query(sort: \PZProfileMO.priority) fileprivate var pzProfiles: [PZProfileMO]
    @Query fileprivate var pzGachaProfileIDs: [PZGachaProfileMO]
    @Environment(GachaVM.self) fileprivate var theVM
}

extension GachaRootView {
    @MainActor @ViewBuilder public var coreBody: some View {
        Form {
            if theVM.currentGPID != nil {
                GachaProfileView()
            } else if !pzGachaProfileIDs.isEmpty {
                Text("gachaKit.prompt.pleaseChooseGachaProfile".i18nGachaKit)
            } else {
                Text("gachaKit.prompt.noGachaProfileFound".i18nGachaKit)
            }
        }
        .formStyle(.grouped)
    }
}
