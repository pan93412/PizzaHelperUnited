// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - Enka.PropertyType

extension Enka {
    /// 原神＆星穹铁道共用的属性类型。
    public enum PropertyType: String, Hashable, CaseIterable, RawRepresentable, Sendable {
        case unknownType = "UnknownType" // 解码失败时专用。
        case anemoAddedRatio = "WindAddedRatio"
        case anemoResistance = "WindResistance"
        case anemoResistanceDelta = "WindResistanceDelta"
        case physicoAddedRatio = "PhysicalAddedRatio"
        case physicoResistance = "PhysicalResistance"
        case physicoResistanceDelta = "PhysicalResistanceDelta"
        case electroAddedRatio = "ThunderAddedRatio"
        case electroResistance = "ThunderResistance"
        case electroResistanceDelta = "ThunderResistanceDelta"
        case fantasticoAddedRatio = "ImaginaryAddedRatio"
        case fantasticoResistance = "ImaginaryResistance"
        case fantasticoResistanceDelta = "ImaginaryResistanceDelta"
        case posestoAddedRatio = "QuantumAddedRatio"
        case posestoResistance = "QuantumResistance"
        case posestoResistanceDelta = "QuantumResistanceDelta"
        case pyroAddedRatio = "FireAddedRatio"
        case pyroResistance = "FireResistance"
        case pyroResistanceDelta = "FireResistanceDelta"
        case cryoAddedRatio = "IceAddedRatio"
        case cryoResistance = "IceResistance"
        case cryoResistanceDelta = "IceResistanceDelta"
        case hydroAddedRatio = "WaterAddedRatio" // GI
        case hydroResistance = "WaterResistance" // GI
        case hydroResistanceDelta = "WaterResistanceDelta" // GI
        case dendroAddedRatio = "GrassAddedRatio" // GI
        case dendroResistance = "GrassResistance" // GI
        case dendroResistanceDelta = "GrassResistanceDelta" // GI
        case geoAddedRatio = "RockAddedRatio" // GI
        case geoResistance = "RockResistance" // GI
        case geoResistanceDelta = "RockResistanceDelta" // GI
        case allDamageTypeAddedRatio = "AllDamageTypeAddedRatio"
        case attack = "Attack"
        case attackAddedRatio = "AttackAddedRatio"
        case attackDelta = "AttackDelta"
        case baseAttack = "BaseAttack"
        case baseDefence = "BaseDefence"
        case baseHP = "BaseHP"
        case baseSpeed = "BaseSpeed"
        case breakUp = "BreakUp"
        case breakDamageAddedRatio = "BreakDamageAddedRatio"
        case breakDamageAddedRatioBase = "BreakDamageAddedRatioBase"
        case criticalChance = "CriticalChance"
        case criticalChanceBase = "CriticalChanceBase"
        case criticalDamage = "CriticalDamage"
        case criticalDamageBase = "CriticalDamageBase"
        case defence = "Defence"
        case defenceAddedRatio = "DefenceAddedRatio"
        case defenceDelta = "DefenceDelta"
        case energyRecovery = "SPRatio"
        case energyRecoveryBase = "SPRatioBase"
        case healRatio = "HealRatio"
        case healRatioBase = "HealRatioBase"
        case healTakenRatio = "HealTakenRatio"
        case hpAddedRatio = "HPAddedRatio"
        case hpDelta = "HPDelta"
        case maxHP = "MaxHP"
        case energyLimit = "MaxSP"
        case speed = "Speed"
        case speedAddedRatio = "SpeedAddedRatio"
        case speedDelta = "SpeedDelta"
        case statusProbability = "StatusProbability"
        case statusProbabilityBase = "StatusProbabilityBase"
        case statusResistance = "StatusResistance"
        case statusResistanceBase = "StatusResistanceBase"
        case elementalMastery = "ElementalMastery" // GI
        case shieldCostMinusRatio = "ShieldCostMinusRatio" // GI
        case skillCoolDownMinusRatio = "SkillCoolDownMinusRatio" // GI
        case allDamageResistance = "AllDamageResistance" // GI
    }
}

// MARK: - Enka.PropertyType + Codable, CodingKeyRepresentable

/// 注意：这个 Enum 目前在技术上来讲无法作为 Dictionary Key 来解码「原神词条数字名称」，
/// 因为在这个场合下无法让自订 decoder 生效。
extension Enka.PropertyType: Codable, CodingKeyRepresentable {
    public init(rawValue: String) {
        guard let matched = Self(enkaPropIDStr4GI: rawValue)
            ?? GIAvatarAttribute(rawValue: rawValue)?.asPropertyType
            ?? Self.allCases.first(where: { $0.rawValue == rawValue })
        else {
            // The rest unknown / unhandled cases are all useless to this app.
            // print("!!! Unknown or Unhandled Property: \(rawValue)")
            self = .unknownType
            return
        }
        self = matched
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let debugDescription = "Wrong type Decodable for Enka.PropertyType"
        let error = DecodingError.typeMismatch(
            Self.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: debugDescription
            )
        )

