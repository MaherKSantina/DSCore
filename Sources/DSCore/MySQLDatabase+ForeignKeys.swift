//
//  File.swift
//  
//
//  Created by Maher Santina on 6/16/20.
//

import Vapor
import FluentMySQLDriver

public extension MySQLDatabase {
    func foreignKeys(schema: String) -> EventLoopFuture<[DatabaseConstraint]> {
        return self.simpleQuery("""
        SELECT * FROM information_schema.TABLE_CONSTRAINTS
        WHERE information_schema.TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'FOREIGN KEY'
        AND information_schema.TABLE_CONSTRAINTS.TABLE_SCHEMA = Database()
        AND information_schema.TABLE_CONSTRAINTS.TABLE_NAME = '\(schema)';
        """).map{ $0.map{ DatabaseConstraint(mySQLRow: $0) } }
    }

    func deleteForeignKeys(schema: String) -> EventLoopFuture<Void> {
        let constraints = self
            .foreignKeys(schema: schema)
            .map { $0.map{ $0.CONSTRAINT_NAME } }

        return constraints.flatMap {
            $0.map { self.simpleQuery("ALTER TABLE `\(schema)` DROP FOREIGN KEY `\($0)`;").map{ _ in return () } }.flatten(on: self.eventLoop)
        }
    }
}
