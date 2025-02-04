// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - NewsElement

public protocol NewsElement: Codable, Sendable, Hashable, Identifiable {
    var id: String { get }
    var createdAt: Int { get }
    var description: String { get }
    var title: String { get }
    var url: String { get }
    var isValid: Bool { get }
    static var urlStemForQuery: String { get }
}

extension NewsKitHSR {
    public struct EventElement: Codable, Sendable, Hashable {
        public static let urlStemForQuery = "https://api.ennead.cc/starrail/news/events?lang="

        public let id: String
        public let createdAt: Int
        public let description: String
        public let title: String
        public let url: String
    }

    public struct IntelElement: Codable, Sendable, Hashable {
        public static let urlStemForQuery = "https://api.ennead.cc/starrail/news/info?lang="

        public let id: String
        public let createdAt: Int
        public let description: String
        public let title: String
        public let url: String
    }

    public struct NoticeElement: Codable, Sendable, Hashable {
        public static let urlStemForQuery = "https://api.ennead.cc/starrail/news/notices?lang="

        public let id: String
        public let createdAt: Int
        public let description: String
        public let title: String
        public let url: String
    }

    // swiftlint:disable identifier_name
    public enum LangForQuery: String, Codable {
        case en
        case zhHans = "cn"
        case zhHant = "tw"
        case de
        case es
        case fr
        case id
        case it
        case ja = "jp"
        case ko = "kr"
        case pt
        case ru
        case th
        case tr
        case vi
    }
    // swiftlint:enable identifier_name
}
