// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssReportView4HSR

public struct AbyssReportView4HSR: AbyssReportView {
    // MARK: Lifecycle

    public init(data: AbyssReportData) {
        self.data = data
    }

    // MARK: Public

    public typealias AbyssReportData = HoYo.AbyssReport4HSR

    public static let navTitle = "hylKit.abyssReportView4HSR.navTitle".i18nHYLKit

    public static var abyssIcon: Image { Image("hsr_abyss", bundle: .module) }

    public var data: AbyssReportData

    @MainActor public var body: some View {
        Form {
            if data.hasData {
                contents
            } else {
                blankView
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: Internal

    @MainActor @ViewBuilder var blankView: some View {
        Section {
            Text(verbatim: "hylKit.abyssReport.noDataAvailableForThisSeason".i18nHYLKit)
        }
        .listRowMaterialBackground()
    }

    @MainActor @ViewBuilder var contents: some View {
        stats
        floorList
    }

    @MainActor @ViewBuilder var stats: some View {
        Section {
            LabeledContent {
                Text(verbatim: data.maxFloorNumStr)
            } label: {
                Text("hylKit.abyssReport.hsr.stat.maxFloorConquered".i18nHYLKit)
            }
            LabeledContent {
                Text(verbatim: data.starNum.description)
            } label: {
                Text("hylKit.abyssReport.hsr.stat.starsGained".i18nHYLKit)
            }
            LabeledContent {
                Text(verbatim: data.battleNum.description)
            } label: {
                Text("hylKit.abyssReport.hsr.stat.numOfBattles".i18nHYLKit)
            }
        } header: {
            HStack {
                Text("hylKit.abyssReport.hsr.stats.header".i18nHYLKit)
                Spacer()
                Text("hylKit.abyssReport.hsr.stat.seasonID".i18nHYLKit + " \(data.scheduleID)")
            }
        }
        .listRowMaterialBackground()
    }

    @MainActor @ViewBuilder var floorList: some View {
        ForEach(data.allFloorDetail, id: \.mazeID) { floorData in
            Section {
                if floorData.isSkipped {
                    Text("hylKit.abyssReport.floor.thisFloorIsSkipped".i18nHYLKit)
                } else {
                    let theContent = Group {
                        drawBattleNode(floorData.node1, spacers: false)
                        Spacer()
                        drawBattleNode(floorData.node2, spacers: false)
                    }
                    let theContentLabeled = Group {
                        drawBattleNode(floorData.node1, label: "hylKit.abyssReport.floor.1stHalf".i18nHYLKit)
                        Spacer()
                        drawBattleNode(floorData.node2, label: "hylKit.abyssReport.floor.2ndHalf".i18nHYLKit)
                    }
                    ViewThatFits(in: .horizontal) {
                        HStack { theContentLabeled }
                        HStack { theContent }
                        VStack { theContentLabeled }
                        VStack { theContent }
                    }
                }
            } header: {
                HStack {
                    Text(
                        "hylKit.abyssReport.floor.title:\(floorData.floorNumStr)",
                        bundle: .module
                    )
                    Spacer()
                    Text(verbatim: floorData.node1.challengeTime.description)
                    Text(verbatim: String(repeating: " ⭐️", count: floorData.starNum))
                }
            }
            .listRowMaterialBackground()
        }
    }

    @MainActor @ViewBuilder
    func drawBattleNode(_ node: HoYo.AbyssReport4HSR.FHNode, label: String = "", spacers: Bool = true) -> some View {
        if !label.isEmpty {
            Text(label)
                .fontDesign(.monospaced)
                .padding()
        }
        if spacers { Spacer() }
        HStack {
            var guardedAvatars: [HoYo.AbyssReport4HSR.FHAvatar] {
                var result = node.avatars
                while result.count < 4 {
                    result.append(.init(id: -114_514, level: 0, icon: "", rarity: 0, element: "", eidolon: 0))
                }
                return result
            }
            ForEach(node.avatars) { avatar in
                let decoratedIconSize = decoratedIconSize
                Group {
                    if avatar.id == -114_514 {
                        Color.primary.opacity(0.3)
                    } else if ThisDevice.isSmallestHDScreenPhone {
                        CharacterIconView(
                            charID: avatar.id.description,
                            size: decoratedIconSize,
                            circleClipped: false,
                            clipToHead: true
                        )
                        .corneredTag(
                            verbatim: avatar.level.description,
                            alignment: .bottomTrailing,
                            textSize: 11
                        )
                    } else {
                        CharacterIconView(charID: avatar.id.description, cardSize: decoratedIconSize / 0.74)
                            .corneredTag(
                                verbatim: "Lv.\(avatar.level.description)",
                                alignment: .bottom,
                                textSize: 11
                            )
                    }
                }.frame(
                    width: decoratedIconSize,
                    height: ThisDevice.isSmallestHDScreenPhone ? decoratedIconSize : (decoratedIconSize / 0.74)
                )
                if spacers { Spacer() }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        Form {
            AbyssReportView4HSR(data: try! AbyssReportTestAssets.hsrCurr.getReport4HSR())
        }
        .formStyle(.grouped)
    }
}

#endif
