//
//  DSModel.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import FluentMySQL
import Vapor

public protocol DSModel: DSDatabaseInteractable, Content, Migration, Parameter {
    static var entity: String { get }
}

extension DSModel where Self: MySQLModel {
    public static func revert(on conn: Database.Connection) -> Future<Void> {
        return conn.simpleQuery("Drop table if exists \(entity)").transform(to: ())
    }
}

extension DSModel {
    public static var defaultDatabase: DatabaseIdentifier<MySQLDatabase>? {
        return .mysql
    }
}
