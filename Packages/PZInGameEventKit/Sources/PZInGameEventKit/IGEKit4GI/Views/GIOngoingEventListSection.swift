// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - GIOngoingEvents.EventListSection

extension GIOngoingEvents {
    public struct EventListSection<TT: View>: View {
        // MARK: Lifecycle

        public init(peripheralViews: @escaping (() -> TT) = { EmptyView() }) {
            self.peripheralViews = peripheralViews
        }

        // MARK: Public

        public var body: some View {
            MainComponent(eventContents: $eventContents, peripheralViews: peripheralViews)
                .listRowMaterialBackground()
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        getCurrentEvent()
                    default:
                        break
                    }
                }
                .onAppear {
                    if eventContents.isEmpty {
                        getCurrentEvent()
                    }
                }
        }

        // MARK: Internal

        typealias EventModel = GIOngoingEvents.EventList.EventModel

        func getCurrentEvent() {
            Task {
                let fetchResult = await GIOngoingEvents.fetch()
                switch fetchResult {
                case let .success(events):
                    withAnimation {
                        eventContents = [EventModel](events.event.values)
                        eventContents = eventContents.sorted {
                            $0.endAt < $1.endAt
                        }
                    }
                case .failure:
                    break
                }
            }
        }

        // MARK: Private

        @Environment(\.scenePhase) private var scenePhase

        @State private var eventContents: [EventModel] = []
        private let peripheralViews: () -> TT
    }
}

// MARK: - GIOngoingEvents.EventListSection.MainComponent

extension GIOngoingEvents.EventListSection {
    private struct MainComponent<T: View>: View {
        // MARK: Public

        public var body: some View {
            Section {
                peripheralViews()
                if !$eventContents.animation().wrappedValue.isEmpty {
                    VStack {
                        NavigationLink {
                            GIOngoingEventAllListView(eventContents: eventContents)
                        } label: {
                            Text("igev.gi.gameEvents.pendingEvents.title", bundle: .module)
                        }
                        VStack(spacing: 7) {
                            let eventContentsValid = validEventContents.prefix(3)
                            if eventContentsValid.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("igev.gi.gameEvents.noCurrentEventInfo", bundle: .module)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            } else {
                                ForEach(eventContentsValid, id: \.id) { content in
                                    eventItem(event: content)
                                }
                            }
                        }
                        .padding(.top, 2)
                        .id(defaultServer4GI)
                    }
                } else {
                    ProgressView()
                }
            }
        }

        // MARK: Internal

        typealias EventModel = GIOngoingEvents.EventList.EventModel

        typealias IntervalDate = Date.IntervalDate

        var validEventContents: [EventModel] {
            eventContents.filter {
                (GIOngoingEvents.getRemainDays($0.endAt)?.day ?? 0) >= 0
                    && (GIOngoingEvents.getRemainDays($0.endAt)?.hour ?? 0) >= 0
                    && (GIOngoingEvents.getRemainDays($0.endAt)?.minute ?? 0) >= 0
            }
        }

        @ViewBuilder
        func eventItem(event: EventModel) -> some View {
            HStack {
                Text(verbatim: " \(getLocalizedContent(event.name))")
                    .lineLimit(1)
                Spacer()
                if GIOngoingEvents.getRemainDays(event.endAt) == nil {
                    Text(event.endAt)
                } else if GIOngoingEvents.getRemainDays(event.endAt)!.day! > 0 {
                    HStack(spacing: 0) {
                        Text(
                            "igev.gi.gameEvents.daysLeft:\(GIOngoingEvents.getRemainDays(event.endAt)!.day!)",
                            bundle: .module
                        )
                    }
                } else {
                    HStack(spacing: 0) {
                        Text(
                            "igev.gi.gameEvents.hoursLeft:\(GIOngoingEvents.getRemainDays(event.endAt)!.hour!)",
                            bundle: .module
                        )
                    }
                }
            }
            .font(.caption)
            .foregroundColor(.primary)
        }

        func getLocalizedContent(
            _ content: EventModel
                .MultiLanguageContents
        )
            -> String {
            let locale = Bundle.main.preferredLocalizations.first
            switch locale {
            case "zh-Hans":
                return content.CHS
            case "zh-Hant", "zh-Hant-HK", "zh-Hant-TW", "zh-HK", "zh-TW":
                return content.CHT
            case "en":
                return content.EN
            case "ja":
                return content.JP
            case "ru":
                return content.RU
            default:
                return content.EN
            }
        }

        // MARK: Private

        @Environment(\.colorScheme) private var colorScheme
        @Default(.defaultServer) private var defaultServer4GI: String
        @Binding public var eventContents: [EventModel]
        public let peripheralViews: () -> T

        private var viewBackgroundColor: UIColor {
            colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
        }

        private var sectionBackgroundColor: UIColor {
            colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        Form {
            GIOngoingEvents.EventListSection()
        }.formStyle(.grouped)
    }
}
#endif
#endif
