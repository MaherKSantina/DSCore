//
//  File.swift
//  
//
//  Created by Maher Santina on 4/4/20.
//

import Vapor
import Fluent

public protocol EntityChangeController {
    func entityDidChange(req: Request)
}

public protocol GetController {
    associatedtype GetEntity: Model
    associatedtype GetEntityOut: Content

    func getQueryBuilderTransform(req: Request, queryBuilder: QueryBuilder<GetEntity>) throws -> QueryBuilder<GetEntity>
    func getTransformOut(result: [GetEntity]) -> [GetEntityOut]
    func get(req: Request) throws -> EventLoopFuture<[GetEntityOut]>
}

public extension GetController {

    func getQueryBuilderTransform(req: Request, queryBuilder: QueryBuilder<GetEntity>) throws -> QueryBuilder<GetEntity> {
        return queryBuilder
    }
}

public extension GetController where GetEntity == GetEntityOut {
    func getTransformOut(result: [GetEntity]) -> [GetEntityOut] {
        return result
    }
}

public extension GetController {
    func get(req: Request) throws -> EventLoopFuture<[GetEntityOut]> {
        let gets = try getQueryBuilderTransform(req: req, queryBuilder: GetEntity.query(on: req.db))
        return gets.all().map{ self.getTransformOut(result: $0) }
    }
}

public protocol DeleteController: EntityChangeController {
    associatedtype DeleteEntity: DSEntityWrite
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus>
}

public extension DeleteController where DeleteEntity.IDValue: LosslessStringConvertible {
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return DeleteEntity.find(req.parameters.get("id"), on: req.db)
        .unwrap(or: Abort(.notFound))
        .flatMap { $0.delete(on: req.db) }
        .transform(to: .ok)
            .always{ _ in
                self.entityDidChange(req: req)
        }
    }
}

public protocol PostController: EntityChangeController {
    associatedtype PostEntityIn: Content
    associatedtype PostEntity: DSEntityWrite
    associatedtype PostEntityOut: Content
    func postTransformIn(content: PostEntityIn, req: Request) throws -> EventLoopFuture<PostEntity>
    func post(req: Request) throws -> EventLoopFuture<PostEntityOut>
    func postTransformOut(content: PostEntity, req: Request) -> EventLoopFuture<PostEntityOut>
    func postCanCreate(item: PostEntity, req: Request) -> Bool
    func postCanUpdate(item: PostEntity, req: Request) -> Bool
}

public extension PostController {
    func postCanCreate(item: PostEntity, req: Request) -> Bool {
        return true
    }

    func postCanUpdate(item: PostEntity, req: Request) -> Bool {
        return true
    }
}

public extension PostController where PostEntity == PostEntityIn {
    func postTransformIn(content: PostEntityIn, req: Request) throws -> EventLoopFuture<PostEntity> {
        return req.eventLoop.makeSucceededFuture(content)
    }
}

public extension PostController where PostEntity == PostEntityOut {
    func postTransformOut(content: PostEntity, req: Request) -> EventLoopFuture<PostEntityOut> {
        return req.eventLoop.makeSucceededFuture(content)
    }
}

public extension PostController {
    func post(req: Request) throws -> EventLoopFuture<PostEntityOut> {
        let content = try req.content.decode(PostEntityIn.self)
        let item = try postTransformIn(content: content, req: req)
        return item
        .flatMapThrowing{ item -> EventLoopFuture<PostEntity> in
            switch (item.id != nil, self.postCanCreate(item: item, req: req), self.postCanUpdate(item: item, req: req)) {
            case (false, true, _), (true, _, true):
                return try item.entityCreate(req: req)
            default:
                throw Abort(.forbidden)
            }
        }
        .always { (_) in
            self.entityDidChange(req: req)
        }
        .flatMap{ $0.flatMap{ self.postTransformOut(content: $0, req: req) } }
    }
}