        if let rawInt = try? container.decode(Int.self),
           let matched = Self(enkaPropID4GI: rawInt) {
            self = matched
            return
        }

        guard let rawStr = try? container.decode(String.self) else {
            throw error
        }
        self = Self(rawValue: rawStr)
    }
}

extension Enka.PropertyType {
    private init?(enkaPropIDStr4GI: String) {
        guard let propID = Int(enkaPropIDStr4GI) else { return nil }
        guard let matched = Self(enkaPropID4GI: propID) else { return nil }
        self = matched
    }

    private init?(enkaPropID4GI propID: Int) {
        switch propID {
        case 1: self = .baseHP
        case 4: self = .baseAttack
        case 7: self = .baseDefence
        case 20: self = .criticalChance
        case 22: self = .criticalDamage
        case 23: self = .energyRecovery
        case 26: self = .healRatio
        case 27: self = .healTakenRatio
        case 28: self = .elementalMastery
        case 29: self = .physicoResistance
        case 30: self = .physicoAddedRatio
        case 40: self = .pyroAddedRatio
        case 41: self = .electroAddedRatio
        case 42: self = .hydroAddedRatio
        case 43: self = .dendroAddedRatio
        case 44: self = .anemoAddedRatio
        case 45: self = .geoAddedRatio
        case 46: self = .cryoAddedRatio
        case 50: self = .pyroResistance
        case 51: self = .electroResistance
        case 52: self = .hydroResistance
        case 53: self = .dendroResistance
        case 54: self = .anemoResistance
        case 55: self = .geoResistance
        case 56: self = .cryoResistance
        case 81: self = .shieldCostMinusRatio
        case 2000: self = .maxHP
        case 2001: self = .attack
        case 2002: self = .defence
        default: return nil
        }
    }
}

// MARK: - Enka.PVPair

extension Enka {
    public struct PVPair: Codable, Hashable, Sendable, Identifiable {
        // MARK: Lifecycle

        /// 该建构子不得用于圣遗物的词条构筑。
        public init(
            theDB: some EnkaDBProtocol,
            type: Enka.PropertyType,
            value: Double
        ) {
            self.type = type
            self.value = value
            var title = (
                theDB.additionalLocTable[type.rawValue] ?? theDB.locTable[type.rawValue] ?? type.rawValue
            )
            Self.sanitizeTitle(&title)
            self.localizedTitle = title
            self.isArtifact = false
            self.count = 0
            self.step = nil
            self.game = theDB.game
        }

        /// 该建构子只得用于圣遗物的词条构筑。
        public init(
            theDB: some EnkaDBProtocol,
            type: Enka.PropertyType,
            value: Double,
            count: Int,
            step: Int?
        ) {
            self.type = type
            self.value = value
            var title = (
                theDB.additionalLocTable[type.rawValue] ?? theDB.locTable[type.rawValue] ?? type.rawValue
            )
            Self.sanitizeTitle(&title)
            self.localizedTitle = title
            self.isArtifact = true
            self.count = count
            self.step = step
            self.game = theDB.game
        }

        // MARK: Public

        /// Game.
        public let game: Enka.GameType
        public let type: Enka.PropertyType
        public let value: Double
        public let localizedTitle: String
        public let isArtifact: Bool
        public let count: Int
        public let step: Int?

        public var id: Enka.PropertyType { type }

        public var valueString: String {
            var copiedValue = value
            let prefix = isArtifact ? "+" : ""
            if type.isPercentage {
                copiedValue *= 100
                return prefix + copiedValue.roundToPlaces(
                    places: 1, round: .up
                ).description + "%"
            }
            return prefix + Int(copiedValue.rounded(.up)).description
        }

        public var iconAssetName: String {
            type.iconAssetName
        }

        // MARK: Internal

