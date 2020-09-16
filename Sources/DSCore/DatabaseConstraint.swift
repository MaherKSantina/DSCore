//
//  File.swift
//  
//
//  Created by Maher Santina on 6/16/20.
//

import Vapor
import FluentMySQLDriver

public struct DatabaseConstraint: Content {
    public var CONSTRAINT_CATALOG: String
    public var CONSTRAINT_SCHEMA: String
    public var CONSTRAINT_NAME: String
    public var TABLE_SCHEMA: String
    public var TABLE_NAME: String
    public var CONSTRAINT_TYPE: String

    public init(CONSTRAINT_CATALOG: String, CONSTRAINT_SCHEMA: String, CONSTRAINT_NAME: String, TABLE_SCHEMA: String, TABLE_NAME: String, CONSTRAINT_TYPE: String) {
        self.CONSTRAINT_CATALOG = CONSTRAINT_CATALOG
        self.CONSTRAINT_SCHEMA = CONSTRAINT_SCHEMA
        self.CONSTRAINT_NAME = CONSTRAINT_NAME
        self.TABLE_SCHEMA = TABLE_SCHEMA
        self.TABLE_NAME = TABLE_NAME
        self.CONSTRAINT_TYPE = CONSTRAINT_TYPE
    }

    private static func string(key: String, row: MySQLRow) -> String {
        return row.column(key)!.string!
    }

    public init(mySQLRow: MySQLRow) {
        self.CONSTRAINT_CATALOG = Self.string(key: "CONSTRAINT_CATALOG", row: mySQLRow)
        self.CONSTRAINT_SCHEMA = Self.string(key: "CONSTRAINT_SCHEMA", row: mySQLRow)
        self.CONSTRAINT_NAME = Self.string(key: "CONSTRAINT_NAME", row: mySQLRow)
        self.TABLE_SCHEMA = Self.string(key: "TABLE_SCHEMA", row: mySQLRow)
        self.TABLE_NAME = Self.string(key: "TABLE_NAME", row: mySQLRow)
        self.CONSTRAINT_TYPE = Self.string(key: "CONSTRAINT_TYPE", row: mySQLRow)
    }
}
