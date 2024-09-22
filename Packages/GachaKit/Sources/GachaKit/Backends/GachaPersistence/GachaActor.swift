// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import EnkaKit
import Foundation
import GachaMetaDB
import PZAccountKit
import PZBaseKit
import SwiftData

// MARK: - GachaActor

@ModelActor
public actor GachaActor {
    // MARK: Lifecycle

    public init(unitTests: Bool = false) {
        modelContainer = unitTests ? Self.makeContainer4UnitTests() : Self.makeContainer()
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: .init(modelContainer)
        )
    }

    // MARK: Public

    public let cdGachaMOSputnik = try! CDGachaMOSputnik(persistence: .cloud, backgroundContext: true)
}

extension GachaActor {
    public static var shared = GachaActor()

    public static func makeContainer4UnitTests() -> ModelContainer {
        do {
            return try ModelContainer(
                for:
                PZGachaEntryMO.self,
                PZGachaProfileMO.self,
                configurations:
                ModelConfiguration(
                    "PZGachaEntryMO",
                    schema: Self.schema4Entries,
                    isStoredInMemoryOnly: true,
                    groupContainer: .none,
                    cloudKitDatabase: .none
                ),
                ModelConfiguration(
                    "PZGachaProfileMO",
                    schema: schema4Profiles,
                    isStoredInMemoryOnly: true,
                    groupContainer: .none,
                    cloudKitDatabase: .none
                )
            )
        } catch {
            fatalError("Could not create in-memory ModelContainer: \(error)")
        }
    }

    public static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: PZGachaEntryMO.self, PZGachaProfileMO.self,
                configurations: Self.modelConfig4Entries, Self.modelConfig4Profiles
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

// MARK: - Schemes and Configs.

extension GachaActor {
    public static let schema4Entries = Schema([PZGachaEntryMO.self])
    public static let schema4Profiles = Schema([PZGachaProfileMO.self])

    public static var modelConfig4Entries: ModelConfiguration {
        ModelConfiguration(
            "PZGachaEntryMO",
            schema: Self.schema4Entries,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .private(iCloudContainerName)
        )
    }

    public static var modelConfig4Profiles: ModelConfiguration {
        ModelConfiguration(
            "PZGachaProfileMO",
            schema: schema4Profiles,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .private(iCloudContainerName)
        )
    }
}

// MARK: - CDGachaMO Related Static Methods.

extension GachaActor {
    public static func migrateOldGachasIntoProfiles() async throws {
        try await Self.shared.migrateOldGachasIntoProfiles()
    }

    public func migrateOldGachasIntoProfiles() throws {
        let oldData = try cdGachaMOSputnik.allCDGachaMOAsPZGachaEntryMO()
        try batchInsert(oldData)
    }

    public func batchInsert(_ sources: [PZGachaEntrySendable]) throws {
        let allExistingEntryIDs: [String] = try modelContext.fetch(FetchDescriptor<PZGachaEntryMO>()).map(\.id)
        var profiles: Set<GachaProfileID> = .init()
        sources.forEach { theEntry in
            if !allExistingEntryIDs.contains(theEntry.id) {
                modelContext.insert(theEntry.asMO)
            }
            let profile = GachaProfileID(uid: theEntry.uid, game: theEntry.gameTyped)
            if !profiles.contains(profile) {
                profiles.insert(profile)
            }
        }
        try modelContext.save()
        // try lazyRefreshProfiles(newProfiles: profiles)
        try refreshAllProfiles()
    }

    public func lazyRefreshProfiles(newProfiles: Set<GachaProfileID>? = nil) throws {
        let existingProfiles = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
        var profiles = newProfiles ?? .init()
        existingProfiles.forEach {
            profiles.insert($0.asSendable)
            modelContext.delete($0)
        }
        try modelContext.save()
        let arrProfiles = profiles.sorted { $0.uidWithGame < $1.uidWithGame }
        arrProfiles.forEach { modelContext.insert($0.asMO) }
        try modelContext.save()
    }

    public func refreshAllProfiles() throws {
        let oldProfileMOs = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
        var profiles = oldProfileMOs.map(\.asSendable)
        var entryFetchDescriptor = FetchDescriptor<PZGachaEntryMO>()
        entryFetchDescriptor.propertiesToFetch = [\.uid, \.game]
        let filteredEntries = try modelContext.fetch(entryFetchDescriptor)
        filteredEntries.forEach { currentGachaEntry in
            let alreadyExisted = profiles.first { $0.uidWithGame == currentGachaEntry.uidWithGame }
            guard alreadyExisted == nil else { return }
            let newProfile = GachaProfileID(uid: currentGachaEntry.uid, game: currentGachaEntry.gameTyped)
            profiles.append(newProfile)
        }
        oldProfileMOs.forEach { modelContext.delete($0) }
        try modelContext.save()
        profiles.forEach { modelContext.insert($0.asMO) }
        try modelContext.save()
    }
}

// MARK: - UIGF & SRGF Exporter APIs.

extension GachaActor {
    public func prepareUIGFv4(
        for owners: [GachaProfileID]? = nil,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> UIGFv4 {
        var entries = [PZGachaEntrySendable]()
        var descriptor = FetchDescriptor<PZGachaEntryMO>()
        if let owners, !owners.isEmpty {
            try owners.forEach { pfID in
                let theUID = pfID.uid
                let theGame = pfID.game.rawValue
                descriptor.predicate = #Predicate { currentEntry in
                    currentEntry.game == theGame && currentEntry.uid == theUID
                }
                try modelContext.enumerate(descriptor) { entry in
                    entries.append(entry.asSendable)
                }
            }
        } else {
            try modelContext.enumerate(descriptor) { entry in
                entries.append(entry.asSendable)
            }
        }
        return try UIGFv4(info: .init(), entries: entries, lang: lang)
    }

    public func prepareSRGFv1(
        for owner: GachaProfileID,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> SRGFv1 {
        var entries = [any PZGachaEntryProtocol]()
        var descriptor = FetchDescriptor<PZGachaEntryMO>()
        let theUID = owner.uid
        let theGame = owner.game.rawValue
        descriptor.predicate = #Predicate { currentEntry in
            currentEntry.game == theGame && currentEntry.uid == theUID
        }
        try modelContext.enumerate(descriptor) { entry in
            entries.append(entry.asSendable)
        }
        let uigfProfiles = try entries.extractProfiles(UIGFv4.GachaItemHSR.self, lang: lang)
        let srgfEntries = uigfProfiles.map(\.list).reduce([], +).map(\.asSRGFv1Item)
        return .init(info: .init(uid: owner.uid, lang: lang), list: srgfEntries)
    }

    public func prepareUIGFv4Document(
        for owners: [GachaProfileID]? = nil,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> GachaDocument {
        .init(model: try prepareUIGFv4(for: owners, lang: lang))
    }

    public func prepareSRGFv4Document(
        for owner: GachaProfileID,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> GachaDocument {
        .init(model: try prepareSRGFv1(for: owner, lang: lang))
    }

    public func prepareGachaDocument(
        for owner: GachaProfileID,
        format: GachaVM.ExportableFormat,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> GachaDocument {
        switch format {
        case .asUIGFv4: .init(model: try prepareUIGFv4(for: [owner], lang: lang))
        case .asSRGFv1: .init(model: try prepareSRGFv1(for: owner, lang: lang))
        }
    }
}