        func triage(
            amp arrAmp: inout [Enka.PVPair],
            add arrAdd: inout [Enka.PVPair],
            element: Enka.GameElement
        ) {
            switch type {
            case .attackAddedRatio, .defenceAddedRatio, .hpAddedRatio, .speedAddedRatio: arrAmp.append(self)
            case .allDamageTypeAddedRatio, .attack, .attackDelta,
                 .baseAttack, .baseDefence, .baseHP, .baseSpeed,
                 .breakDamageAddedRatio, .breakDamageAddedRatioBase,
                 .breakUp, .criticalChance, .criticalChanceBase,
                 .criticalDamage, .criticalDamageBase, .defence,
                 .defenceDelta, element.damageAddedRatioProperty,
                 .energyRecovery, .energyRecoveryBase,
                 .healRatio, .healRatioBase,
                 .hpDelta, .maxHP, .speed,
                 .speedDelta, .statusProbability,
                 .statusProbabilityBase, .statusResistance,
                 .statusResistanceBase:
                arrAdd.append(self)
            default: break
            }
        }

        // MARK: Private

        private static func sanitizeTitle(_ title: inout String) {
            title = title.replacingOccurrences(of: "Regeneration", with: "Recharge")
            title = title.replacingOccurrences(of: "Rate", with: "%")
            title = title.replacingOccurrences(of: "Bonus", with: "+")
            title = title.replacingOccurrences(of: "Boost", with: "+")
            title = title.replacingOccurrences(of: "ダメージ", with: "傷害量")
            title = title.replacingOccurrences(of: "能量恢复", with: "元素充能")
            title = title.replacingOccurrences(of: "能量恢復", with: "元素充能")
            title = title.replacingOccurrences(of: "属性", with: "元素")
            title = title.replacingOccurrences(of: "屬性", with: "元素")
            title = title.replacingOccurrences(of: "量子元素", with: "量子")
            title = title.replacingOccurrences(of: "物理元素", with: "物理")
            title = title.replacingOccurrences(of: "虛數元素", with: "虛數")
            title = title.replacingOccurrences(of: "虚数元素", with: "虚数")
            title = title.replacingOccurrences(of: "提高", with: "增幅")
            title = title.replacingOccurrences(of: "与", with: "")
        }
    }
}

// MARK: - GIAvatarAttribute

/// 原神词条 Enum，一律先翻译成 PropertyType 再投入使用。
/// 这个 Enum 有极大概率已经没用了，因为 Enka 查询结果里面的原神词条是以 Stringed Integer 命名的。
private enum GIAvatarAttribute: String, Codable, Hashable, Sendable, CaseIterable, RawRepresentable {
    case baseAttack = "FIGHT_PROP_BASE_ATTACK"
    case maxHP = "FIGHT_PROP_MAX_HP"
    case attack = "FIGHT_PROP_ATTACK"
    case defence = "FIGHT_PROP_DEFENSE"
    case elementalMastery = "FIGHT_PROP_ELEMENT_MASTERY"
    case critRate = "FIGHT_PROP_CRITICAL"
    case critDmg = "FIGHT_PROP_CRITICAL_HURT"
    case healAmp = "FIGHT_PROP_HEAL_ADD"
    case healedAmp = "FIGHT_PROP_HEALED_ADD"
    case chargeEfficiency = "FIGHT_PROP_CHARGE_EFFICIENCY"
    case shieldCostMinusRatio = "FIGHT_PROP_SHIELD_COST_MINUS_RATIO"
    case dmgAmpPyro = "FIGHT_PROP_FIRE_ADD_HURT"
    case dmgAmpHydro = "FIGHT_PROP_WATER_ADD_HURT"
    case dmgAmpDendro = "FIGHT_PROP_GRASS_ADD_HURT"
    case dmgAmpElectro = "FIGHT_PROP_ELEC_ADD_HURT"
    case dmgAmpAnemo = "FIGHT_PROP_WIND_ADD_HURT"
    case dmgAmpCryo = "FIGHT_PROP_ICE_ADD_HURT"
    case dmgAmpGeo = "FIGHT_PROP_ROCK_ADD_HURT"
    case dmgAmpPhysico = "FIGHT_PROP_PHYSICAL_ADD_HURT"
    case hp = "FIGHT_PROP_HP"
    case attackAmp = "FIGHT_PROP_ATTACK_PERCENT"
    case hpAmp = "FIGHT_PROP_HP_PERCENT"
    case defenceAmp = "FIGHT_PROP_DEFENSE_PERCENT"
    case allDmgAddHurt = "FIGHT_PROP_ADD_HURT"
    case speedPercent = "FIGHT_PROP_SPEED_PERCENT"
    case resisElectro = "FIGHT_PROP_ELEC_SUB_HURT"
    case resisPyro = "FIGHT_PROP_FIRE_SUB_HURT"
    case resisDendro = "FIGHT_PROP_GRASS_SUB_HURT"
    case resisCryo = "FIGHT_PROP_ICE_SUB_HURT"
    case resisPhysico = "FIGHT_PROP_PHYSICAL_SUB_HURT"
    case resisGeo = "FIGHT_PROP_ROCK_SUB_HURT"
    case resisHydro = "FIGHT_PROP_WATER_SUB_HURT"
    case resisAnemo = "FIGHT_PROP_WIND_SUB_HURT"
    case allDamageSubHurt = "FIGHT_PROP_SUB_HURT"
    case skillCdMinusRatio = "FIGHT_PROP_SKILL_CD_MINUS_RATIO"

