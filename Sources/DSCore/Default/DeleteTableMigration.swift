//
//  File.swift
//  
//
//  Created by Maher Santina on 9/9/20.
//

import Vapor
import Fluent

class DeleteTableMigration<Model: DSModel> {

    var model: Model.Type

    init(model: Model.Type) {
        self.model = model
    }

}

extension DeleteTableMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return model.query(on: database).delete()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.future()
    }
}
