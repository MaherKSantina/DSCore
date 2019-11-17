//
//  EnableReferencesMigration.swift
//  App
//
//  Created by Maher Santina on 7/13/19.
//

import Fluent
import FluentMySQL

struct EnableReferencesMigration: Migration {
    
    typealias Database = MySQLDatabase
    
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.enableReferences(on: conn)
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return conn.future()
    }
}
