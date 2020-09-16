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

public class RefreshViewMigration<Model: DSView> {

    public var model: Model.Type

    public init(model: Model.Type) {
        self.model = model
    }
}

extension RefreshViewMigration: Migration {
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return (database as! MySQLDatabase).query("Drop view if exists `\(Model.schema)`").flatMap{ _ in return Model.viewMigration.prepare(on: database) }
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return (database as! MySQLDatabase).query("Drop view if exists `\(Model.schema)`").transform(to: ())
    }
}
