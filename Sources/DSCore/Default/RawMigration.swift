//
//  File.swift
//  
//
//  Created by Maher Santina on 9/9/20.
//

import Vapor
import Fluent
import FluentMySQLDriver

class RawMigration {
    var query: String

    init(query: String) {
        self.query = query
    }
}

extension RawMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return (database as! MySQLDatabase).query(query).transform(to: ())
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.future()
    }


}
