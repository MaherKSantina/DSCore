//
//  File.swift
//
//
//  Created by Maher Santina on 3/4/20.
//

import Vapor
import Fluent

public protocol Controller {
    associatedtype Entity: Model, Content
}

public extension Controller where Entity.IDValue: LosslessStringConvertible {

    func index(req: Request) throws -> EventLoopFuture<[Entity]> {
        return Entity.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Entity> {
        let todo = try req.content.decode(Entity.self)
        return todo.save(on: req.db).map { todo }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Entity.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func setupRoutes(app: Application) {
        let pc = PathComponent.constant(Entity.schema)
        app.get(pc, use: index)
        app.post(pc, use: create)
        app.delete(pc, ":id", use: delete)
    }
}

public protocol DSDatabaseRepresentable: Model, Migration {
    static func setupFields(schemaBuilder: SchemaBuilder) -> SchemaBuilder
}

public extension DSDatabaseRepresentable {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return Self.setupFields(schemaBuilder: database.schema(Self.schema)).create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}