    // MARK: Internal

    var asPropertyType: Enka.PropertyType {
        switch self {
        case .baseAttack: .baseAttack
        case .maxHP: .maxHP
        case .attack: .attack
        case .defence: .defence
        case .elementalMastery: .elementalMastery
        case .critRate: .criticalChance
        case .critDmg: .criticalDamage
        case .healAmp: .healRatio
        case .healedAmp: .healTakenRatio
        case .chargeEfficiency: .energyRecovery
        case .shieldCostMinusRatio: .shieldCostMinusRatio
        case .dmgAmpAnemo: .anemoAddedRatio
        case .dmgAmpCryo: .cryoAddedRatio
        case .dmgAmpDendro: .dendroAddedRatio
        case .dmgAmpElectro: .electroAddedRatio
        case .dmgAmpGeo: .geoAddedRatio
        case .dmgAmpHydro: .hydroAddedRatio
        case .dmgAmpPhysico: .physicoAddedRatio
        case .dmgAmpPyro: .pyroAddedRatio
        case .resisAnemo: .anemoResistance
        case .resisCryo: .cryoResistance
        case .resisDendro: .dendroResistance
        case .resisElectro: .electroResistance
        case .resisGeo: .geoResistance
        case .resisHydro: .hydroResistance
        case .resisPhysico: .physicoResistance
        case .resisPyro: .pyroResistance
        case .hp: .maxHP
        case .attackAmp: .attackAddedRatio
        case .hpAmp: .hpAddedRatio
        case .defenceAmp: .defenceAddedRatio
        case .allDmgAddHurt: .allDamageTypeAddedRatio
        case .speedPercent: .speedAddedRatio
        case .allDamageSubHurt: .allDamageResistance
        case .skillCdMinusRatio: .skillCoolDownMinusRatio
        }
    }
}

extension Enka.PropertyType {
    public var titleSuffix: String {
        var result = ""
        if isDelta { result = "+" }
        if isPercentage { result = "%" }
        return result
    }

    public var isDelta: Bool { rawValue.suffix(5) == "Delta" }

    public var isPercentage: Bool {
        rawValue.contains("Chance")
            || rawValue.contains("Probability")
            || rawValue.contains("Ratio")
            || rawValue.contains("Crit")
            || rawValue.contains("Rate")
            || rawValue.contains("Resistance")
            || rawValue.contains("BreakUp")
            || rawValue.contains("Damage")
    }

    public var iconAssetName: String {
        "property_\(proposedIconFileNameStem)"
    }

    internal var proposedIconFileName: String {
        "\(proposedIconFileNameStem).heic"
    }

    internal var proposedIconFileNameStem: String {
        var nameStem = rawValue
        switch self {
        case .baseHP, .hpAddedRatio, .hpDelta: nameStem = "MaxHP"
        case .baseDefence, .defenceAddedRatio, .defenceDelta: nameStem = "Defence"
        case .attackAddedRatio, .attackDelta, .baseAttack: nameStem = "Attack"
        case .breakDamageAddedRatio, .breakDamageAddedRatioBase: nameStem = "BreakUp"
        case .criticalChanceBase: nameStem = "CriticalChance"
        case .healRatioBase: nameStem = "HealRatio"
        case .statusProbabilityBase: nameStem = "StatusProbability"
        case .speedAddedRatio, .speedDelta: nameStem = "Speed"
        case .energyRecovery: nameStem = "EnergyRecovery"
        case .energyRecoveryBase: nameStem = "EnergyRecovery"
        case .criticalDamageBase: nameStem = "CriticalDamage"
        case .statusResistanceBase: nameStem = "StatusResistance"
        case .energyLimit: nameStem = "EnergyLimit"
        case .allDamageTypeAddedRatio: nameStem = "AllDamageTypeAddedRatio"
        default: break
        }
        return "Icon\(nameStem)"
    }

    /// This variable is only for unit tests.
    internal var proposedIconAssetName: String {
        "property_\(proposedIconFileNameStem)"
    }

