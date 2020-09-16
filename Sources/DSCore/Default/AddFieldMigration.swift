//
//  File.swift
//  
//
//  Created by Maher Santina on 9/5/20.
//

import Fluent
import Vapor

public class AddFieldMigration<Model> where Model: DSModel {

    public var model: Model.Type
    public var field: DatabaseSchema.FieldDefinition

    public var fieldKey: FieldKey? {
        guard case .definition(let fieldName, _, _) = field, case .key(let fieldKey) = fieldName else { return nil }
        return fieldKey
    }

    init(model: Model.Type, field: DatabaseSchema.FieldDefinition) {
        self.model = model
        self.field = field
    }

}

extension AddFieldMigration: Migration {
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(model.schema).field(field).update()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(model.schema).deleteField(fieldKey!).update()
    }
}
