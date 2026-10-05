//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftData

// The data schema that every released app version (App Store 1.0 and 1.1) has used. It wraps the existing JoyEntry
// without changing it. The version below is the SwiftData schema version, not the app version: SwiftData wrote
// "1.0.0" into every existing store by itself, so the same value here means no migration runs for current users.
// Before changing JoyEntry, freeze a copy of it inside this version and add the next version to the plan.
enum LummiSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [JoyEntry.self] }
}

enum LummiMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [LummiSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
