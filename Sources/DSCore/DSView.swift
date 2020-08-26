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
    public var fieldsPrefix: String

    public init(schema: String, fields: [DSViewField]) {
        self.schema = schema
        self.fields = fields
        self.fieldsPrefix = schema
    }

    public init(schema: String, fields: [DSViewField], fieldsPrefix: String) {
        self.schema = schema
        self.fields = fields
        self.fieldsPrefix = fieldsPrefix
    }
}

public extension DSModel {
    static var viewInformation: ViewInformation {
        return ViewInformation(schema: schema, fields: modelFields.map{ $0 })
    }

    static func viewInformation(fieldsPrefix: String) -> ViewInformation {
        return ViewInformation(schema: schema, fields: modelFields.map{ $0 }, fieldsPrefix: fieldsPrefix)
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

fileprivate struct QueryInformation {
    var viewInformation: ViewInformation
    var alias: String?

    var selectFields: [ViewSelectField] {
        return viewInformation.fields.map { (viewField) -> ViewSelectField in
            return .init(table: viewInformation.schema, tableAlias: alias ?? viewInformation.schema, newPrefix: viewInformation.fieldsPrefix, tableFieldKey: viewField.key, alias: viewField.alias)
        }
    }
}

fileprivate struct ViewSelectField {
    var table: String
    var tableAlias: String
    var newPrefix: String
    var tableFieldKey: String
    var alias: String?

    var selectString: String {
        return "`\(tableAlias)`.`\(tableFieldKey)` AS `\(alias ?? "\(newPrefix)_\(tableFieldKey)`")"
    }
}

public extension DSJoinsRepresentableView {
    static var viewQuery: String {
        let tables: [QueryInformation] = [
            .init(viewInformation: mainEntity, alias: nil)
        ] + entities.enumerated().map{ QueryInformation(viewInformation: $0.element, alias: "t\($0.offset)") }

        let select = tables
            .flatMap{ $0.selectFields }
            .map{ $0.selectString }
            .joined(separator: ", ")



        let joinClause = joins.enumerated().map{ (offset, element) in
            let entityAlias = "t\(offset)"
             return "\(element.joinType.query) `\(element.foreignEntity)` \(entityAlias) ON `\(entityAlias)`.`\(element.foreignEntityKey)` = `\(element.baseEntity)`.`\(element.baseEntityKey)`"
        }.joined(separator: " ")

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
