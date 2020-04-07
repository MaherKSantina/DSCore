//
//  File.swift
//
//
//  Created by Maher Santina on 3/4/20.
//

import Vapor
import Fluent
import FluentMySQLDriver

public extension RawRepresentable where RawValue == String {
    var fieldKey: FieldKey {
        return .string(rawValue)
    }
}

public protocol DSModelCodingKeys: CodingKey, CaseIterable, DSModelField { }
public protocol DSViewCodingKeys: CodingKey, CaseIterable, DSViewField { }

public protocol DSViewField {
    var key: String { get }
}

public protocol DSModelField: DSViewField {
    var dataType: DatabaseSchema.DataType { get }
    var constraints: [DatabaseSchema.FieldConstraint] { get }
}

public protocol DSModelFields {
    static var modelFields: [DSModelField] { get }
}

public protocol DSViewFields {
    static var viewFields: [DSViewField] { get }
}

public protocol DSEntity: Model, Content {

}

public protocol DSModel: DSEntityRead, DSEntityWrite, DSDatabaseFieldsRepresentable, DSModelFields {

}

public protocol DSView: DSEntityRead, DSDatabaseViewQuery, DSViewFields {

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

public struct ViewInformation {
    public var schema: String
    public var fields: [DSViewField]
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

public protocol DSJoinsRepresentable {
    static var mainEntity: ViewInformation { get }
    static var entities: [ViewInformation] { get }
    static var joins: [Join] { get }
}

public extension DSView where Self: DSJoinsRepresentable {
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

public extension DSModel {
    static var viewInformation: ViewInformation {
        return ViewInformation(schema: schema, fields: modelFields.map{ $0 })
    }
}

public extension DSView {
    static var viewInformation: ViewInformation {
        return ViewInformation(schema: schema, fields: viewFields)
    }
}


public protocol DSEntityRead: DSEntity {
    static var queryField: String? { get }
    static func getAll(req: Request) throws -> EventLoopFuture<[Self]>
}

public extension DSEntityRead {
    static var queryField: String? {
        return nil
    }
}

public extension DSEntityRead {
    static func getAll(req: Request) throws -> EventLoopFuture<[Self]> {
        var queryBuilder = Self.query(on: req.db)
        if let field = Self.queryField, let query = try? req.query.get(String.self, at: field) {
            queryBuilder = queryBuilder.filter(FieldKey(stringLiteral: field), .contains(inverse: false, .anywhere), query)
        }
        return queryBuilder.all()
    }
}

public protocol DSEntityWrite: DSEntity {
    static func create(req: Request) throws -> EventLoopFuture<Self>
    static func delete(req: Request) throws -> EventLoopFuture<HTTPStatus>
}

public extension DSEntityWrite {
    static func create(req: Request) throws -> EventLoopFuture<Self> {
        let todo = try req.content.decode(Self.self)
        todo._$id.exists = todo.id != nil
        return todo.save(on: req.db).map { todo }
    }
}

public extension DSEntityWrite where IDValue: LosslessStringConvertible {
    static func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Self.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}

//func setupRoutes(app: Application) {
//    let pc = PathComponent.constant(Entity.schema)
//    app.get(pc, use: getAll)
//    app.post(pc, use: create)
//    app.delete(pc, ":id", use: delete)
//}

public protocol DSDatabaseFieldsRepresentable {
    static func setupFields(schemaBuilder: SchemaBuilder) -> SchemaBuilder
}

public extension DSDatabaseFieldsRepresentable where Self: DSModelFields {
    static func setupFields(schemaBuilder: SchemaBuilder) -> SchemaBuilder {
        var newSchemaBuilder = schemaBuilder
        modelFields.forEach { (modelField) in
            newSchemaBuilder = newSchemaBuilder.field(.definition(name: .key(FieldKey.string(modelField.key)), dataType: modelField.dataType, constraints: modelField.constraints))
        }
        return newSchemaBuilder
    }
}

public protocol DSDatabaseViewQuery {
    static var viewQuery: String { get }
}

public protocol Selfable {
    static var selfKey: String? { get }
}

public extension Selfable {
    static var selfKey: String? {
        return nil
    }
}

public extension DSViewField where Self: CodingKey {
    var key: String {
        return stringValue
    }
}
