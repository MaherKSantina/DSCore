//
//  File.swift
//  
//
//  Created by Maher Santina on 3/15/20.
//

import Vapor
import FluentMySQLDriver

public final class ViewMigration<T: DSDatabaseViewQuery & Model>: Migration {
    public init() { }
}

public extension ViewMigration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        guard let mysqlDatabase = database as? MySQLDatabase else { assertionFailure(); return database.eventLoop.future() }
        let query = "CREATE VIEW `ndis`.`\(T.schema)` AS \(T.viewQuery)"
        return mysqlDatabase.simpleQuery("DROP VIEW IF EXISTS `ndis`.`\(T.schema)`").flatMap{ _ in mysqlDatabase.simpleQuery(query) }.map{ _ in return }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        guard let mysqlDatabase = database as? MySQLDatabase else { assertionFailure(); return database.eventLoop.future() }
        return mysqlDatabase.simpleQuery("DROP VIEW IF EXISTS `ndis`.`\(T.schema)`").map{ _ in return }
    }
}

public extension DSDatabaseViewQuery where Self: Model {
    static var viewMigration: ViewMigration<Self> {
        return ViewMigration()
    }
}
