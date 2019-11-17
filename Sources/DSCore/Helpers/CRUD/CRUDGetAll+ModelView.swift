//
//  CRUDGetAll+ModelView.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import FluentMySQL

extension CRUDGetAll where Self: ModelView {
    public static func crudGetAll(on connectable: DatabaseConnectable) -> EventLoopFuture<[Self]> {
        guard let conn = connectable as? Container else {
            fatalError()
        }
        return conn.withPooledConnection(to: .mysql, closure: { (connection) -> EventLoopFuture<[Self]> in
            let query = Self.rawBuilder(on: connection, onlyOne: false)
            return query.all(decoding: Self.self)
        })
    }
}
