//
//  ModelView+WMSQuery.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import FluentMySQL

extension ModelView {
    static func query(onlyOne: Bool) -> DSQuery<Self> {
        return DSQuery(table: Self.tableName, onlyOne: onlyOne)
    }
    
    static func rawBuilder(on conn: MySQLConnection, onlyOne: Bool) -> SQLRawBuilder<MySQLConnection> {
        return query(onlyOne: onlyOne).builder(on: conn)
    }
}
