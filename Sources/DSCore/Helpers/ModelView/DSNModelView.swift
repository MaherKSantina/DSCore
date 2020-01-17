//
//  File.swift
//  
//
//  Created by Maher Santina on 12/26/19.
//

import Vapor
import FluentMySQL

public struct DSViewJoin {
    public var type: DSJoinType
    public var foreignTable: String
    public var foreignKey: String
    public var mainTable: String
    public var mainTableKey: String

    public init(type: DSJoinType, foreignTable: String, foreignKey: String, mainTable: String, mainTableKey: String) {
        self.type = type
        self.foreignTable = foreignTable
        self.foreignKey = foreignKey
        self.mainTable = mainTable
        self.mainTableKey = mainTableKey
    }
}

public struct DSViewTable {
    public var name: String
    public var fields: [String]

    public init(name: String, fields: [String]) {
        self.name = name
        self.fields = fields
    }
}

public protocol DSNModelView: DSView {
    static var tables: [DSViewTable] { get }
    static var mainTableName: String { get }
    static var joins: [DSViewJoin] { get }
}

extension DSNModelView {
    public static var entity: String {
        return tableName
    }
}

extension DSNModelView {

    public static var modelNames: [String] {
        return tables.map{ $0.name }
    }

    public static var selectClause: String {
        return tables.map { (table) -> String in
            return table.fields.map { (field) -> String in
                return "`\(table.name)`.`\(field)` as `\(table.name)_\(field)`"
            }.joined(separator: " , ")
        }.joined(separator: " , ")
    }

    public static var fromClause: String {
        return " \(mainTableName) "
    }

    public static var joinClause: String {
        return joins.map { (join) -> String in
            return "\(join.type.rawValue) `\(join.foreignTable)` ON `\(join.foreignTable)`.`\(join.foreignKey)` = `\(join.mainTable)`.`\(join.mainTableKey)`"
        }.joined(separator: " ")
    }

    public static var migrationQueryString: String {
        return "Create or Replace View \(tableName) as SELECT \(selectClause) FROM \(fromClause) \(joinClause)"
    }
}

extension DSNModelView {
    public static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        let query = migrationQueryString
        return conn.raw(query).run()
    }
}
