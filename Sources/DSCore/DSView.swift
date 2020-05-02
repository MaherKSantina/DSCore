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
}

public protocol DSViewFields {
    static var viewFields: [DSViewField] { get }
}

public protocol DSDatabaseViewQuery {
    static var viewQuery: String { get }
}

public protocol DSView: DSEntityRead, DSDatabaseViewQuery, DSViewFields {

}

public struct ViewInformation {
    public var schema: String
    public var fields: [DSViewField]
}

public extension DSView {
    static var viewInformation: ViewInformation {
        return ViewInformation(schema: schema, fields: viewFields)
    }
}

public extension DSJoinsRepresentableView {
    static var viewQuery: String {
        let select = ([mainEntity] + entities).map { (entity) -> [(String, DSViewField)] in
            return entity.fields.map{ (entity.schema, $0) }
        }
        .flatMap{ $0 }
        .map{ "`\($0.0)`.`\($0.1.key)` AS `\($0.0)_\($0.1.key)`" }
        .joined(separator: ", ")

        let joinClause = joins.map{ "\($0.joinType.query) `\($0.foreignEntity)` ON `\($0.foreignEntity)`.`\($0.foreignEntityKey)` = `\(mainEntity.schema)`.`\($0.entityKey)` " }.joined(separator: " ")

        let final = """
        SELECT
        `\(mainEntity.schema)`.`\(mainEntity.fields.first?.key ?? "id")` AS `id`,
        \(select)
        FROM
        `\(mainEntity.schema)`
        \(joinClause)
        """
        return final
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
    public var foreignEntity: String
    public var entityKey: String
    public var foreignEntityKey: String
    public var joinType: DSEntityJoin

    public init(foreignEntity: String, entityKey: String, foreignEntityKey: String, joinType: DSEntityJoin) {
        self.foreignEntity = foreignEntity
        self.entityKey = entityKey
        self.foreignEntityKey = foreignEntityKey
        self.joinType = joinType
    }
}

public protocol DSJoinsRepresentableView: DSView {
    static var mainEntity: ViewInformation { get }
    static var entities: [ViewInformation] { get }
    static var joins: [Join] { get }
}
