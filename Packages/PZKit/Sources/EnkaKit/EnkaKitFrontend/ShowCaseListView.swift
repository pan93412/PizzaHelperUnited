// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SwiftUI

// MARK: - ShowCaseListView

@MainActor
public struct ShowCaseListView<P: EKQueriedProfileProtocol, S: Enka.ProfileSummarized<P>>: View {
    // MARK: Lifecycle

    public init(profile: S, expanded: Bool = false) {
        self.profile = profile
        self.expanded = expanded
    }

    // MARK: Public

    @State public var expanded: Bool

    public var body: some View {
        if !profile.summarizedAvatars.isEmpty {
            if !expanded {
                bodyAsCardCase
            } else {
                bodyAsNavList
            }
        }
    }

    @ViewBuilder public var bodyAsNavList: some View {
        ScrollView {
            Spacer()
            VStack {
                Divided {
                    // TabView 以 EnkaID 为依据，不能仅依赖资料本身的 Identifiable 特性。
                    ForEach(profile.summarizedAvatars) { avatar in
                        Button {
                            tapticMedium()
                            var transaction = Transaction()
                            transaction.animation = .easeInOut
                            transaction.disablesAnimations = !animateOnCallingCharacterShowcase
                            withTransaction(transaction) {
                                // TabView 以 EnkaId 为依据。
                                showingCharacterIdentifier = avatar.id
                            }
                        } label: {
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
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        #if !os(OSX)
        .fullScreenCover(item: $showingCharacterIdentifier) { enkaId in
            fullScreenCover(selectedAvatarID: enkaId)
        }
        #endif
    }

    @ViewBuilder public var bodyAsCardCase: some View {
        // （Enka 被天空岛服务器喂屎的情形会导致 profile.summarizedAvatars 成为空阵列。）
        if profile.summarizedAvatars.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    HStack {
                        // TabView 以 EnkaID 为依据，不能仅依赖资料本身的 Identifiable 特性。
                        ForEach(profile.summarizedAvatars, id: \.mainInfo.uniqueCharId) { avatar in
                            Button {
                                tapticMedium()
                                var transaction = Transaction()
                                transaction.animation = .easeInOut
                                transaction.disablesAnimations = !animateOnCallingCharacterShowcase
                                withTransaction(transaction) {
                                    // TabView 以 EnkaId 为依据。
                                    showingCharacterIdentifier = avatar.mainInfo.uniqueCharId
                                }
                            } label: {
                                avatar.asCardIcon(75)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
                HelpTextForScrollingOnDesktopComputer(.horizontal)
            }
            #if !os(OSX)
            .fullScreenCover(item: $showingCharacterIdentifier) { enkaId in
                fullScreenCover(selectedAvatarID: enkaId)
            }
            #endif
        }
    }

    // MARK: Internal

    @State var showingCharacterIdentifier: String?
    @Default(.animateOnCallingCharacterShowcase) var animateOnCallingCharacterShowcase: Bool
    @State var profile: S

    @ViewBuilder
    func fullScreenCover(selectedAvatarID: String) -> some View {
        AvatarShowCaseView(
            selectedAvatarID: selectedAvatarID,
            profile: profile
        ) {
            var transaction = Transaction()
            transaction.animation = .easeInOut
            transaction.disablesAnimations = !animateOnCallingCharacterShowcase
            withTransaction(transaction) {
                showingCharacterIdentifier = nil
            }
        }
        .environment(\.colorScheme, .dark)
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private func tapticMedium() {
        #if !os(OSX)
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
        #endif
    }
}

extension EKQueriedProfileProtocol {
    @MainActor
    public func asView(
        theDB: Self.DBType,
        expanded: Bool = false
    )
        -> ShowCaseListView<Self, Enka.ProfileSummarized<Self>> {
        .init(profile: summarize(theDB: theDB), expanded: expanded)
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
        summaryGI
            .asView(theDB: enkaDatabaseGI, expanded: false).frame(width: 510, height: 720)
            .tabItem { Text(verbatim: "GI") }
        summaryHSR
            .asView(theDB: enkaDatabaseHSR, expanded: false).frame(width: 510, height: 720)
            .tabItem { Text(verbatim: "HSR") }
        summaryGI
            .asView(theDB: enkaDatabaseGI, expanded: true).frame(width: 510, height: 720)
            .tabItem { Text(verbatim: "GIEX") }
        summaryHSR
            .asView(theDB: enkaDatabaseHSR, expanded: true).frame(width: 510, height: 720)
            .tabItem { Text(verbatim: "HSREX") }
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif