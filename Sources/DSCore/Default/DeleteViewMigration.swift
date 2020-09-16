//
//  File.swift
//
//
//  Created by Maher Santina on 9/6/20.
//

import Foundation
import Vapor
import Fluent
import FluentMySQLDriver

public class DeleteViewMigration<Model: DSView> {

    public var model: Model.Type

    public init(model: Model.Type) {
        self.model = model
    }
}

extension DeleteViewMigration: Migration {
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return (database as! MySQLDatabase).query("Drop view if exists `\(Model.schema)`").transform(to: ())
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.future()
    }
}