    public var hasPropIcon: Bool {
        switch self {
        case .allDamageTypeAddedRatio: return true
        case .baseAttack, .baseDefence, .baseHP: return true
        case .attack: return true
        case .breakUp: return true
        case .criticalChance: return true
        case .criticalDamage: return true
        case .defence: return true
        case .energyLimit: return true
        case .energyRecovery: return true
        case .healRatio: return true
        case .maxHP: return true
        case .speed: return true
        case .statusProbability: return true
        case .statusResistance: return true
        case .pyroAddedRatio: return true
        case .pyroResistanceDelta: return true
        case .cryoAddedRatio: return true
        case .cryoResistanceDelta: return true
        case .fantasticoAddedRatio: return true
        case .fantasticoResistanceDelta: return true
        case .physicoAddedRatio: return true
        case .physicoResistanceDelta: return true
        case .posestoAddedRatio: return true
        case .posestoResistanceDelta: return true
        case .electroAddedRatio: return true
        case .electroResistanceDelta: return true
        case .anemoAddedRatio: return true
        case .anemoResistanceDelta: return true
        case .geoAddedRatio: return true
        case .geoResistanceDelta: return true
        case .hydroAddedRatio: return true
        case .hydroResistanceDelta: return true
        case .dendroAddedRatio: return true
        case .dendroResistanceDelta: return true

        // Other cases requiring reusing existing icons.
        case .hpDelta: return true
        case .healRatioBase: return true
        case .defenceDelta: return true
        case .hpAddedRatio: return true
        case .defenceAddedRatio: return true
        case .attackDelta: return true
        case .attackAddedRatio: return true
        case .criticalChanceBase: return true
        case .breakDamageAddedRatio: return true
        case .breakDamageAddedRatioBase: return true
        case .statusProbabilityBase: return true
        case .speedDelta: return true
        case .energyRecoveryBase: return true
        case .criticalDamageBase: return true
        case .statusResistanceBase: return true
        case .elementalMastery: return true
        case .shieldCostMinusRatio: return true

        default:
            // Just in case that there will be new elements available.
            let condition1 = rawValue.suffix(10) == "AddedRatio" || rawValue.suffix(15) == "ResistanceDelta"
            let condition2 = rawValue.prefix(9) != "AllDamage"
            return condition1 && condition2
        }
    }

    public var element: Enka.GameElement? {
        switch self {
        case .anemoAddedRatio, .anemoResistance, .anemoResistanceDelta:
            .anemo
        case .physicoAddedRatio, .physicoResistance, .physicoResistanceDelta:
            .physico
        case .electroAddedRatio, .electroResistance, .electroResistanceDelta:
            .electro
        case .fantasticoAddedRatio, .fantasticoResistance, .fantasticoResistanceDelta:
            .fantastico
        case .posestoAddedRatio, .posestoResistance, .posestoResistanceDelta:
            .posesto
        case .pyroAddedRatio, .pyroResistance, .pyroResistanceDelta:
            .pyro
        case .cryoAddedRatio, .cryoResistance, .cryoResistanceDelta:
            .cryo
        case .geoAddedRatio, .geoResistance, .geoResistanceDelta:
            .geo
        case .hydroAddedRatio, .hydroResistance, .hydroResistanceDelta:
            .hydro
        case .dendroAddedRatio, .dendroResistance, .dendroResistanceDelta:
            .dendro
        default: nil
        }
    }

    public static var propsForAddedRatioPerElement: [Self] {
        [
            .physicoAddedRatio,
            .anemoAddedRatio,
            .electroAddedRatio,
            .fantasticoAddedRatio,
            .posestoAddedRatio,
            .pyroAddedRatio,
            .cryoAddedRatio,
            .geoAddedRatio,
            .dendroAddedRatio,
            .hydroAddedRatio,
        ]
    }

    public static func getAvatarProperties(
        element: Enka.GameElement
    )
        -> [Enka.PropertyType] {
        var results: [Enka.PropertyType] = [
            .maxHP,
            .attack,
            .defence,
            .speed,
            .criticalChance,
            .criticalDamage,
            .breakUp,
            .energyRecovery,
            .statusProbability,
            .statusResistance,
            .healRatio,
        ]
        switch element {
        case .physico: results.append(.physicoAddedRatio)
        case .anemo: results.append(.anemoAddedRatio)
        case .electro: results.append(.electroAddedRatio)
        case .fantastico: results.append(.fantasticoAddedRatio)
        case .posesto: results.append(.posestoAddedRatio)
        case .pyro: results.append(.pyroAddedRatio)
        case .cryo: results.append(.cryoAddedRatio)
        case .geo: results.append(.geoAddedRatio)
        case .dendro: results.append(.dendroAddedRatio)
        case .hydro: results.append(.hydroAddedRatio)
        }

        return results
    }
}
