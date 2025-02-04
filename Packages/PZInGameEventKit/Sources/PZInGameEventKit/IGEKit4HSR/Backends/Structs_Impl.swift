// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit

extension NewsKitHSR {
    public enum NewsType: Int, CaseIterable, Identifiable {
        case events = 0
        case intels = 1
        case notices = 2

        // MARK: Public

        public var id: Int { rawValue }
    }

    public struct AggregatedResult: Sendable {
        public var events: [NewsKitHSR.EventElement] = []
        public var intels: [NewsKitHSR.IntelElement] = []
        public var notices: [NewsKitHSR.NoticeElement] = []

        public var smashed: [any NewsElement] {
            var results: [any NewsElement] = []
            results.append(contentsOf: events)
            results.append(contentsOf: intels)
            results.append(contentsOf: notices)
            return results.filter(\.isValid).sorted { $0.createdAt < $1.createdAt }
        }
    }

    public static func fetchAndAggregate() async throws -> AggregatedResult {
        AggregatedResult(
            events: try await NewsKitHSR.EventElement.queryData().sorted { $0.createdAt > $1.createdAt },
            intels: try await NewsKitHSR.IntelElement.queryData().sorted { $0.createdAt > $1.createdAt },
            notices: try await NewsKitHSR.NoticeElement.queryData().sorted { $0.createdAt > $1.createdAt }
        )
    }

    public static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = .autoupdatingCurrent
        let cachedServerRawValue = Defaults[.defaultServer]
        let cachedServerTyped = HoYo.Server(rawValue: cachedServerRawValue) ?? .asia(.genshinImpact)
        dateFormatter.timeZone = cachedServerTyped.timeZone
        return dateFormatter
    }
}

extension NewsElement {
    public var dateCreated: Date { Date(timeIntervalSince1970: Double(createdAt)) }

    public var dateCreatedStr: String {
        let theDate = Date(timeIntervalSince1970: Double(createdAt))
        return NewsKitHSR.dateFormatter.string(from: theDate)
    }

    public static func decodeFrom(string: String) throws -> Self {
        try JSONDecoder().decode(Self.self, from: Data(string.utf8))
    }

    public static func decodeArrayFrom(string: String) throws -> [Self] {
        try JSONDecoder().decode([Self].self, from: Data(string.utf8))
    }

    public static func queryData(lang: NewsKitHSR.LangForQuery = .defaultValue) async throws -> [Self] {
        let strURL = Self.urlStemForQuery + lang.rawValue
        var dataToParse = Data([])
        do {
            let (data, _) = try await URLSession.shared.data(
                for: URLRequest(url: URL(string: strURL)!)
            )
            dataToParse = data
        } catch {
            print(error)
            throw error
        }
        do {
            let requestResult = try JSONDecoder().decode([Self].self, from: dataToParse)
            return requestResult
        } catch {
            print(error)
            throw error
        }
    }
}

// MARK: - NewsKitHSR.EventElement + NewsElement

extension NewsKitHSR.EventElement: NewsElement {
    public var isValid: Bool { true }
}

// MARK: - NewsKitHSR.IntelElement + NewsElement

extension NewsKitHSR.IntelElement: NewsElement {
    public var isValid: Bool { true }
}

// MARK: - NewsKitHSR.NoticeElement + NewsElement

extension NewsKitHSR.NoticeElement: NewsElement {
    public var isValid: Bool { true }
}

extension NewsKitHSR.LangForQuery {
    public static var defaultValue: Self {
        let languageCode = Locale.preferredLanguages.first
            ?? Bundle.main.preferredLocalizations.first
            ?? "en"
        switch languageCode.prefix(7).lowercased() {
        case "zh-hans": return .zhHans
        case "zh-hant": return .zhHant
        default: break
        }
        switch languageCode.prefix(5).lowercased() {
        case "zh-cn": return .zhHans
        case "zh-tw": return .zhHant
        default: break
        }
        switch languageCode.prefix(2).lowercased() {
        case "ja", "jp": return .ja
        case "ko", "kr": return .ko
        default: break
        }
        return Self(rawValue: languageCode) ?? .en
    }
}
