// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ShowCaseListView

@MainActor
public struct ShowCaseListView<ProfileForList: EKQueriedProfileProtocol>: View {
    // MARK: Lifecycle

    public init(
        profile: ProfileForList,
        enkaDB: ProfileForList.DBType,
        asCardIcons: Bool = false
    ) {
        self.profile = profile
        self.enkaDB = enkaDB
        self.profileSummarized = profile.summarize(theDB: enkaDB)
        self.extraTerms = .init(lang: enkaDB.locTag, game: ProfileForList.DBType.game)
        self.asCardIcons = asCardIcons
    }

    // MARK: Public

    public var body: some View {
        Group {
            if asCardIcons {
                showAsCardIcons
            } else {
                showAsList
            }
        }
        .navigationDestination(for: Enka.AvatarSummarized.self) { currentAvatar in
            AvatarShowCaseView(
                selectedAvatarID: currentAvatar.id,
                profile: profileSummarized
            )
        }
    }

    @ViewBuilder public var showAsCardIcons: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(profileSummarized.summarizedAvatars) { avatar in
                        NavigationLink(value: avatar) {
                            avatar.asCardIcon(75)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            HelpTextForScrollingOnDesktopComputer(.horizontal)
        }
    }

    // MARK: Internal

    @ViewBuilder var showAsList: some View {
        List {
            listHeader
            Section {
                ForEach(profileSummarized.summarizedAvatars) { avatar in
                    NavigationLink(value: avatar) {
                        makeLabelForNavLink(avatar: avatar)
                    }
                }
            }
        }
        .navigationTitle(Text(verbatim: "\(profile.nickname) (\(profile.uid.description))"))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder var listHeader: some View {
        Section {
            HStack(spacing: 0) {
                let levelTag = "\(extraTerms.levelNameShortened)\(profile.level)"
                profile.localFittingIcon4SUI
                    .frame(width: 74, height: 60)
                    .corneredTag(
                        verbatim: levelTag,
                        alignment: .bottomTrailing,
                        textSize: 12
                    )
                    .padding(.trailing, 4)
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(verbatim: profile.nickname)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                            Text(verbatim: profile.signature)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .lineLimit(2)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                        Spacer()
                    }
                }
            }
        } footer: {
            HStack {
                Text(verbatim: "UID: \(profile.uid)")
                Spacer()
                Text(verbatim: "\(extraTerms.equilibriumLevel): \(profile.worldLevel)")
            }
            .secondaryColorVerseBackground()
        }
    }

    @ViewBuilder
    func makeLabelForNavLink(avatar: Enka.AvatarSummarized) -> some View {
        HStack(alignment: .center) {
            let intel = avatar.mainInfo
            let strLevel = "\(intel.terms.levelName): \(intel.avatarLevel)"
            let strEL = "\(intel.terms.constellationName): \(intel.constellation)"
            intel.avatarPhoto(
                size: ceil(Font.baseFontSize * 3),
                circleClipped: true,
                clipToHead: true
            )
            VStack(alignment: .leading) {
                Text(verbatim: intel.name).font(.headline).fontWeight(.bold)
                HStack {
                    Text(verbatim: strLevel)
                    Spacer()
                    Text(verbatim: strEL)
                }
                .monospacedDigit()
                .font(.subheadline)
            }
        }
        .foregroundStyle(.primary)
    }

    // MARK: Private

    @State private var profile: ProfileForList
    @State private var profileSummarized: ProfileForList.SummarizedType
    @State private var enkaDB: ProfileForList.DBType
    private let asCardIcons: Bool
    private let extraTerms: Enka.ExtraTerms

    private var allAvatarSummaries: [Enka.AvatarSummarized] {
        profile.summarizeAllAvatars(theDB: enkaDB)
    }
}

extension EKQueriedProfileProtocol {
    @MainActor
    public func asView(
        theDB: Self.DBType,
        expanded: Bool = false
    )
        -> ShowCaseListView<Self> {
        .init(profile: self, enkaDB: theDB, asCardIcons: !expanded)
    }
}

#if hasFeature(RetroactiveAttribute)
extension String: @retroactive Identifiable {}
#else
extension String: Identifiable {}
#endif

extension String {
    public var id: String { description }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
private let enkaDatabaseHSR = try! Enka.EnkaDB4HSR(locTag: "zh-tw")
private let enkaDatabaseGI = try! Enka.EnkaDB4GI(locTag: "zh-tw")
// swiftlint:enable force_try
// swiftlint:enable force_unwrapping

private let summaryHSR: Enka.QueriedProfileHSR = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileHSR.json"
    let dataURL = URL(fileURLWithPath: filePath)
    return try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultHSR.self).detailInfo!
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

private let summaryGI: Enka.QueriedProfileGI = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileGI.json"
    let dataURL = URL(fileURLWithPath: filePath)
    return try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultGI.self).detailInfo!
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

#Preview {
    /// 注意：请仅用 iOS 或者 MacCatalyst 来预览。AppKit 无法正常处理这个 View。
    TabView {
        NavigationStack {
            summaryGI
                .asView(theDB: enkaDatabaseGI, expanded: false)
        }
        .tabItem { Text(verbatim: "GI") }
        NavigationStack {
            summaryHSR
                .asView(theDB: enkaDatabaseHSR, expanded: false)
        }
        .tabItem { Text(verbatim: "HSR") }
        NavigationStack {
            summaryGI
                .asView(theDB: enkaDatabaseGI, expanded: true)
        }
        .tabItem { Text(verbatim: "GIEX") }
        NavigationStack {
            summaryHSR
                .asView(theDB: enkaDatabaseHSR, expanded: true)
        }
        .tabItem { Text(verbatim: "HSREX") }
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
