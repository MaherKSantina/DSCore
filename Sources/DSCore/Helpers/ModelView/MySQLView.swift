//
//  MySQLView.swift
//  App
//
//  Created by Maher Santina on 7/21/19.
//

import FluentMySQL

public protocol MySQLView: Migration, Decodable {
    static var modelNames: [String] { get }
    static var tableName: String { get }
}

extension MySQLView {
    public static var tableName: String {
        return "\(modelNames.joined(separator: "_"))View"
    }
}

extension DSView {
    public static func revert(on conn: Database.Connection) -> EventLoopFuture<Void> {
        return conn.raw("Drop View if exists \(Self.tableName)").run()
    }
}
