// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import Observation
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - GachaVM

@Observable
public final class GachaVM: @unchecked Sendable {
    // MARK: Lifecycle

    @MainActor
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: Public

    public enum State: String, Sendable, Hashable, Identifiable {
        case busy
        case standBy

        // MARK: Public

        public var id: String { rawValue }
    }

    @MainActor public var modelContext: ModelContext
    public var task: Task<Void, Never>?
    @MainActor public var hasInheritableGachaEntries: Bool = false
    @MainActor public var taskState: State = .standBy
    @MainActor public var errorMsg: String?
    @MainActor public private(set) var mappedEntriesByPools: [GachaPoolExpressible: [GachaEntryExpressible]] = [:]
    @MainActor public private(set) var currentPentaStars: [GachaEntryExpressible] = []
    @MainActor public private(set) var currentExportableDocument: GachaDocument?

    @MainActor public var currentGPID: GachaProfileID? {
        didSet {
            currentPoolType = Self.defaultPoolType(for: currentGPID?.game)
            updateMappedEntriesByPools()
        }
    }

    @MainActor public var currentPoolType: GachaPoolExpressible? {
        didSet {
            updateCurrentPentaStars()
        }
    }

    // MARK: Fileprivate

    fileprivate static func defaultPoolType(for game: Pizza.SupportedGame?) -> GachaPoolExpressible? {
        switch game {
        case .genshinImpact: .giCharacterEventWish
        case .starRail: .srCharacterEventWarp
        case .zenlessZone: .zzExclusiveChannel
        case .none: nil
        }
    }
}

// MARK: - Tasks and Error Handlers.

extension GachaVM {
    @MainActor
    public func handleError(_ error: Error) {
        withAnimation {
            errorMsg = "\(error)"
            taskState = .standBy
        }
        GachaActor.shared.modelExecutor.modelContext.rollback()
        task?.cancel()
    }

    @MainActor
    public func rebuildGachaUIDList() {
        task?.cancel()
        withAnimation {
            taskState = .busy
            errorMsg = nil
        }
        task = Task {
            do {
                try await GachaActor.shared.refreshAllProfiles()
                Task { @MainActor in
                    withAnimation {
                        if currentGPID == nil {
                            resetDefaultProfile()
                        }
                        taskState = .standBy
                        errorMsg = nil
                    }
                }
            } catch {
                handleError(error)
            }
        }
    }

    /// This method is not supposed to have animation.
    @MainActor
    public func checkWhetherInheritableDataExists() {
        task?.cancel()
        task = Task {
            let hasEntries = await GachaActor.shared.cdGachaMOSputnik.confirmWhetherHavingData()
            Task { @MainActor in
                hasInheritableGachaEntries = hasEntries
            }
        }
    }

    @MainActor
    public func migrateOldGachasIntoProfiles() {
        task?.cancel()
        withAnimation {
            taskState = .busy
            errorMsg = nil
        }
        task = Task {
            do {
                try await GachaActor.migrateOldGachasIntoProfiles()
                Task { @MainActor in
                    withAnimation {
                        if currentGPID == nil {
                            resetDefaultProfile()
                        }
                        taskState = .standBy
                        errorMsg = nil
                    }
                }
            } catch {
                handleError(error)
            }
        }
    }

    @MainActor
    public func updateCurrentPentaStars() {
        guard currentGPID != nil else {
            withAnimation {
                currentPentaStars.removeAll()
            }
            return
        }
        task?.cancel()
        withAnimation {
            taskState = .busy
            errorMsg = nil
        }
        task = Task {
            let filtered = getCurrentPentaStars()
            Task { @MainActor in
                withAnimation {
                    currentPentaStars = filtered
                    taskState = .standBy
                    errorMsg = nil
                    // 此处不需要检查 currentGPID 是否为 nil。
                }
            }
        }
    }

