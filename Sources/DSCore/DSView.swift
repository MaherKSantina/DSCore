//
//  File.swift
//  
//
//  Created by Maher Santina on 5/2/20.
//

import Vapor
import Fluent
import FluentMySQLDriver

public protocol DSViewCodingKeys: CodingKey, CaseIterable, DSViewField { }

public protocol DSViewField {
    var key: String { get }
    var alias: String? { get }
}

public extension DSViewField {
    var alias: String? {
        return nil
    }
}

public struct DSViewFieldData: DSViewField {
    public var key: String
    public var alias: String?

    public init(key: String, alias: String? = nil) {
        self.key = key
        self.alias = alias
    }
}

public protocol DSViewFields {
    static var viewFields: [DSViewField] { get }
}

public protocol DSDatabaseViewQuery {
    static var viewQuery: String { get }
}

public protocol DSView: DSEntity, DSDatabaseViewQuery, DSViewFields {

}

public struct ViewIDInformation {
    public var schema: String
    public var key: String

    public init(schema: String, key: String) {
        self.schema = schema
        self.key = key
    }
}

public struct ViewInformation {
    public var schema: String
    public var fields: [DSViewField]

    public init(schema: String, fields: [DSViewField]) {
        self.schema = schema
        self.fields = fields
    }
}

public extension DSView {
    static var viewInformation: ViewInformation {
        return ViewInformation(schema: schema, fields: viewFields)
    }
}

public extension DSViewField where Self: CodingKey {
    var key: String {
        return stringValue
    }
}

public enum DSEntityJoin {
    case left
    case right
    case inner

    var query: String {
        switch self {
        case .left:
            return " LEFT JOIN "
        case .right:
            return " RIGHT JOIN "
        case .inner:
            return " JOIN "
        }
    }
}

public struct Join {
    public var joinType: DSEntityJoin
    public var foreignEntity: String
    public var baseEntity: String
    public var baseEntityKey: String
    public var foreignEntityKey: String

    public init(joinType: DSEntityJoin, baseEntity: String, baseEntityKey: String, foreignEntity: String,  foreignEntityKey: String) {
        self.foreignEntity = foreignEntity
        self.baseEntity = baseEntity
        self.baseEntityKey = baseEntityKey
        self.foreignEntityKey = foreignEntityKey
        self.joinType = joinType
    }
}

public protocol DSJoinsRepresentableView: DSView {
    static var idInformation: ViewIDInformation { get } 
    static var mainEntity: ViewInformation { get }
    static var entities: [ViewInformation] { get }
    static var joins: [Join] { get }
}

public extension DSJoinsRepresentableView {
    static var idInformation: ViewIDInformation {
        return ViewIDInformation(schema: mainEntity.schema, key: "id")
    }
}

public extension DSJoinsRepresentableView {
    static var viewQuery: String {
        let select = ([mainEntity] + entities).map { (entity) -> [(String, DSViewField)] in
            return entity.fields.map{ (entity.schema, $0) }
        }
        .flatMap{ $0 }
        .map{ "`\($0.0)`.`\($0.1.key)` AS `\($0.1.alias ?? "\($0.0)_\($0.1.key)")`" }
        .joined(separator: ", ")

        let joinClause = joins.map{ "\($0.joinType.query) `\($0.foreignEntity)` ON `\($0.foreignEntity)`.`\($0.foreignEntityKey)` = `\($0.baseEntity)`.`\($0.baseEntityKey)`" }.joined(separator: " ")

        let final = """
        SELECT
        `\(idInformation.schema)`.`\(idInformation.key)` AS `id`,
        \(select)
        FROM
        `\(mainEntity.schema)`
        \(joinClause)
        """
        return final
    }
}
