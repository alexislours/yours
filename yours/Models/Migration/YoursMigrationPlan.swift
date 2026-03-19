import SwiftData

enum YoursMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [YoursSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
