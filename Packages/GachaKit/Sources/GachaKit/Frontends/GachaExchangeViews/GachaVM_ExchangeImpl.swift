// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - Formats Importable & Exportable.

extension GachaVM {
    public enum ExportableFormat: String, Sendable, Identifiable, CaseIterable {
        case asUIGFv4
        case asSRGFv1

        // MARK: Public

        public var id: String { rawValue }

        public var name: String {
            switch self {
            case .asUIGFv4: "UIGF-v4.0"
            case .asSRGFv1: "SRGF-v1.0"
            }
        }

        public var supportedGames: [Pizza.SupportedGame] {
            switch self {
            case .asUIGFv4: Pizza.SupportedGame.allCases
            case .asSRGFv1: [.starRail]
            }
        }
    }

    public enum ExportableOptions: Sendable, Identifiable {
        case specifiedOwners([GachaProfileID])
        case singleOwner(GachaProfileID)
        case allOwners

        // MARK: Lifecycle

        public init(owners: [GachaProfileID]?) {
            guard let owners, let firstOwner = owners.first else {
                self = .allOwners
                return
            }
            self = switch owners.count {
            case 1: .singleOwner(firstOwner)
            case ...0: .allOwners
            default: .specifiedOwners(owners)
            }
        }

        // MARK: Public

        public var id: String {
            switch self {
            case .specifiedOwners: "specifiedOwners"
            case .singleOwner: "singleOwner"
            case .allOwners: "allOwners"
            }
        }

        public var localizedName: String {
            "gachaKit.exportableOptions.\(id)"
        }

        public func supportedExportableFormats(by game: Pizza.SupportedGame) -> [ExportableFormat] {
            switch (self, game) {
            case (.singleOwner, .starRail): ExportableFormat.allCases
            default: [.asUIGFv4]
            }
        }
    }

    public enum ImportableFormat: String, Sendable, Identifiable, CaseIterable {
        case asUIGFv4
        case asSRGFv1
        case asGIGFJson
        case asGIGFExcel

        // MARK: Public

        public var id: String { rawValue }

        public var name: String {
            switch self {
            case .asUIGFv4: "UIGF-v4.0"
            case .asSRGFv1: "SRGF-v1.0"
            case .asGIGFJson: "GIGF-JSON (UIGF-v2.2…v3.0)"
            case .asGIGFExcel: "GIGF-Excel (UIGF-v2.0…v2.2)"
            }
        }

        public var supportedGames: [Pizza.SupportedGame] {
            switch self {
            case .asUIGFv4: Pizza.SupportedGame.allCases
            case .asSRGFv1: [.starRail]
            case .asGIGFExcel, .asGIGFJson: [.genshinImpact]
            }
        }
    }
}

// MARK: - Extra Tasks dedicated for Gacha Data Exchange (UIGF, etc.)