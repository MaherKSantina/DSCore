//
//  File.swift
//  
//
//  Created by Maher Santina on 3/5/20.
//

import Vapor
import Fluent

public final class TableMigration<T: DSDatabaseRepresentable> {
    public init() { }
}

extension TableMigration: Migration {
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return T.setupFields(schemaBuilder: database.schema(T.schema)).create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(T.schema).delete()
    }
}

public extension DSDatabaseRepresentable {
    static var tableMigration: TableMigration<Self> {
        return TableMigration()
    }
}
