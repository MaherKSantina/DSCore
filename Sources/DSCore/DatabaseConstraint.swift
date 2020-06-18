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

    public init(mySQLRow: MySQLRow) {
        self.CONSTRAINT_CATALOG = try! mySQLRow.decode(column: "CONSTRAINT_CATALOG", as: String.self)
        self.CONSTRAINT_SCHEMA = try! mySQLRow.decode(column: "CONSTRAINT_SCHEMA", as: String.self)
        self.CONSTRAINT_NAME = try! mySQLRow.decode(column: "CONSTRAINT_NAME", as: String.self)
        self.TABLE_SCHEMA = try! mySQLRow.decode(column: "TABLE_SCHEMA", as: String.self)
        self.TABLE_NAME = try! mySQLRow.decode(column: "TABLE_NAME", as: String.self)
        self.CONSTRAINT_TYPE = try! mySQLRow.decode(column: "CONSTRAINT_TYPE", as: String.self)
    }
}