    @MainActor
    public func updateMappedEntriesByPools() {
        guard let currentGPID else {
            withAnimation {
                mappedEntriesByPools.removeAll()
                currentPentaStars.removeAll()
            }
            return
        }
        task?.cancel()
        withAnimation {
            taskState = .busy
            errorMsg = nil
        }
        task = Task {
            do {
                let descriptor = FetchDescriptor<PZGachaEntryMO>(
                    predicate: PZGachaEntryMO.predicate(
                        owner: currentGPID,
                        rarityLevel: nil
                    ),
                    sortBy: [SortDescriptor(\PZGachaEntryMO.id, order: .reverse)]
                )
                var existedIDs = Set<String>() // 用来去除重复内容。
                var fetchedEntries = [GachaEntryExpressible]()
                let context = GachaActor.shared.modelExecutor.modelContext
                let count = try context.fetchCount(descriptor)
                if count > 0 {
                    try context.enumerate(descriptor) { rawEntry in
                        let expressible = rawEntry.expressible
                        if existedIDs.contains(expressible.id) {
                            context.delete(rawEntry)
                        } else {
                            existedIDs.insert(expressible.id)
                            fetchedEntries.append(expressible)
                        }
                    }
                    if context.hasChanges {
                        try context.save()
                    }
                }
                let mappedEntries = fetchedEntries.mappedByPools
                let pentaStars = getCurrentPentaStars(from: mappedEntries)
                Task { @MainActor in
                    withAnimation {
                        mappedEntriesByPools = mappedEntries
                        currentPentaStars = pentaStars
                        taskState = .standBy
                        errorMsg = nil
                        // 此处不需要检查 currentGPID 是否为 nil。
                    }
                }
            } catch {
                handleError(error)
            }
        }
    }
}

// MARK: - Profile Switchers and other tools.

extension GachaVM {
    @MainActor
    fileprivate func getCurrentPentaStars(
        from mappedEntries: [GachaPoolExpressible: [GachaEntryExpressible]]? = nil
    )
        -> [GachaEntryExpressible] {
        let mappedEntries = mappedEntries ?? mappedEntriesByPools
        guard let currentPoolType else {
            return mappedEntries.values.reduce([], +).filter { entry in
                entry.rarity == .rank5
            }
        }
        return mappedEntries[currentPoolType]?.filter { entry in
            entry.rarity == .rank5
        } ?? []
    }

    @MainActor public var currentGPIDTitle: String? {
        guard let pfID = currentGPID else { return nil }
        return nameIDMap[pfID.uidWithGame] ?? nil
    }

    @MainActor public var nameIDMap: [String: String] {
        var nameMap = [String: String]()
        try? modelContext.enumerate(FetchDescriptor<PZProfileMO>(), batchSize: 1) { pzProfile in
            if nameMap[pzProfile.uidWithGame] == nil { nameMap[pzProfile.uidWithGame] = pzProfile.name }
        }
        Defaults[.queriedEnkaProfiles4GI].forEach { uid, enkaProfile in
            let pfID = GachaProfileID(uid: uid, game: .genshinImpact)
            guard nameMap[pfID.uidWithGame] == nil else { return }
            nameMap[pfID.uidWithGame] = enkaProfile.nickname
        }
        Defaults[.queriedEnkaProfiles4HSR].forEach { uid, enkaProfile in
            let pfID = GachaProfileID(uid: uid, game: .starRail)
            guard nameMap[pfID.uidWithGame] == nil else { return }
            nameMap[pfID.uidWithGame] = enkaProfile.nickname
        }
        return nameMap
    }

    @MainActor public var allPZProfiles: [PZProfileMO] {
        let result = try? modelContext.fetch(FetchDescriptor<PZProfileMO>())
        return result?.sorted { $0.priority < $1.priority } ?? []
    }

    @MainActor public var allGPIDs: [GachaProfileID] {
        let context = GachaActor.shared.modelContainer.mainContext
        let result = try? context.fetch(FetchDescriptor<PZGachaProfileMO>()).map(\.asSendable)
        return result?.sorted { $0.uidWithGame < $1.uidWithGame } ?? []
    }

    @MainActor
    public func resetDefaultProfile() {
        let sortedGPIDs = allGPIDs
        guard !sortedGPIDs.isEmpty else { return }
        if let matched = allPZProfiles.first {
            let firstExistingProfile = sortedGPIDs.first {
                $0.uid == matched.uid && $0.game == matched.game
            }
            guard let firstExistingProfile else { return }
            currentGPID = firstExistingProfile
        } else {
            currentGPID = sortedGPIDs.first
        }
    }
}
