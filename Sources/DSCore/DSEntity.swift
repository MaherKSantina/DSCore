//
//  File.swift
//
//
//  Created by Maher Santina on 3/4/20.
//

import Vapor
import Fluent
import FluentMySQLDriver

public protocol DSEntity: Model, Content {

}

public protocol DSModel: DSEntityRead, DSEntityWrite, DSDatabaseFieldsRepresentable {

}

public protocol DSView: DSEntityRead, DSDatabaseViewQuery {

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

public protocol DSDatabaseViewQuery {
    static var viewQuery: String { get }
}
