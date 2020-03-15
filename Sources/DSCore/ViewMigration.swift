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
        if let mysqlDatabase = database as? MySQLDatabase {
            let query = "CREATE VIEW \(T.schema) AS \(T.viewQuery)"
            return revert(on: database).flatMap{ mysqlDatabase.simpleQuery(query) }.map{ _ in return }
        }
//        else if let sqliteDatabase = database as? SQLiteDatabase {
//            let query = "CREATE VIEW \(T.schema) AS \(T.viewQuery)"
//            return revert(on: database).flatMap{ sqliteDatabase.query(query) }.map{ _ in return }
//        }
        else {
            assertionFailure()
            return database.eventLoop.future()
        }

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        if let mysqlDatabase = database as? MySQLDatabase {
            return mysqlDatabase.simpleQuery("DROP VIEW IF EXISTS \(T.schema)").map{ _ in return }
        }
//        else if let sqliteDatabase = database as? SQLiteDatabase {
//            return sqliteDatabase.query("DROP VIEW IF EXISTS \(T.schema)").map{ _ in return }
//        }
        else {
            assertionFailure()
            return database.eventLoop.future()
        }

    }
}

public extension DSDatabaseViewQuery where Self: Model {
    static var viewMigration: ViewMigration<Self> {
        return ViewMigration()
    }
}
