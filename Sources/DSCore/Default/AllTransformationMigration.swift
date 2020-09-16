//
//  File.swift
//  
//
//  Created by Maher Santina on 9/9/20.
//

import Vapor
import Fluent

class AllTransformationMigration<Model: DSModel> {

    var model: Model.Type

    var transformation: ((Model) -> Model)

    init(model: Model.Type, transformation: @escaping ((Model) -> Model)) {
        self.model = model
        self.transformation = transformation
    }

}

extension AllTransformationMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return Model.query(on: database).all().map{ $0.map(self.transformation).map{ $0.save(on: database) }.flatten(on: database.eventLoop) }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.future()
    }
}

