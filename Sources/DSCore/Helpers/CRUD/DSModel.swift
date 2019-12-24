//
//  DSModel.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import FluentMySQL
import Vapor

public protocol DSDatabaseEntityRepresentable {
    static var entity: String { get }
}

public protocol DSDatabaseEntity: DSDatabaseEntityRepresentable, Content, Migration where Database == MySQLDatabase {

}

public protocol DSModel: DSDatabaseEntity, DSDatabaseReadWriteInteractable, MySQLModel, Parameter {

}

public protocol DSView: DSDatabaseEntity, DSDatabaseReadOnlyInteractable, MySQLView {

}

extension MySQLModel {
    public static func revert(on conn: MySQLConnection) -> Future<Void> {
        return conn.simpleQuery("Drop table if exists \(entity)").transform(to: ())
    }
}

extension MySQLView {
    public static func revert(on conn: MySQLConnection) -> Future<Void> {
        return conn.simpleQuery("Drop view if exists \(tableName)").transform(to: ())
    }
}

extension DSDatabaseEntity {
    public static var defaultDatabase: DatabaseIdentifier<MySQLDatabase>? {
        return .mysql
    }
}
