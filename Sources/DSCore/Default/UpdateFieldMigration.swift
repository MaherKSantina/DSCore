//
//  File.swift
//
//
//  Created by Maher Santina on 9/5/20.
//

import Fluent
import Vapor

public class UpdateFieldMigration<Model> where Model: DSModel {

    public var model: Model.Type
    public var key: FieldKey
    public var dataType: DatabaseSchema.DataType

    init(model: Model.Type, key: FieldKey, dataType: DatabaseSchema.DataType) {
        self.model = model
        self.key = key
        self.dataType = dataType
    }

}

extension UpdateFieldMigration: Migration {
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(model.schema).updateField(key, dataType).update()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.future()
    }
}
