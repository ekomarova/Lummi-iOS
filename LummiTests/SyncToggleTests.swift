import Testing
import Foundation
import SwiftData
@testable import Lummi

@MainActor
struct SyncToggleTests {

    private struct StoreFailure: Error, Equatable {
        let id: Int
    }

    // Applies the switch with a factory that records the sync flag of every attempt and fails when `failure` is set.
    private func apply(
        requested: Bool,
        isActive: Bool,
        failure: StoreFailure? = nil
    ) -> (outcome: SyncToggleOutcome, attempts: [Bool]) {
        var attempts: [Bool] = []
        let outcome = SyncToggle.apply(requested: requested, isActive: isActive) { isSync in
            attempts.append(isSync)
            if let failure { throw failure }
            return try LummiApp.makeInMemoryContainer()
        }
        return (outcome, attempts)
    }

    // MARK: - Switch succeeds

    @Test func apply_turnOn_containerOpens_switches() {
        let (outcome, attempts) = apply(requested: true, isActive: false)
        guard case .switched = outcome else {
            Issue.record("Expected .switched, got \(outcome)")
            return
        }
        #expect(attempts == [true])
    }

    @Test func apply_turnOff_containerOpens_switches() {
        let (outcome, attempts) = apply(requested: false, isActive: true)
        guard case .switched = outcome else {
            Issue.record("Expected .switched, got \(outcome)")
            return
        }
        #expect(attempts == [false])
    }

    // MARK: - Switch fails

    @Test func apply_turnOn_containerFails_failsWithTheError() {
        let (outcome, attempts) = apply(requested: true, isActive: false, failure: StoreFailure(id: 1))
        guard case .failed(let error) = outcome else {
            Issue.record("Expected .failed, got \(outcome)")
            return
        }
        #expect(error as? StoreFailure == StoreFailure(id: 1))
        #expect(attempts == [true])
    }

    @Test func apply_turnOff_containerFails_failsWithTheError() {
        let (outcome, _) = apply(requested: false, isActive: true, failure: StoreFailure(id: 2))
        guard case .failed(let error) = outcome else {
            Issue.record("Expected .failed, got \(outcome)")
            return
        }
        #expect(error as? StoreFailure == StoreFailure(id: 2))
    }

    // MARK: - Flag already matches the container

    // The revert of a failed switch changes the flag back, which triggers this call again.
    @Test func apply_revertAfterFailure_isUnchangedAndOpensNothing() {
        let (outcome, attempts) = apply(requested: false, isActive: false, failure: StoreFailure(id: 3))
        guard case .unchanged = outcome else {
            Issue.record("Expected .unchanged, got \(outcome)")
            return
        }
        #expect(attempts.isEmpty)
    }

    // A launch fallback saves "off" while the container is already local.
    @Test func apply_syncActiveAndRequested_isUnchangedAndOpensNothing() {
        let (outcome, attempts) = apply(requested: true, isActive: true)
        guard case .unchanged = outcome else {
            Issue.record("Expected .unchanged, got \(outcome)")
            return
        }
        #expect(attempts.isEmpty)
    }
}
