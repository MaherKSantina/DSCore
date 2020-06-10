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

public protocol DSIdentifiable {
    associatedtype IDValue: Codable, Hashable
    var id: IDValue? { get set }
}

public protocol DSEntity: Model, Content, DSIdentifiable {
    
}

public protocol DSEntityWrite: DSEntity {
    static func entityCreate(req: Request) throws -> EventLoopFuture<Self>
    static func entityDelete(req: Request) throws -> EventLoopFuture<HTTPStatus>
    func entityCreate(req: Request) throws -> EventLoopFuture<Self>
    func entityDelete(req: Request) throws -> EventLoopFuture<HTTPStatus>
}

public extension DSEntityWrite {
    static func createEntity(req: Request) throws -> EventLoopFuture<Self> {
        let todo = try req.content.decode(Self.self)
        todo._$id.exists = todo.id != nil
        return todo.save(on: req.db).map { todo }
    }

    func entityCreate(req: Request) throws -> EventLoopFuture<Self> {
        self._$id.exists = self.id != nil
        return self.save(on: req.db).map { self }
    }

    func entityDelete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return self.delete(on: req.db).transform(to: .ok)
    }
}

public extension DSEntityWrite where IDValue: LosslessStringConvertible {
    static func entityDelete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Self.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}

public protocol DSDatabaseFieldsRepresentable {
    static func setupFields(schemaBuilder: SchemaBuilder) -> SchemaBuilder
}
