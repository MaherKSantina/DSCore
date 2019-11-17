//
//  ModelView.swift
//  App
//
//  Created by Maher Santina on 7/21/19.
//

import FluentMySQL

public protocol ModelView: Decodable {
    static var modelNames: [String] { get }
}

extension ModelView {
    public static var tableName: String {
        return "\(modelNames.joined(separator: "_"))View"
    }
}

extension Migration where Self: ModelView {
    public static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return conn.raw("Drop View if exists \(Self.tableName)").run()
    }
}
