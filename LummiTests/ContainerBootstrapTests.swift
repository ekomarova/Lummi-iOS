import Testing
import Foundation
import SwiftData
@testable import Lummi

@MainActor
struct ContainerBootstrapTests {

    private struct StoreFailure: Error, Equatable {
        let id: Int
    }

    private func memoryContainer() throws -> ModelContainer {
        try LummiApp.makeInMemoryContainer()
    }

    // Opens with a factory that records the sync flag of every attempt and fails the ones listed in `failing`.
    private func open(
        sync: Bool,
        failing: [Bool: StoreFailure] = [:],
        memoryFails: Bool = false
    ) throws -> (result: ContainerBootstrapResult, attempts: [Bool]) {
        var attempts: [Bool] = []
        let result = try ContainerBootstrap.open(
            isICloudSyncEnabled: sync,
            makeContainer: { isSync in
                attempts.append(isSync)
                if let failure = failing[isSync] { throw failure }
                return try memoryContainer()
            },
            makeInMemoryContainer: {
                if memoryFails { throw StoreFailure(id: 99) }
                return try memoryContainer()
            }
        )
        return (result, attempts)
    }

    // MARK: - Requested store opens

    @Test func open_syncOn_requestedStoreOpens_noFallback() throws {
        let (result, attempts) = try open(sync: true)
        #expect(result.fallback == .none)
        #expect(result.isICloudSyncActive)
        #expect(result.error == nil)
        #expect(attempts == [true])
    }

    @Test func open_syncOff_requestedStoreOpens_noFallback() throws {
        let (result, attempts) = try open(sync: false)
        #expect(result.fallback == .none)
        #expect(!result.isICloudSyncActive)
        #expect(result.syncError == nil)
        #expect(result.storageError == nil)
        #expect(attempts == [false])
    }

    // MARK: - iCloud store fails

    @Test func open_syncOn_cloudFails_fallsBackToLocalStoreAndKeepsCloudError() throws {
        let (result, attempts) = try open(sync: true, failing: [true: StoreFailure(id: 1)])
        #expect(result.fallback == .localOnly)
        #expect(!result.isICloudSyncActive)
        #expect(attempts == [true, false])
        #expect((result.syncError as? StoreFailure) == StoreFailure(id: 1))
        #expect(result.storageError == nil)
    }

    // MARK: - Nothing on disk opens

    @Test func open_syncOn_cloudAndLocalFail_fallsBackToMemoryWithLocalError() throws {
        let (result, attempts) = try open(sync: true, failing: [true: StoreFailure(id: 1), false: StoreFailure(id: 2)])
        #expect(result.fallback == .inMemory)
        #expect(!result.isICloudSyncActive)
        #expect(attempts == [true, false])
        #expect((result.storageError as? StoreFailure) == StoreFailure(id: 2))
        #expect(result.syncError == nil)
    }

    @Test func open_syncOff_localFails_fallsBackToMemoryWithoutRetryingTheSameStore() throws {
        let (result, attempts) = try open(sync: false, failing: [false: StoreFailure(id: 2)])
        #expect(result.fallback == .inMemory)
        #expect(attempts == [false])
        #expect((result.storageError as? StoreFailure) == StoreFailure(id: 2))
    }

    @Test func open_memoryFallbackFailsToo_throws() {
        #expect(throws: StoreFailure.self) {
            try open(sync: false, failing: [false: StoreFailure(id: 2)], memoryFails: true)
        }
    }

    @Test func open_memoryFallback_returnsUsableEmptyStore() throws {
        let (result, _) = try open(sync: false, failing: [false: StoreFailure(id: 2)])
        let context = ModelContext(result.container)
        context.insert(JoyEntry(text: "Still works", date: Date()))
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<JoyEntry>()) == 1)
        #expect(result.container.configurations.allSatisfy { $0.isStoredInMemoryOnly })
    }

    // MARK: - Schema

    @Test func schemaV1_wrapsJoyEntryWithTheVersionSwiftDataAlreadyWrote() {
        #expect(LummiSchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
        #expect(LummiSchemaV1.models.count == 1)
        #expect(LummiSchemaV1.models.first is JoyEntry.Type)
        #expect(LummiMigrationPlan.stages.isEmpty)
    }

    // A store written before the migration plan existed must open with it and keep its entries.
    @Test func migrationPlan_opensStoreWrittenWithoutIt_andKeepsEntries() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("default.store")

        do {
            let legacy = try ModelContainer(
                for: JoyEntry.self,
                configurations: ModelConfiguration(url: url, cloudKitDatabase: .none)
            )
            let context = ModelContext(legacy)
            context.insert(JoyEntry(text: "Written by 1.1.0", date: Date()))
            try context.save()
        }

        let schema = Schema(versionedSchema: LummiSchemaV1.self)
        let reopened = try ModelContainer(
            for: schema,
            migrationPlan: LummiMigrationPlan.self,
            configurations: ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        )
        let entries = try ModelContext(reopened).fetch(FetchDescriptor<JoyEntry>())
        #expect(entries.map(\.text) == ["Written by 1.1.0"])
    }
}
