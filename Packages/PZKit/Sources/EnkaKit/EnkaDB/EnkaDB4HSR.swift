// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import enum EnkaDBModels.EnkaDBModelsHSR
import Foundation

// MARK: - Enka.EnkaDB4HSR

extension Enka {
    @Observable
    public class EnkaDB4HSR: EnkaDBProtocol, Codable {
        // MARK: Lifecycle

        public init(
            locTag: String? = nil,
            locTable: Enka.LocTable,
            profileAvatars: EnkaDBModelsHSR.ProfileAvatarDict,
            characters: EnkaDBModelsHSR.CharacterDict,
            meta: EnkaDBModelsHSR.Meta,
            skillRanks: EnkaDBModelsHSR.SkillRanksDict,
            artifacts: EnkaDBModelsHSR.ArtifactsDict,
            skills: EnkaDBModelsHSR.SkillsDict,
            skillTrees: EnkaDBModelsHSR.SkillTreesDict,
            weapons: EnkaDBModelsHSR.WeaponsDict
        ) {
            self.locTag = Enka.sanitizeLangTag(locTag ?? Locale.langCodeForEnkaAPI)
            self.locTable = locTable
            self.profileAvatars = profileAvatars
            self.characters = characters
            self.meta = meta
            self.skillRanks = skillRanks
            self.artifacts = artifacts
            self.skills = skills
            self.skillTrees = skillTrees
            self.weapons = weapons
        }

        // MARK: Public

        public var locTag: String
        public var locTable: Enka.LocTable
        public var profileAvatars: EnkaDBModelsHSR.ProfileAvatarDict
        public var characters: EnkaDBModelsHSR.CharacterDict
        public var meta: EnkaDBModelsHSR.Meta
        public var skillRanks: EnkaDBModelsHSR.SkillRanksDict
        public var artifacts: EnkaDBModelsHSR.ArtifactsDict
        public var skills: EnkaDBModelsHSR.SkillsDict
        public var skillTrees: EnkaDBModelsHSR.SkillTreesDict
        public var weapons: EnkaDBModelsHSR.WeaponsDict
        public var isExpired: Bool = false

        // MARK: Private

        private enum CodingKeys: CodingKey {
            case _locTag
            case _locTable
            case _profileAvatars
            case _characters
            case _meta
            case _skillRanks
            case _artifacts
            case _skills
            case _skillTrees
            case _weapons
            case _isExpired
        }
    }
}

// MARK: - Protocol Conformance.

extension Enka.EnkaDB4HSR {
    public var game: Enka.HoyoGame { .starRail }

    /// Only available for characters and Weapons.
    public func getNameTextMapHash(id: String) -> String? {
        var matchedInts: [Int] = characters.compactMap {
            guard $0.key.hasPrefix(id) else { return nil }
            return $0.value.avatarName.hash
        }
        matchedInts += weapons.compactMap {
            guard $0.key.hasPrefix(id) else { return nil }
            return $0.value.equipmentName.hash
        }
        return matchedInts.first?.description
    }

    @MainActor
    public func update(new: Enka.EnkaDB4HSR) {
        locTag = new.locTag
        locTable = new.locTable
        profileAvatars = new.profileAvatars
        characters = new.characters
        meta = new.meta
        skillRanks = new.skillRanks
        artifacts = new.artifacts
        skills = new.skills
        skillTrees = new.skillTrees
        weapons = new.weapons
    }
}

// MARK: - Use bundled resources to initiate an EnkaDB instance.

extension Enka.EnkaDB4HSR {
    public convenience init(locTag: String? = nil) throws {
        let locTables = try Enka.JSONType.hsrLocTable.bundledJSONData
            .assertedParseAs(Enka.RawLocTables.self)
        let locTag = Enka.sanitizeLangTag(locTag ?? Locale.langCodeForEnkaAPI)
        guard let locTableSpecified = locTables[locTag] else {
            throw Enka.EKError.langTableMatchFailure
        }
        self.init(
            locTag: locTag,
            locTable: locTableSpecified,
            profileAvatars: try Enka.JSONType.hsrProfileAvatarIcons.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.ProfileAvatarDict.self),
            characters: try Enka.JSONType.hsrCharacters.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.CharacterDict.self),
            meta: try Enka.JSONType.hsrMetadata.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.Meta.self),
            skillRanks: try Enka.JSONType.hsrSkillRanks.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.SkillRanksDict.self),
            artifacts: try Enka.JSONType.hsrArtifacts.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.ArtifactsDict.self),
            skills: try Enka.JSONType.hsrSkills.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.SkillsDict.self),
            skillTrees: try Enka.JSONType.hsrSkillTrees.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.SkillTreesDict.self),
            weapons: try Enka.JSONType.hsrWeapons.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.WeaponsDict.self)
        )
    }
}
